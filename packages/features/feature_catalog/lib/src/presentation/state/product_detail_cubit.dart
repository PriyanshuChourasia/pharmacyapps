import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_models/shared_models.dart';

import 'load_status.dart';

/// State of the product detail screen.
class ProductDetailState extends Equatable {
  const ProductDetailState({
    this.status = LoadStatus.initial,
    this.product,
    this.substitutes = const [],
    this.cartQty = 0,
    this.error,
  });

  final LoadStatus status;
  final Product? product;

  /// Other products sharing this product's salt.
  final List<Product> substitutes;

  /// Quantity of this product in the cart (0 = not in cart).
  final int cartQty;
  final String? error;

  ProductDetailState copyWith({
    LoadStatus? status,
    Product? product,
    List<Product>? substitutes,
    int? cartQty,
    String? error,
  }) =>
      ProductDetailState(
        status: status ?? this.status,
        product: product ?? this.product,
        substitutes: substitutes ?? this.substitutes,
        cartQty: cartQty ?? this.cartQty,
        error: error,
      );

  @override
  List<Object?> get props => [status, product, substitutes, cartQty, error];
}

/// Loads one product plus its same-salt substitutes and mirrors the cart
/// quantity for the Add/stepper control.
class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit(this._catalog, this._cart) : super(const ProductDetailState()) {
    _cartSub = _cart.watch().listen((items) {
      if (isClosed || state.product == null) return;
      final qty = items
          .where((i) => i.productId == state.product!.id)
          .fold(0, (sum, i) => sum + i.qty);
      emit(state.copyWith(cartQty: qty));
    });
  }

  final CatalogRepository _catalog;
  final CartRepository _cart;
  StreamSubscription<List<CartItem>>? _cartSub;

  Future<void> load(String productId) async {
    emit(state.copyWith(status: LoadStatus.loading));
    final result = await _catalog.getProduct(productId);
    if (isClosed) return;

    final product = result.dataOrNull;
    if (product == null) {
      emit(
        state.copyWith(
          status: LoadStatus.error,
          error: result.errorMessageOrNull ?? 'Product not found',
        ),
      );
      return;
    }

    // Substitutes: same salt, different product.
    List<Product> substitutes = const [];
    final all = await _catalog.getProducts();
    final products = all.dataOrNull ?? const <Product>[];
    substitutes = products
        .where((p) => p.id != product.id && p.salt == product.salt)
        .toList(growable: false);

    if (isClosed) return;
    emit(
      state.copyWith(
        status: LoadStatus.loaded,
        product: product,
        substitutes: substitutes,
      ),
    );
    _syncCartQty();
  }

  /// Adds one unit; returns an error message or `null`.
  Future<String?> add() async {
    final product = state.product;
    if (product == null) return null;
    final result = await _cart.add(product);
    if (!isClosed && result.isSuccess) _syncCartQty(result.dataOrNull);
    return result.errorMessageOrNull;
  }

  /// Changes quantity (`0` removes the line). Returns an error or `null`.
  Future<String?> setQty(int qty) async {
    final product = state.product;
    if (product == null) return null;
    final result = qty <= 0
        ? await _cart.remove(product.id)
        : await _cart.updateQty(product.id, qty);
    if (!isClosed && result.isSuccess) _syncCartQty(result.dataOrNull);
    return result.errorMessageOrNull;
  }

  void _syncCartQty([List<CartItem>? items]) {
    final list = items;
    if (list != null) {
      final qty = list
          .where((i) => i.productId == state.product?.id)
          .fold(0, (sum, i) => sum + i.qty);
      emit(state.copyWith(cartQty: qty));
      return;
    }
    final qty = _cart.items
        .where((i) => i.productId == state.product?.id)
        .fold(0, (sum, i) => sum + i.qty);
    emit(state.copyWith(cartQty: qty));
  }

  @override
  Future<void> close() {
    _cartSub?.cancel();
    return super.close();
  }
}

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_models/shared_models.dart';

import 'load_status.dart';

/// Sort options for a category's product list.
enum ProductSort { priceAsc, priceDesc, name }

/// OTC/Rx filter options for a category's product list.
enum ProductFilter { all, otc, rx }

/// State of one category's product list.
class CategoryProductsState extends Equatable {
  const CategoryProductsState({
    required this.categoryId,
    this.status = LoadStatus.initial,
    this.products = const [],
    this.sort = ProductSort.priceAsc,
    this.filter = ProductFilter.all,
    this.cartQty = const {},
    this.error,
  });

  final String categoryId;
  final LoadStatus status;
  final List<Product> products;
  final ProductSort sort;
  final ProductFilter filter;

  /// productId → quantity currently in the cart (drives Add → stepper morph).
  final Map<String, int> cartQty;
  final String? error;

  /// Products after the active filter + sort.
  List<Product> get visible {
    var list = products.where((p) {
      return switch (filter) {
        ProductFilter.all => true,
        ProductFilter.otc => !p.requiresPrescription,
        ProductFilter.rx => p.requiresPrescription,
      };
    }).toList(growable: true);
    switch (sort) {
      case ProductSort.priceAsc:
        list.sort((a, b) => a.price.compareTo(b.price));
      case ProductSort.priceDesc:
        list.sort((a, b) => b.price.compareTo(a.price));
      case ProductSort.name:
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }
    return list;
  }

  CategoryProductsState copyWith({
    LoadStatus? status,
    List<Product>? products,
    ProductSort? sort,
    ProductFilter? filter,
    Map<String, int>? cartQty,
    String? error,
  }) =>
      CategoryProductsState(
        categoryId: categoryId,
        status: status ?? this.status,
        products: products ?? this.products,
        sort: sort ?? this.sort,
        filter: filter ?? this.filter,
        cartQty: cartQty ?? this.cartQty,
        error: error,
      );

  @override
  List<Object?> get props =>
      [categoryId, status, products, sort, filter, cartQty, error];
}

/// Loads a category's products and applies sort/filter; also mirrors the
/// cart so cards can morph Add → stepper.
class CategoryProductsCubit extends Cubit<CategoryProductsState> {
  CategoryProductsCubit(
    this._catalog,
    this._cart, {
    required String categoryId,
  }) : super(CategoryProductsState(categoryId: categoryId)) {
    _cartSub = _cart.watch().listen(_onCart);
  }

  final CatalogRepository _catalog;
  final CartRepository _cart;
  StreamSubscription<List<CartItem>>? _cartSub;

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading));
    final result = await _catalog.getProducts(categoryId: state.categoryId);
    if (isClosed) return;
    result.when(
      onSuccess: (products) =>
          emit(state.copyWith(status: LoadStatus.loaded, products: products)),
      onFailure: (message, _) =>
          emit(state.copyWith(status: LoadStatus.error, error: message)),
    );
  }

  void setSort(ProductSort sort) => emit(state.copyWith(sort: sort));

  void setFilter(ProductFilter filter) => emit(state.copyWith(filter: filter));

  /// Adds one unit; returns an error message (e.g. qty limit) or `null`.
  Future<String?> add(Product product) async {
    final result = await _cart.add(product);
    if (!isClosed && result.isSuccess) {
      _apply(result.dataOrNull ?? const []);
    }
    return result.errorMessageOrNull;
  }

  /// Changes a line's quantity (`0` removes it). Returns an error or `null`.
  Future<String?> setQty(String productId, int qty) async {
    final result = qty <= 0
        ? await _cart.remove(productId)
        : await _cart.updateQty(productId, qty);
    if (!isClosed && result.isSuccess) {
      _apply(result.dataOrNull ?? const []);
    }
    return result.errorMessageOrNull;
  }

  void _onCart(List<CartItem> items) {
    if (!isClosed) _apply(items);
  }

  void _apply(List<CartItem> items) {
    emit(
      state.copyWith(
        cartQty: {for (final item in items) item.productId: item.qty},
      ),
    );
  }

  @override
  Future<void> close() {
    _cartSub?.cancel();
    return super.close();
  }
}

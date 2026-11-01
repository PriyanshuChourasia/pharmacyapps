import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_models/shared_models.dart';

import 'home_state.dart';

/// Loads Home sections from the [CatalogRepository] and mirrors the cart
/// and the selected delivery address.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._catalog, this._cart, this._addresses)
    : super(HomeState(address: _addresses.selected)) {
    _cartSub = _cart.watch().listen((items) {
      if (!isClosed) {
        emit(
          state.copyWith(cartQty: {for (final i in items) i.productId: i.qty}),
        );
      }
    });
    _addressSub = _addresses.watchSelected().listen((address) {
      if (!isClosed && address != null) emit(state.copyWith(address: address));
    });
  }

  final CatalogRepository _catalog;
  final CartRepository _cart;
  final AddressRepository _addresses;
  late final StreamSubscription<List<CartItem>> _cartSub;
  late final StreamSubscription<Address?> _addressSub;

  static const int _dealCount = 6;
  static const int _popularCount = 8;

  List<Address> get addresses => _addresses.addresses;

  Future<void> load() async {
    emit(state.copyWith(status: HomeStatus.loading));
    final categories = await _catalog.getCategories();
    final products = await _catalog.getProducts();
    if (isClosed) return;

    final all = products.dataOrNull;
    final cats = categories.dataOrNull;
    if (all == null || cats == null) {
      emit(
        state.copyWith(
          status: HomeStatus.error,
          error: products.errorMessageOrNull ?? categories.errorMessageOrNull,
        ),
      );
      return;
    }

    final inStock = all.where((p) => p.inStock).toList();
    final deals = [...inStock]
      ..sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
    final dealList = deals.take(_dealCount).toList();
    final popular = inStock
        .where((p) => !dealList.contains(p))
        .take(_popularCount)
        .toList();
    final recommended = all
        .where((p) => !dealList.contains(p) && !popular.contains(p))
        .toList();

    emit(
      state.copyWith(
        status: HomeStatus.loaded,
        categories: cats,
        deals: dealList,
        popular: popular,
        recommended: recommended,
        brands: {for (final p in all) p.manufacturer}.toList(),
      ),
    );
  }

  Future<String?> add(Product product) async =>
      (await _cart.add(product)).errorMessageOrNull;

  Future<String?> setQty(String productId, int qty) async =>
      (await _cart.updateQty(productId, qty)).errorMessageOrNull;

  void selectAddress(String id) => _addresses.select(id);

  @override
  Future<void> close() {
    _cartSub.cancel();
    _addressSub.cancel();
    return super.close();
  }
}

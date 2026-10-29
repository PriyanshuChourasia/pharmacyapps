import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_models/shared_models.dart';

import 'load_status.dart';

/// State of the catalog search screen.
class SearchState extends Equatable {
  const SearchState({
    this.status = LoadStatus.initial,
    this.query = '',
    this.results = const [],
    this.cartQty = const {},
    this.error,
  });

  final LoadStatus status;

  /// The raw text currently in the field.
  final String query;

  /// Matches for the last executed (debounced) query.
  final List<Product> results;
  final Map<String, int> cartQty;
  final String? error;

  /// True when a search ran and found nothing (drives the empty state).
  bool get isEmpty => query.trim().isNotEmpty && results.isEmpty;

  SearchState copyWith({
    LoadStatus? status,
    String? query,
    List<Product>? results,
    Map<String, int>? cartQty,
    String? error,
  }) =>
      SearchState(
        status: status ?? this.status,
        query: query ?? this.query,
        results: results ?? this.results,
        cartQty: cartQty ?? this.cartQty,
        error: error,
      );

  @override
  List<Object?> get props => [status, query, results, cartQty, error];
}

/// Debounced (300 ms) search over brand, generic name and salt.
class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._catalog, this._cart) : super(const SearchState()) {
    _cartSub = _cart.watch().listen((items) {
      if (!isClosed) {
        emit(
          state.copyWith(
            cartQty: {for (final i in items) i.productId: i.qty},
          ),
        );
      }
    });
  }

  static const Duration debounce = Duration(milliseconds: 300);

  final CatalogRepository _catalog;
  final CartRepository _cart;
  Timer? _debounce;
  StreamSubscription<List<CartItem>>? _cartSub;

  /// Called on every keystroke; runs the query after [debounce] of quiet.
  void onQueryChanged(String query) {
    _debounce?.cancel();
    emit(state.copyWith(query: query, status: LoadStatus.loading));

    if (query.trim().isEmpty) {
      emit(state.copyWith(status: LoadStatus.loaded, results: const []));
      return;
    }
    _debounce = Timer(debounce, () => _run(query));
  }

  Future<void> _run(String query) async {
    final result = await _catalog.searchProducts(query);
    if (isClosed) return;
    result.when(
      onSuccess: (products) => emit(
        state.copyWith(status: LoadStatus.loaded, results: products),
      ),
      onFailure: (message, _) =>
          emit(state.copyWith(status: LoadStatus.error, error: message)),
    );
  }

  /// Sets a result's quantity (`0` removes it). Returns an error or `null`.
  Future<String?> setQty(String productId, int qty) async {
    final result = qty <= 0
        ? await _cart.remove(productId)
        : await _cart.updateQty(productId, qty);
    if (!isClosed && result.isSuccess) _applyCart(result.dataOrNull ?? const []);
    return result.errorMessageOrNull;
  }

  /// Adds one unit from a search result; returns an error message or `null`.
  Future<String?> add(Product product) async {
    final result = await _cart.add(product);
    if (!isClosed && result.isSuccess) _applyCart(result.dataOrNull);
    return result.errorMessageOrNull;
  }

  void _applyCart(List<CartItem>? items) {
    emit(
      state.copyWith(
        cartQty: {
          for (final item in items ?? const <CartItem>[])
            item.productId: item.qty,
        },
      ),
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    _cartSub?.cancel();
    return super.close();
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:core/core.dart';
import 'package:shared_models/shared_models.dart';

/// [CartRepository] persisted as JSON through a [KeyValueStore], so the cart
/// (and its coupon) survive app restarts. Call [load] once before use.
class PersistedCartRepository implements CartRepository {
  PersistedCartRepository(this._store);

  static const String storageKey = 'cart_v1';
  static const String couponKey = 'cart_coupon_v1';
  static const String limitMessage = 'You can add up to 10 of an item';

  final KeyValueStore _store;
  final StreamController<List<CartItem>> _changes =
      StreamController<List<CartItem>>.broadcast();
  List<CartItem> _items = const [];
  String? _couponCode;

  /// Restores the saved cart; corrupt JSON falls back to an empty cart.
  Future<void> load() async {
    try {
      final raw = await _store.read(storageKey);
      if (raw != null) {
        _items = List.unmodifiable(
          (jsonDecode(raw) as List<dynamic>).map(
            (e) => CartItem.fromJson(e as Map<String, dynamic>),
          ),
        );
      }
    } catch (_) {
      _items = const [];
    }
    _couponCode = await _store.read(couponKey);
  }

  @override
  List<CartItem> get items => _items;

  @override
  String? get couponCode => _couponCode;

  @override
  Stream<List<CartItem>> watch() async* {
    yield _items;
    yield* _changes.stream;
  }

  @override
  Future<Result<List<CartItem>>> add(Product product, {int qty = 1}) {
    final current = _qtyOf(product.id);
    if (current + qty > CartRepository.maxQuantityPerItem) {
      return Future.value(const Failure(limitMessage, code: 'qty_limit'));
    }
    if (current == 0) {
      return _save([..._items, CartItem(product: product, qty: qty)]);
    }
    return _save([
      for (final item in _items)
        item.productId == product.id ? item.copyWith(qty: current + qty) : item,
    ]);
  }

  @override
  Future<Result<List<CartItem>>> updateQty(String productId, int qty) {
    if (qty <= 0) return remove(productId);
    if (qty > CartRepository.maxQuantityPerItem) {
      return Future.value(const Failure(limitMessage, code: 'qty_limit'));
    }
    return _save([
      for (final item in _items)
        item.productId == productId ? item.copyWith(qty: qty) : item,
    ]);
  }

  @override
  Future<Result<List<CartItem>>> remove(String productId) =>
      _save(_items.where((i) => i.productId != productId).toList());

  @override
  Future<Result<List<CartItem>>> clear() async {
    await setCouponCode(null);
    return _save(const []);
  }

  @override
  Future<void> setCouponCode(String? code) async {
    _couponCode = code;
    if (code == null) {
      await _store.delete(couponKey);
    } else {
      await _store.write(couponKey, code);
    }
    _changes.add(_items);
  }

  int _qtyOf(String productId) {
    for (final item in _items) {
      if (item.productId == productId) return item.qty;
    }
    return 0;
  }

  Future<Result<List<CartItem>>> _save(List<CartItem> next) async {
    _items = List.unmodifiable(next);
    _changes.add(_items);
    final ok = await _store.write(
      storageKey,
      jsonEncode([for (final item in _items) item.toJson()]),
    );
    return ok
        ? Success(_items)
        : Failure<List<CartItem>>('Could not save your cart', code: 'io');
  }
}

import 'package:core/core.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import 'cart_repository.dart';

/// In-memory implementation of [CartRepository] for demo purposes.
/// Cart survives app restart because it's stored in get_it (will be replaced
/// by PersistedCartRepository in Phase 4).
class InMemoryCartRepository implements CartRepository {
  InMemoryCartRepository() : _items = [], _sub = const <CartItem>[].watch();

  final List<CartItem> _items;
  final StreamController<List<CartItem>> _controller = StreamController.broadcast();
  late final Stream<List<CartItem>> watch = _controller.stream;

  @override
  List<CartItem> get items => List.unmodifiable(_items);

  @override
  Future<Result<List<CartItem>>> add(Product product, {int qty = 1}) async {
    // Check limit
    final existing = _items.where((i) => i.productId == product.id).toList();
    if (existing.isNotEmpty && existing.first.qty + qty > CartRepository.maxQuantityPerItem) {
      return Result.failure('qty_limit', ['Quantity exceeds maximum of ${CartRepository.maxQuantityPerItem} per item']);
    }

    // increment existing or add new
    if (existing.isNotEmpty) {
      final updated = existing.first.copyWith(qty: existing.first.qty + qty);
      final idx = _items.indexOf(existing.first);
      _items[idx] = updated;
    } else {
      _items.add(CartItem(product: product, qty: qty));
    }
    _controller.sink.add(List.unmodifiable(_items));
    return Result.success(List.unmodifiable(_items));
  }

  @override
  Future<Result<List<CartItem>>> clear() async {
    _items.clear();
    _controller.sink.add(const <CartItem>[]);
    return Result.success(const <CartItem>[]);
  }

  @override
  Future<Result<List<CartItem>>> remove(String productId) async {
    final before = _items.length;
    _items.removeWhere((i) => i.productId == productId);
    if (_items.length < before) _controller.sink.add(List.unmodifiable(_items));
    return Result.success(items);
  }

  @override
  Future<Result<List<CartItem>>> updateQty(String productId, int qty) async {
    if (qty <= 0) return remove(productId);

    final existing = _items.where((i) => i.productId == productId).toList();
    if (existing.isEmpty) return Result.failure('not_found', ['Item not in cart']);

    if (existing.first.qty + (qty - existing.first.qty) > CartRepository.maxQuantityPerItem) {
      return Result.failure('qty_limit', ['Quantity exceeds maximum of ${CartRepository.maxQuantityPerItem} per item']);
    }

    final idx = _items.indexOf(existing.first);
    _items[idx] = existing.first.copyWith(qty: qty);
    _controller.sink.add(List.unmodifiable(_items));
    return Result.success(items);
  }

  @override
  Stream<List<CartItem>> watch() => watch;
}
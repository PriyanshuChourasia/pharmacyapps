import 'package:core/core.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

/// Cross-feature cart contract.
///
/// Implemented by `feature_cart` (persisted via `KeyValueStore`);
/// consumed by home, catalog, cart and checkout through the app's DI —
/// features never import each other.
abstract interface class CartRepository {
  /// Maximum quantity of a single line item.
  static const int maxQuantityPerItem = 10;

  /// Current snapshot, for immediate synchronous reads (badge, checkout).
  List<CartItem> get items;

  /// Emits the full cart on every change.
  Stream<List<CartItem>> watch();

  /// Adds [qty] of [product] (or increments its line).
  Future<Result<List<CartItem>>> add(Product product, {int qty = 1});

  /// Sets the quantity of [productId]; `0` removes the line.
  /// Fails with code `qty_limit` beyond [maxQuantityPerItem].
  Future<Result<List<CartItem>>> updateQty(String productId, int qty);

  /// Removes [productId]'s line.
  Future<Result<List<CartItem>>> remove(String productId);

  /// Empties the cart (used on successful order placement).
  Future<Result<List<CartItem>>> clear();
}

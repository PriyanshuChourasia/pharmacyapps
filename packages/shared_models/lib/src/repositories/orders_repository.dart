import 'package:core/core.dart';

import '../models/order.dart';

/// Placed orders, shared by checkout (writes) and orders (reads).
abstract interface class OrdersRepository {
  /// Stores a newly placed [order].
  Future<Result<Order>> place(Order order);

  /// All orders, newest first.
  Future<Result<List<Order>>> getOrders();

  /// A single order, or `null` when the id is unknown.
  Future<Result<Order?>> getOrder(String id);

  /// Emits the full list (newest first) now and on every change.
  Stream<List<Order>> watch();
}

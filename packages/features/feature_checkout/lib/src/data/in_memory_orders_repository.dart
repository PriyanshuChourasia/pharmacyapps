import 'dart:async';

import 'package:core/core.dart';
import 'package:shared_models/shared_models.dart';

/// [OrdersRepository] kept in memory for the app run (newest first).
class InMemoryOrdersRepository implements OrdersRepository {
  final List<Order> _orders = [];
  final StreamController<List<Order>> _changes =
      StreamController<List<Order>>.broadcast();

  List<Order> get _snapshot => List.unmodifiable(_orders);

  @override
  Future<Result<Order>> place(Order order) async {
    _orders.insert(0, order);
    _changes.add(_snapshot);
    return Success(order);
  }

  @override
  Future<Result<List<Order>>> getOrders() async => Success(_snapshot);

  @override
  Future<Result<Order?>> getOrder(String id) async =>
      Success(_orders.where((o) => o.id == id).firstOrNull);

  @override
  Stream<List<Order>> watch() async* {
    yield _snapshot;
    yield* _changes.stream;
  }
}

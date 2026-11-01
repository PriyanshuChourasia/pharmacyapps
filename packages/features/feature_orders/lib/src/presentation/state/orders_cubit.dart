import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_models/shared_models.dart';

class OrdersState extends Equatable {
  const OrdersState({this.loading = true, this.orders = const []});

  final bool loading;

  /// Newest first.
  final List<Order> orders;

  @override
  List<Object?> get props => [loading, orders];
}

/// Watches the [OrdersRepository]; also re-adds an order's items to the cart.
class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._orders, this._cart) : super(const OrdersState()) {
    _sub = _orders.watch().listen((orders) {
      if (!isClosed) emit(OrdersState(loading: false, orders: orders));
    });
  }

  final OrdersRepository _orders;
  final CartRepository _cart;
  late final StreamSubscription<List<Order>> _sub;

  /// Adds every line of [order] to the cart; returns a user message.
  Future<String> reorder(Order order) => reorderInto(_cart, order);

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}

/// Shared by the list and the detail page.
Future<String> reorderInto(CartRepository cart, Order order) async {
  var skipped = 0;
  for (final item in order.items) {
    final result = await cart.add(item.product, qty: item.qty);
    if (result.isFailure) skipped++;
  }
  return skipped == 0
      ? 'Items added to cart'
      : 'Items added to cart ($skipped hit the 10-per-item limit)';
}

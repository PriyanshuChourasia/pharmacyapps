import 'package:equatable/equatable.dart';

import 'address.dart';
import 'cart_item.dart';
import 'price_breakdown.dart';

/// Payment method chosen at checkout.
enum PaymentMethod {
  cod('Cash on Delivery'),
  upi('UPI (demo)');

  const PaymentMethod(this.label);
  final String label;
}

/// Status of a placed order (demo scope: only "Placed").
enum OrderStatus {
  placed('Placed');

  const OrderStatus(this.label);
  final String label;
}

/// An order placed in this session. Kept in memory by the orders feature.
class Order extends Equatable {
  const Order({
    required this.id,
    required this.items,
    required this.address,
    required this.slot,
    required this.paymentMethod,
    required this.breakdown,
    required this.createdAt,
    this.status = OrderStatus.placed,
  });

  /// Order id, e.g. `PM1730000000000`.
  final String id;

  /// The ordered lines (product snapshot + quantity).
  final List<CartItem> items;

  final Address address;

  /// Delivery slot label, e.g. `Today · Morning`.
  final String slot;

  final PaymentMethod paymentMethod;

  final PriceBreakdown breakdown;

  final DateTime createdAt;

  final OrderStatus status;

  /// Total number of units across all lines.
  int get itemCount => items.fold(0, (sum, item) => sum + item.qty);

  @override
  List<Object?> get props => [
        id,
        items,
        address,
        slot,
        paymentMethod,
        breakdown,
        createdAt,
        status,
      ];
}

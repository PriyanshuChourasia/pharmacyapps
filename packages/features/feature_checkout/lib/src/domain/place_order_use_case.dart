import 'package:core/core.dart';
import 'package:shared_models/shared_models.dart';

import 'delivery_slot.dart';

/// Domain rule for placing an order. Rx items without a prescription are
/// rejected here, so a disabled button is never the only guard.
class PlaceOrderUseCase {
  PlaceOrderUseCase({
    required CartRepository cart,
    required OrdersRepository orders,
    required AddressRepository addresses,
    required PaymentGateway payment,
    PricingCalculator pricing = const PricingCalculator(),
  }) : _cart = cart,
       _orders = orders,
       _addresses = addresses,
       _payment = payment,
       _pricing = pricing;

  final CartRepository _cart;
  final OrdersRepository _orders;
  final AddressRepository _addresses;
  final PaymentGateway _payment;
  final PricingCalculator _pricing;

  /// Checks the order can be placed; `null` when it can.
  Failure<Order>? validate({required bool prescriptionAttached}) {
    final items = _cart.items;
    if (items.isEmpty) {
      return const Failure('Your cart is empty', code: 'empty_cart');
    }
    if (!prescriptionAttached &&
        items.any((i) => i.product.requiresPrescription)) {
      return const Failure(
        'Please upload a prescription for Rx medicines',
        code: 'prescription_required',
      );
    }
    if (_addresses.selected == null) {
      return const Failure(
        'Please choose a delivery address',
        code: 'no_address',
      );
    }
    return null;
  }

  Future<Result<Order>> call({
    required bool prescriptionAttached,
    required DeliverySlot slot,
    required PaymentMethod method,
  }) async {
    final invalid = validate(prescriptionAttached: prescriptionAttached);
    if (invalid != null) return invalid;

    final items = _cart.items;
    final breakdown = _pricing.calculate(items, couponCode: _cart.couponCode);
    final orderId = 'PM${DateTime.now().millisecondsSinceEpoch}';

    final payment = await _payment.pay(
      amountPaise: breakdown.payable,
      orderId: orderId,
      method: method.name,
    );
    if (payment case Failure(:final message)) {
      return Failure(message, code: 'payment_failed');
    }

    final order = Order(
      id: orderId,
      items: items,
      address: _addresses.selected!,
      slot: slot.label,
      paymentMethod: method,
      breakdown: breakdown,
      createdAt: DateTime.now(),
    );
    final placed = await _orders.place(order);
    if (placed.isSuccess) await _cart.clear();
    return placed;
  }
}

import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_models/shared_models.dart';

import '../../domain/delivery_slot.dart';
import '../../domain/place_order_use_case.dart';
import 'checkout_state.dart';

/// Drives the checkout page; [placeOrder] delegates to [PlaceOrderUseCase].
class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit({
    required CartRepository cart,
    required AddressRepository addresses,
    required PlaceOrderUseCase placeOrderUseCase,
    PricingCalculator pricing = const PricingCalculator(),
  }) : _cart = cart,
       _addresses = addresses,
       _placeOrder = placeOrderUseCase,
       _pricing = pricing,
       super(const CheckoutState()) {
    _cartSub = _cart.watch().listen(_onCart);
    _addressSub = _addresses.watchSelected().listen(_onAddress);
  }

  final CartRepository _cart;
  final AddressRepository _addresses;
  final PlaceOrderUseCase _placeOrder;
  final PricingCalculator _pricing;
  late final StreamSubscription<List<CartItem>> _cartSub;
  late final StreamSubscription<Address?> _addressSub;

  void _onCart(List<CartItem> items) {
    // Keep the summary visible while the placed order clears the cart.
    if (isClosed || state.placing) return;
    emit(
      state.copyWith(
        items: items,
        breakdown: _pricing.calculate(items, couponCode: _cart.couponCode),
      ),
    );
  }

  void _onAddress(Address? selected) {
    if (isClosed) return;
    emit(
      state.copyWith(
        addresses: _addresses.addresses,
        selectedAddressId: selected?.id,
      ),
    );
  }

  void selectAddress(String id) => _addresses.select(id);

  void selectDay(SlotDay day) => emit(state.copyWith(slotDay: day));

  void selectTime(SlotTime time) => emit(state.copyWith(slotTime: time));

  void selectPayment(PaymentMethod method) =>
      emit(state.copyWith(paymentMethod: method));

  void attachPrescription() => emit(state.copyWith(prescriptionAttached: true));

  void removePrescription() =>
      emit(state.copyWith(prescriptionAttached: false));

  /// Pre-flight check (before asking a guest to log in).
  Failure<Order>? validate() =>
      _placeOrder.validate(prescriptionAttached: state.prescriptionAttached);

  Future<Result<Order>> placeOrder() async {
    if (state.placing) {
      return const Failure('Already placing your order', code: 'busy');
    }
    emit(state.copyWith(placing: true));
    final result = await _placeOrder(
      prescriptionAttached: state.prescriptionAttached,
      slot: state.slot,
      method: state.paymentMethod,
    );
    if (!isClosed && result.isFailure) emit(state.copyWith(placing: false));
    return result;
  }

  @override
  Future<void> close() {
    _cartSub.cancel();
    _addressSub.cancel();
    return super.close();
  }
}

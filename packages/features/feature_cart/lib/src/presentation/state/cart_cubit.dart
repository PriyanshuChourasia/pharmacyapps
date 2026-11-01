import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_models/shared_models.dart';

import 'cart_state.dart';

/// Mirrors the [CartRepository] and recomputes the bill (with the coupon)
/// through [PricingCalculator] on every change.
class CartCubit extends Cubit<CartState> {
  CartCubit(
    this._repository, {
    PricingCalculator pricing = const PricingCalculator(),
  }) : _pricing = pricing,
       super(const CartState()) {
    _sub = _repository.watch().listen(_recompute);
  }

  final CartRepository _repository;
  final PricingCalculator _pricing;
  late final StreamSubscription<List<CartItem>> _sub;

  void _recompute(List<CartItem> items) {
    if (isClosed) return;
    final code = _repository.couponCode;
    final breakdown = _pricing.calculate(items, couponCode: code);
    String? error;
    if (code != null && breakdown.couponCode == null && items.isNotEmpty) {
      error = _pricing.validateCoupon(code, breakdown.sellingTotal).error;
    }
    emit(
      state.copyWith(
        items: items,
        breakdown: breakdown,
        couponCode: () => code,
        couponError: () => error,
      ),
    );
  }

  Future<void> setQty(String productId, int qty) async {
    final result = await _repository.updateQty(productId, qty);
    final message = result.errorMessageOrNull;
    if (message != null && !isClosed) {
      emit(state.copyWith(limitMessage: () => message));
    }
  }

  /// Removes a line and returns it so the page can offer "Undo".
  Future<CartItem?> remove(String productId) async {
    final removed = state.items
        .where((i) => i.productId == productId)
        .firstOrNull;
    await _repository.remove(productId);
    return removed;
  }

  Future<void> undoRemove(CartItem item) =>
      _repository.add(item.product, qty: item.qty);

  Future<void> applyCoupon(String code) async {
    final result = _pricing.validateCoupon(code, state.breakdown.sellingTotal);
    if (!result.isValid) {
      emit(state.copyWith(couponError: () => result.error));
      return;
    }
    await _repository.setCouponCode(result.code);
  }

  Future<void> removeCoupon() => _repository.setCouponCode(null);

  void clearLimitMessage() => emit(state.copyWith(limitMessage: () => null));

  /// Extra amount needed for free delivery (0 when already free).
  int get amountForFreeDelivery =>
      _pricing.amountForFreeDelivery(state.breakdown);

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}

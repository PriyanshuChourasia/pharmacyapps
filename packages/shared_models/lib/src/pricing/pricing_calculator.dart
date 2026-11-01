import 'package:equatable/equatable.dart';

import '../models/cart_item.dart';
import '../models/money.dart';
import '../models/price_breakdown.dart';

/// Outcome of validating a coupon code against a selling total.
class CouponResult extends Equatable {
  const CouponResult.valid(this.code, this.discount) : error = null;

  const CouponResult.invalid(this.error) : code = null, discount = 0;

  /// Normalised (upper-case) code when valid.
  final String? code;

  /// Discount in paise.
  final int discount;
  final String? error;

  bool get isValid => error == null;

  @override
  List<Object?> get props => [code, discount, error];
}

/// A demo coupon shown in the cart suggestions and the profile offers sheet.
class CouponInfo {
  const CouponInfo(this.code, this.title, this.rule);

  final String code;
  final String title;
  final String rule;
}

/// Pure pricing rules for the cart, checkout and orders. Integer paise only.
class PricingCalculator {
  const PricingCalculator();

  /// Delivery is free when the payable (before delivery) is above this.
  static const int freeDeliveryAbove = 49900;
  static const int deliveryFee = 4000;

  static const int _pharma10Cap = 10000;
  static const int _first50Off = 5000;
  static const int _first50Min = 30000;

  static const List<CouponInfo> coupons = [
    CouponInfo('PHARMA10', '10% off up to ₹100', 'Valid on all orders.'),
    CouponInfo('FIRST50', '₹50 off on ₹300+', 'Minimum order value ₹300.'),
  ];

  CouponResult validateCoupon(String code, int sellingTotal) {
    final normalised = code.trim().toUpperCase();
    switch (normalised) {
      case '':
        return const CouponResult.invalid('Enter a coupon code');
      case 'PHARMA10':
        final off = Money.percentOf(sellingTotal, 10);
        return CouponResult.valid(
          normalised,
          off > _pharma10Cap ? _pharma10Cap : off,
        );
      case 'FIRST50':
        if (sellingTotal < _first50Min) {
          return CouponResult.invalid(
            'Add ${Money.format(_first50Min - sellingTotal)} more to use FIRST50',
          );
        }
        return const CouponResult.valid('FIRST50', _first50Off);
      default:
        return CouponResult.invalid('"$normalised" is not a valid coupon');
    }
  }

  /// Full bill for [items]. An invalid [couponCode] is ignored (the
  /// breakdown's `couponCode` is then `null`).
  PriceBreakdown calculate(List<CartItem> items, {String? couponCode}) {
    if (items.isEmpty) return const PriceBreakdown.empty();
    final mrpTotal = items.fold(0, (sum, i) => sum + i.lineMrpTotal);
    final sellingTotal = items.fold(0, (sum, i) => sum + i.lineTotal);
    final coupon = couponCode == null
        ? null
        : validateCoupon(couponCode, sellingTotal);
    final couponDiscount = coupon != null && coupon.isValid
        ? coupon.discount
        : 0;
    final beforeDelivery = sellingTotal - couponDiscount;
    final delivery = beforeDelivery > freeDeliveryAbove ? 0 : deliveryFee;
    return PriceBreakdown(
      itemMrpTotal: mrpTotal,
      sellingTotal: sellingTotal,
      discount: mrpTotal - sellingTotal,
      couponDiscount: couponDiscount,
      deliveryFee: delivery,
      payable: beforeDelivery + delivery,
      couponCode: coupon != null && coupon.isValid ? coupon.code : null,
    );
  }

  /// How much more must be added for free delivery (0 when already free).
  int amountForFreeDelivery(PriceBreakdown breakdown) {
    if (breakdown.deliveryFee == 0) return 0;
    final beforeDelivery = breakdown.payable - breakdown.deliveryFee;
    return freeDeliveryAbove + 100 - beforeDelivery;
  }
}

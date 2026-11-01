import 'package:equatable/equatable.dart';
import 'package:shared_models/shared_models.dart';

/// State of the cart page.
class CartState extends Equatable {
  const CartState({
    this.items = const [],
    this.breakdown = const PriceBreakdown.empty(),
    this.couponCode,
    this.couponError,
    this.limitMessage,
  });

  final List<CartItem> items;
  final PriceBreakdown breakdown;

  /// Coupon the user entered (may be stored but not currently applicable).
  final String? couponCode;
  final String? couponError;

  /// One-shot message (quantity limit, save error) shown as a snackbar.
  final String? limitMessage;

  bool get isEmpty => items.isEmpty;

  /// Total units in the cart.
  int get unitCount => items.fold(0, (sum, i) => sum + i.qty);

  /// Number of lines that need a prescription.
  int get rxCount => items.where((i) => i.product.requiresPrescription).length;

  /// Applied coupon (valid for the current total), or `null`.
  String? get appliedCoupon => breakdown.couponCode;

  /// Total savings: MRP discount + coupon.
  int get totalSavings => breakdown.discount + breakdown.couponDiscount;

  CartState copyWith({
    List<CartItem>? items,
    PriceBreakdown? breakdown,
    String? Function()? couponCode,
    String? Function()? couponError,
    String? Function()? limitMessage,
  }) => CartState(
    items: items ?? this.items,
    breakdown: breakdown ?? this.breakdown,
    couponCode: couponCode != null ? couponCode() : this.couponCode,
    couponError: couponError != null ? couponError() : this.couponError,
    limitMessage: limitMessage != null ? limitMessage() : this.limitMessage,
  );

  @override
  List<Object?> get props => [
    items,
    breakdown,
    couponCode,
    couponError,
    limitMessage,
  ];
}

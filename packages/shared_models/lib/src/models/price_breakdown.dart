import 'package:equatable/equatable.dart';

/// Price breakdown shown in the cart, checkout and order detail.
/// All amounts are integer paise. Computation lives in the cart feature's
/// pricing use case (unit-tested there); this is the shared shape.
class PriceBreakdown extends Equatable {
  const PriceBreakdown({
    required this.itemMrpTotal,
    required this.sellingTotal,
    required this.discount,
    required this.couponDiscount,
    required this.deliveryFee,
    required this.payable,
    this.couponCode,
  });

  /// A zeroed breakdown (empty cart).
  const PriceBreakdown.empty()
      : itemMrpTotal = 0,
        sellingTotal = 0,
        discount = 0,
        couponDiscount = 0,
        deliveryFee = 0,
        payable = 0,
        couponCode = null;

  /// Sum of MRP × qty, in paise.
  final int itemMrpTotal;

  /// Sum of selling price × qty, in paise.
  final int sellingTotal;

  /// MRP savings (itemMrpTotal − sellingTotal), in paise.
  final int discount;

  /// Coupon savings (after caps), in paise.
  final int couponDiscount;

  /// Delivery fee: free above the threshold, otherwise a flat fee.
  final int deliveryFee;

  /// Amount payable: sellingTotal − couponDiscount + deliveryFee, in paise.
  final int payable;

  /// Applied coupon code, if any.
  final String? couponCode;

  @override
  List<Object?> get props => [
        itemMrpTotal,
        sellingTotal,
        discount,
        couponDiscount,
        deliveryFee,
        payable,
        couponCode,
      ];
}

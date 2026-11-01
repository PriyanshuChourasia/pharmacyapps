import 'package:core/core.dart';

/// Demo [PaymentGateway]: COD succeeds immediately, UPI after 1.5 s. No money
/// moves and no network call is made.
class DemoPaymentGateway implements PaymentGateway {
  static const Duration upiDelay = Duration(milliseconds: 1500);

  @override
  Future<Result<PaymentReceipt>> pay({
    required int amountPaise,
    required String orderId,
    required String method,
  }) async {
    if (method == 'upi') await Future<void>.delayed(upiDelay);
    final now = DateTime.now();
    return Success(
      PaymentReceipt(
        transactionId: 'TXN${now.millisecondsSinceEpoch}',
        method: method,
        paidAt: now,
      ),
    );
  }
}

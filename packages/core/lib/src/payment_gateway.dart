import 'result.dart';

/// Swappable payment provider. The demo implementation (`DemoPaymentGateway`)
/// lives in `feature_checkout`; a real gateway (e.g. Razorpay) only needs a
/// new implementation plus a DI change.
abstract interface class PaymentGateway {
  /// Charges [amountPaise] for [orderId] using the given [method]
  /// (see `PaymentMethod.name`, e.g. `cod` or `upi`).
  Future<Result<PaymentReceipt>> pay({
    required int amountPaise,
    required String orderId,
    required String method,
  });
}

/// Receipt returned by a successful payment.
class PaymentReceipt {
  const PaymentReceipt({
    required this.transactionId,
    required this.method,
    required this.paidAt,
  });

  final String transactionId;
  final String method;
  final DateTime paidAt;
}

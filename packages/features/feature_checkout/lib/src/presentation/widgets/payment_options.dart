import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

/// Cash on Delivery / UPI (demo) radio tiles.
class PaymentOptions extends StatelessWidget {
  const PaymentOptions({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioGroup<PaymentMethod>(
      groupValue: selected,
      onChanged: (m) {
        if (m != null) onChanged(m);
      },
      child: Column(
        children: [
          RadioListTile<PaymentMethod>(
            value: PaymentMethod.cod,
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.payments_outlined),
            title: Text(PaymentMethod.cod.label),
            subtitle: const Text('Pay in cash or UPI when it arrives'),
          ),
          RadioListTile<PaymentMethod>(
            value: PaymentMethod.upi,
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.qr_code_2),
            title: Text(PaymentMethod.upi.label),
            subtitle: const Text('Simulated payment, no money is charged'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Small red "Rx" chip shown on products that require a prescription.
class RxBadge extends StatelessWidget {
  const RxBadge({super.key, this.label = 'Rx'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.rx,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.2,
        ),
      ),
    );
  }
}

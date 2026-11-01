import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Amber notice: some cart lines need a prescription.
class RxBanner extends StatelessWidget {
  const RxBanner({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFF4E0),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm + 4),
        child: Row(
          children: [
            const Icon(Icons.description_outlined, color: AppColors.warning),
            const SizedBox(width: AppSpacing.sm + 4),
            Expanded(
              child: Text(
                'Prescription required for $count item${count == 1 ? '' : 's'}. '
                'You can upload it at checkout.',
                style: const TextStyle(fontSize: 13, height: 1.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

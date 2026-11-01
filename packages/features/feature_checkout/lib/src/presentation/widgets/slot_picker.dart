import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/delivery_slot.dart';

/// Day (Today / Tomorrow) and time-window chips.
class SlotPicker extends StatelessWidget {
  const SlotPicker({
    super.key,
    required this.day,
    required this.time,
    required this.onDay,
    required this.onTime,
  });

  final SlotDay day;
  final SlotTime time;
  final ValueChanged<SlotDay> onDay;
  final ValueChanged<SlotTime> onTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            for (final d in SlotDay.values)
              ChoiceChip(
                label: Text(DeliverySlot.dayLabel(d)),
                selected: d == day,
                onSelected: (_) => onDay(d),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            for (final t in SlotTime.values)
              ChoiceChip(
                avatar: Icon(
                  t == SlotTime.morning
                      ? Icons.wb_sunny_outlined
                      : Icons.nights_stay_outlined,
                  size: 18,
                ),
                label: Text('${t.label} ${t.hours}'),
                selected: t == time,
                onSelected: (_) => onTime(t),
              ),
          ],
        ),
      ],
    );
  }
}

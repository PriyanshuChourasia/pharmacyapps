import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_models/shared_models.dart';

/// Bottom sheet listing the saved addresses as radio tiles.
Future<void> showAddressSelectorSheet(
  BuildContext context, {
  required List<Address> addresses,
  required String? selectedId,
  required ValueChanged<String> onSelect,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: RadioGroup<String>(
        groupValue: selectedId,
        onChanged: (id) {
          if (id != null) onSelect(id);
          Navigator.pop(sheetContext);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Text(
                'Choose a delivery address',
                style: AppTypography.sectionTitle,
              ),
            ),
            for (final a in addresses)
              RadioListTile<String>(
                value: a.id,
                title: Text(a.fullName),
                subtitle: Text('${a.summary}\n${a.phone}'),
                isThreeLine: true,
              ),
            ListTile(
              leading: const Icon(Icons.add, color: AppColors.primary),
              title: const Text(
                'Add new address',
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                context.push(RoutePaths.addAddress);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

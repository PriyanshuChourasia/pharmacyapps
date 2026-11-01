import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Mock prescription upload: a sheet with camera/gallery that just marks
/// the prescription attached.
class PrescriptionSection extends StatelessWidget {
  const PrescriptionSection({
    super.key,
    required this.rxCount,
    required this.attached,
    required this.onAttach,
    required this.onRemove,
  });

  final int rxCount;
  final bool attached;
  final VoidCallback onAttach;
  final VoidCallback onRemove;

  void _pick(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (icon, label) in const [
              (Icons.photo_camera_outlined, 'Take photo'),
              (Icons.photo_library_outlined, 'Choose from gallery'),
            ])
              ListTile(
                leading: Icon(icon, color: AppColors.primary),
                title: Text(label),
                onTap: () {
                  Navigator.pop(sheetContext);
                  onAttach();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$rxCount item${rxCount == 1 ? '' : 's'} in your cart need'
          '${rxCount == 1 ? 's' : ''} a valid prescription',
          style: AppTypography.bodySecondary,
        ),
        const SizedBox(height: AppSpacing.sm + 4),
        if (!attached)
          OutlinedButton.icon(
            onPressed: () => _pick(context),
            icon: const Icon(Icons.upload_file_outlined),
            label: const Text('Upload prescription'),
          )
        else
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: AppColors.textSecondary,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppSpacing.sm + 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'prescription_demo.jpg',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Chip(
                      avatar: const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 18,
                      ),
                      label: const Text('Attached'),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: AppColors.success.withValues(alpha: 0.1),
                      side: BorderSide.none,
                    ),
                  ],
                ),
              ),
              TextButton(onPressed: onRemove, child: const Text('Remove')),
            ],
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Renders a bundled asset image with `Image.asset`.
///
/// When [assetPath] is null/empty or fails to load, falls back to a colored
/// rounded box showing [icon] (the category icon) and the product's first
/// letter ([letter]) — never an error, never a network request.
class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.assetPath,
    required this.icon,
    required this.letter,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(AppSpacing.radiusMd),
    ),
    this.fallbackColor = AppColors.primaryLight,
  });

  /// Bundled asset path (e.g. `assets/images/products/tablet_strip.jpg`),
  /// or `null` to force the placeholder.
  final String? assetPath;

  /// Category icon shown in the placeholder.
  final IconData icon;

  /// Product's first letter shown in the placeholder.
  final String letter;

  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final Color fallbackColor;

  @override
  Widget build(BuildContext context) {
    final placeholder = _buildPlaceholder();

    final path = assetPath;
    if (path == null || path.isEmpty) return placeholder;

    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => placeholder,
      ),
    );
  }

  Widget _buildPlaceholder() {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22, color: AppColors.primaryDark),
        const SizedBox(height: AppSpacing.xs),
        Text(
          letter.isEmpty ? '?' : letter[0].toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: fallbackColor,
        borderRadius: borderRadius,
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: content,
        ),
      ),
    );
  }
}

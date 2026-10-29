import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Visual variant of [AppButton].
enum AppButtonVariant {
  /// Solid teal — the primary action on a screen.
  primary,

  /// Tonal teal — a secondary action.
  secondary,

  /// Text-only — low-emphasis actions.
  ghost,
}

/// The app's standard button: primary/secondary/ghost variants, optional
/// leading icon, optional loading state (which also disables taps).
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expanded = true,
  });

  /// Button text.
  final String label;

  /// Called when tapped; `null` disables the button.
  final VoidCallback? onPressed;

  final AppButtonVariant variant;

  /// Optional leading icon.
  final IconData? icon;

  /// Shows a spinner instead of the label and blocks taps.
  final bool loading;

  /// Stretches the button to the available width.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;

    final Widget child = loading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                  Text(label),
                ],
              )
            : Text(label);

    final ButtonStyle style;
    final Widget button;
    switch (variant) {
      case AppButtonVariant.primary:
        style = FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        );
        button = FilledButton(
          style: style,
          onPressed: enabled ? onPressed : null,
          child: child,
        );
      case AppButtonVariant.secondary:
        style = FilledButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.primaryDark,
          minimumSize: const Size(0, 48),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        );
        button = FilledButton(
          style: style,
          onPressed: enabled ? onPressed : null,
          child: child,
        );
      case AppButtonVariant.ghost:
        style = TextButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          minimumSize: const Size(0, 48),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        );
        button = TextButton(
          style: style,
          onPressed: enabled ? onPressed : null,
          child: child,
        );
    }

    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

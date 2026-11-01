import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Shows [message] as a floating snackbar (no-op for `null`). Used for cart
/// errors such as the quantity limit and for "coming soon" taps.
void showAppSnackBar(
  BuildContext context,
  String? message, {
  bool error = false,
  SnackBarAction? action,
}) {
  if (message == null || !context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? AppColors.danger : null,
        action: action,
      ),
    );
}

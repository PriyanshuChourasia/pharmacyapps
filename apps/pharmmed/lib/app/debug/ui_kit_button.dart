import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Debug-only button shown on the Profile tab that opens the UI-kit page.
///
/// Only rendered in debug mode (`kDebugMode`); the route itself is also
/// debug-only, so release builds never expose it.
class UiKitButton extends StatelessWidget {
  const UiKitButton({super.key, required this.onOpen});

  /// Navigates to the UI-kit page (typically `context.push(RoutePaths.uiKit)`).
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    return Center(
      child: TextButton.icon(
        onPressed: onOpen,
        icon: const Icon(Icons.widgets_outlined, size: 18),
        label: const Text('UI kit (debug)'),
      ),
    );
  }
}

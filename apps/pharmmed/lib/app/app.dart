import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'package:pharmmed/app/router/app_router.dart';

/// Root widget: `MaterialApp.router` with the design-system theme and the
/// go_router shell (bottom nav + top-level routes).
class PharmmedApp extends StatefulWidget {
  const PharmmedApp({super.key});

  @override
  State<PharmmedApp> createState() => _PharmmedAppState();
}

class _PharmmedAppState extends State<PharmmedApp> {
  late final _router = buildAppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PharmMed',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: _router,
    );
  }
}

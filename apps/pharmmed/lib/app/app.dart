import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'package:dawaidukaan/app/router/app_router.dart';
import 'package:dawaidukaan/app/services/location_permission_service.dart';
import 'package:dawaidukaan/app/widgets/location_permission_gate.dart';

/// Root widget: `MaterialApp.router` with the design-system theme and the
/// go_router shell (bottom nav + top-level routes).
///
/// Before the app shell is shown, [LocationPermissionGate] checks location
/// permission on first load and asks the user for it when it has not been
/// granted yet.
class PharmmedApp extends StatefulWidget {
  const PharmmedApp({super.key});

  @override
  State<PharmmedApp> createState() => _PharmmedAppState();
}

class _PharmmedAppState extends State<PharmmedApp> {
  late final _router = buildAppRouter();
  late final _locationService = LocationPermissionService();

  @override
  Widget build(BuildContext context) {
    return LocationPermissionGate(
      service: _locationService,
      child: MaterialApp.router(
        title: 'Dawaidukaan',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        routerConfig: _router,
      ),
    );
  }
}

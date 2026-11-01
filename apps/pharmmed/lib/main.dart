import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dawaidukaan/app/app.dart';
import 'package:dawaidukaan/app/di/injector.dart';

/// Entry point: wires up dependency injection (restoring the saved cart),
/// then runs the app shell.
///
/// The app opens on the splash, which routes to Home (signed in) or Login.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Draw behind the status and navigation bars so full-bleed screens (splash,
  // login header) cover the whole display.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await configureDependencies();
  runApp(const PharmmedApp());
}

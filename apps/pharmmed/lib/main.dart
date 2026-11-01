import 'package:flutter/material.dart';

import 'package:dawaidukaan/app/app.dart';
import 'package:dawaidukaan/app/di/injector.dart';

/// Entry point: wires up dependency injection (restoring the saved cart),
/// then runs the app shell.
///
/// The app opens on Home — there is no splash-to-login redirect. Login is
/// requested only from checkout ("Place order") or the Profile tab.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const PharmmedApp());
}

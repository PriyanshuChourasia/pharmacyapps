import 'package:flutter/material.dart';

import 'package:pharmmed/app/app.dart';
import 'package:pharmmed/app/di/injector.dart';

/// Entry point: wires up dependency injection, then runs the app shell.
///
/// The app opens on Home — there is no splash-to-login redirect. Login is
/// requested only from checkout ("Place order").
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const PharmmedApp());
}

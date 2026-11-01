import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dawaidukaan/app/app.dart';
import 'package:dawaidukaan/app/di/injector.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();
  });

  testWidgets('launches on Home and switches between all five tabs', (
    tester,
  ) async {
    await tester.pumpWidget(const PharmmedApp());
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('PharmMed'), findsOneWidget);
    expect(find.text('Log in to place your order'), findsNothing);

    for (final tab in ['Categories', 'Cart', 'Orders', 'Profile', 'Home']) {
      await tester.tap(find.text(tab).last);
      await tester.pump(const Duration(seconds: 1));
    }
    expect(find.text('Shop by category'), findsOneWidget);
  });
}
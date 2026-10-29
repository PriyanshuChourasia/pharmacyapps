import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pharmmed/app/app.dart';

void main() {
  testWidgets('launches on Home without a login screen', (tester) async {
    await tester.pumpWidget(const PharmmedApp());
    await tester.pumpAndSettle();

    // Home is the initial tab.
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsWidgets);

    // No sign-in gate on launch.
    expect(find.text('Sign in'), findsNothing);
    expect(find.text('Welcome back'), findsNothing);
    expect(find.text('Create your account'), findsNothing);
  });

  testWidgets('switches between all five tabs', (tester) async {
    await tester.pumpWidget(const PharmmedApp());
    await tester.pumpAndSettle();

    for (final tab in ['Categories', 'Cart', 'Orders', 'Profile']) {
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();
      expect(find.text(tab), findsWidgets, reason: '$tab tab not visible');
    }

    // Tapping Home returns to the first tab.
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsWidgets);
  });
}

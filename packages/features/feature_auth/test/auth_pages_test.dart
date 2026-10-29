import 'package:feature_auth/feature_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpAuthFlow(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AuthFlow()));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the login page by default', (tester) async {
    await pumpAuthFlow(tester);

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(RegistrationPage), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
  });

  testWidgets('switches between login and registration', (tester) async {
    await pumpAuthFlow(tester);

    await tester.tap(find.text("Don't have an account? Register"));
    await tester.pumpAndSettle();
    expect(find.byType(RegistrationPage), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);

    await tester.tap(find.text('Already have an account? Sign in'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(RegistrationPage), findsNothing);
  });

  testWidgets('shows validation errors on empty login form', (tester) async {
    await pumpAuthFlow(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('shows placeholder snackbar after valid login', (tester) async {
    await pumpAuthFlow(tester);

    await tester.enterText(
      find.byType(TextFormField).first,
      'patient@example.com',
    );
    await tester.enterText(find.byType(TextFormField).last, 'secret123');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();

    // Fake API delay is 800ms; advance past it so the snackbar shows.
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(
      find.text('Signed in (placeholder): patient@example.com'),
      findsOneWidget,
    );
  });

  testWidgets('shows placeholder snackbar after valid registration',
      (tester) async {
    await pumpAuthFlow(tester);

    await tester.tap(find.text("Don't have an account? Register"));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Jane Doe');
    await tester.enterText(fields.at(1), 'jane@example.com');
    await tester.enterText(fields.at(2), 'secret123');
    await tester.enterText(fields.at(3), 'secret123');
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(
      find.text('Account created (placeholder): jane@example.com'),
      findsOneWidget,
    );
  });

  testWidgets('registration rejects mismatched passwords', (tester) async {
    await pumpAuthFlow(tester);

    await tester.tap(find.text("Don't have an account? Register"));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Jane Doe');
    await tester.enterText(fields.at(1), 'jane@example.com');
    await tester.enterText(fields.at(2), 'secret123');
    await tester.enterText(fields.at(3), 'different');
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pump();

    expect(find.text('Passwords do not match'), findsOneWidget);
  });
}

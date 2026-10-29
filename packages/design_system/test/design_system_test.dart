import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: Center(child: child)),
      );

  group('AppTheme', () {
    test('light() builds a light teal theme', () {
      final theme = AppTheme.light();
      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, AppColors.background);
      expect(theme.useMaterial3, isTrue);
    });
  });

  group('AppButton', () {
    testWidgets('renders its label and fires onPressed', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrap(AppButton(label: 'Add', onPressed: () => taps++)),
      );

      expect(find.text('Add'), findsOneWidget);
      await tester.tap(find.byType(AppButton));
      expect(taps, 1);
    });

    testWidgets('shows a spinner and ignores taps while loading',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrap(
          AppButton(
            label: 'Add',
            loading: true,
            onPressed: () => taps++,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Add'), findsNothing);
      await tester.tap(find.byType(AppButton), warnIfMissed: false);
      expect(taps, 0);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(wrap(const AppButton(label: 'Out of stock')));

      final button = tester.widget<AppButton>(find.byType(AppButton));
      expect(button.onPressed, isNull);
      expect(find.text('Out of stock'), findsOneWidget);
    });
  });

  group('QuantityStepper', () {
    Widget host() => wrap(
          _StepperHost(initial: 2, max: 3),
        );

    testWidgets('renders the current value', (tester) async {
      await tester.pumpWidget(host());
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('plus increments and minus decrements', (tester) async {
      await tester.pumpWidget(host());

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(find.text('3'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('disables plus at max and minus at min', (tester) async {
      await tester.pumpWidget(host());

      // At max (3): plus must not change the value.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(find.text('3'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(find.text('3'), findsOneWidget);

      // Down to min (1), then minus must not change the value.
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('count animates between values', (tester) async {
      await tester.pumpWidget(host());
      await tester.tap(find.byIcon(Icons.add));
      // Mid-transition the AnimatedSwitcher shows both old and new values.
      await tester.pump();
      expect(find.byType(AnimatedSwitcher), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('3'), findsOneWidget);
    });
  });

  group('ProductImage', () {
    // Note: bundled assets live in the app package, so the design_system
    // tests exercise the fallback contract; asset loading itself is covered
    // by the app's widget tests.
    testWidgets('falls back to the placeholder when no asset is set',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          const ProductImage(
            assetPath: null,
            icon: Icons.local_pharmacy_outlined,
            letter: 'dolo',
            width: 80,
            height: 80,
          ),
        ),
      );

      expect(find.byIcon(Icons.local_pharmacy_outlined), findsOneWidget);
      expect(find.text('D'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('falls back to the placeholder when the asset fails to load',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          const ProductImage(
            assetPath: 'assets/images/products/definitely_missing.jpg',
            icon: Icons.sick_outlined,
            letter: 'c',
            width: 80,
            height: 80,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.sick_outlined), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });
  });

  group('PriceText', () {
    testWidgets('formats price with MRP and discount', (tester) async {
      await tester.pumpWidget(
        wrap(
          const PriceText(pricePaise: 13500, mrpPaise: 15000),
        ),
      );

      expect(find.text('₹135.00'), findsOneWidget);
      expect(find.text('₹150.00'), findsOneWidget);
      expect(find.text('-10%'), findsOneWidget);
    });

    testWidgets('omits MRP and discount when none', (tester) async {
      await tester.pumpWidget(
        wrap(const PriceText(pricePaise: 49900)),
      );

      expect(find.text('₹499.00'), findsOneWidget);
      expect(find.text('-0%'), findsNothing);
    });
  });

  group('RxBadge', () {
    testWidgets('shows Rx', (tester) async {
      await tester.pumpWidget(wrap(const RxBadge()));
      expect(find.text('Rx'), findsOneWidget);
    });
  });

  group('EmptyState', () {
    testWidgets('renders title, message and action', (tester) async {
      await tester.pumpWidget(
        wrap(
          EmptyState(
            title: 'Your cart is empty',
            message: 'Add medicines to get started.',
            actionLabel: 'Browse medicines',
            onAction: () {},
          ),
        ),
      );

      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.text('Add medicines to get started.'), findsOneWidget);
      expect(find.text('Browse medicines'), findsOneWidget);
    });
  });

  group('LoadingView', () {
    testWidgets('shows a spinner and an optional message', (tester) async {
      await tester.pumpWidget(
        wrap(const LoadingView(message: 'Loading…')),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading…'), findsOneWidget);
    });
  });
}

class _StepperHost extends StatefulWidget {
  const _StepperHost({required this.initial, required this.max});

  final int initial;
  final int max;

  @override
  State<_StepperHost> createState() => _StepperHostState();
}

class _StepperHostState extends State<_StepperHost> {
  late int _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    return QuantityStepper(
      value: _value,
      min: 1,
      max: widget.max,
      onChanged: (next) => setState(() => _value = next),
    );
  }
}

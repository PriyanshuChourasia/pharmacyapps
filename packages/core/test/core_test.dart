import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatPaise', () {
    test('formats zero', () {
      expect(formatPaise(0), '₹0.00');
    });

    test('formats whole rupees', () {
      expect(formatPaise(49900), '₹499.00');
    });

    test('formats a paise fraction with a leading zero', () {
      expect(formatPaise(5), '₹0.05');
    });

    test('formats with a thousands separator', () {
      expect(formatPaise(123450), '₹1,234.50');
    });

    test('uses Indian digit grouping above a lakh', () {
      expect(formatPaise(12345678), '₹1,23,456.78');
    });

    test('formats negative amounts', () {
      expect(formatPaise(-123450), '-₹1,234.50');
    });
  });

  group('Result', () {
    test('success exposes value and flags', () {
      const result = Success<int>(7);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.dataOrNull, 7);
      expect(result.errorMessageOrNull, isNull);
      expect(result.errorCodeOrNull, isNull);
    });

    test('failure exposes message and code', () {
      const result = Failure<int>('nope', code: 'invalid');
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.dataOrNull, isNull);
      expect(result.errorMessageOrNull, 'nope');
      expect(result.errorCodeOrNull, 'invalid');
    });

    test('when folds both branches', () {
      int fold(Result<int> r) =>
          r.when(onSuccess: (v) => v * 3, onFailure: (_, _) => -1);
      expect(fold(const Success<int>(2)), 6);
      expect(fold(const Failure<int>('bad')), -1);
    });

    test('map transforms success and passes failures through', () {
      expect(const Success<int>(2).map((v) => '$v').dataOrNull, '2');
      final mapped = const Failure<int>('bad', code: 'c').map((v) => '$v');
      expect(mapped.isFailure, isTrue);
      expect(mapped.errorMessageOrNull, 'bad');
      expect(mapped.errorCodeOrNull, 'c');
    });
  });
}

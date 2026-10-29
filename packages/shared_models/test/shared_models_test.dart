import 'package:flutter_test/flutter_test.dart';
import 'package:shared_models/shared_models.dart';

void main() {
  Product buildProduct({int mrp = 15000, int price = 13500}) => Product(
        id: 'dolo-650',
        name: 'Dolo 650',
        genericName: 'Paracetamol',
        salt: 'Paracetamol 650mg',
        manufacturer: 'Micro Labs',
        categoryId: 'pain_relief',
        packSize: 'Strip of 15 tablets',
        mrp: mrp,
        price: price,
        requiresPrescription: false,
        inStock: true,
        description: 'Fever and pain relief tablet.',
        uses: const ['Fever', 'Headache'],
        sideEffects: const ['Nausea'],
        storage: 'Store in a cool, dry place.',
        imageAsset: 'assets/images/products/tablet_strip.jpg',
      );

  group('Product', () {
    test('computes discount percent with integer math', () {
      expect(buildProduct().discountPercent, 10);
      expect(buildProduct(mrp: 10000, price: 10000).discountPercent, 0);
      expect(buildProduct(mrp: 0, price: 0).discountPercent, 0);
    });

    test('equality is by value', () {
      expect(buildProduct(), buildProduct());
      expect(buildProduct(), isNot(buildProduct(price: 100)));
    });

    test('round-trips through the hand-written JSON', () {
      final product = buildProduct();
      final restored = Product.fromJson(product.toJson());
      expect(restored, product);
    });
  });

  group('CartItem JSON (cart persistence)', () {
    test('round-trips through toJson/fromJson', () {
      final item = CartItem(product: buildProduct(), qty: 2);
      final restored = CartItem.fromJson(item.toJson());
      expect(restored, item);
      expect(restored.qty, 2);
    });

    test('computes line totals in paise', () {
      final item = CartItem(product: buildProduct(), qty: 3);
      expect(item.lineMrpTotal, 45000);
      expect(item.lineTotal, 40500);
    });
  });

  group('Money helpers', () {
    test('converts rupees to paise', () {
      expect(Money.rupees(499), 49900);
    });

    test('computes a whole-percent slice of an amount', () {
      expect(Money.percentOf(10000, 10), 1000);
      expect(Money.percentOf(9999, 10), 999);
    });

    test('formats through the core formatter', () {
      expect(Money.format(123450), '₹1,234.50');
    });
  });
}

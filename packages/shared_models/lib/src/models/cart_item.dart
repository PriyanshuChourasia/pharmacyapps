import 'package:equatable/equatable.dart';

import 'product.dart';

/// A product line in the cart.
///
/// The cart persists each line as JSON across app restarts, which is why the
/// embedded [Product] is serialized verbatim (hand-written, no codegen).
class CartItem extends Equatable {
  const CartItem({required this.product, required this.qty});

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        product: Product.fromJson(json['product'] as Map<String, dynamic>),
        qty: json['qty'] as int,
      );

  /// The product this line refers to.
  final Product product;

  /// Quantity in this line (1…`CartRepository.maxQuantityPerItem`).
  final int qty;

  /// Convenience id of the underlying product.
  String get productId => product.id;

  /// Line total at MRP, in paise.
  int get lineMrpTotal => product.mrp * qty;

  /// Line total at the selling price, in paise.
  int get lineTotal => product.price * qty;

  CartItem copyWith({int? qty}) =>
      CartItem(product: product, qty: qty ?? this.qty);

  Map<String, dynamic> toJson() =>
      {'product': product.toJson(), 'qty': qty};

  @override
  List<Object?> get props => [product, qty];
}

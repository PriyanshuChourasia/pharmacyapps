import 'package:equatable/equatable.dart';

/// A sellable medicine.
///
/// All money fields are integer **paise** — never `double`.
/// [toJson]/[fromJson] exist only because the cart persists products
/// verbatim across app restarts.
class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.genericName,
    required this.salt,
    required this.manufacturer,
    required this.categoryId,
    required this.packSize,
    required this.mrp,
    required this.price,
    required this.requiresPrescription,
    required this.inStock,
    required this.description,
    required this.uses,
    required this.sideEffects,
    required this.storage,
    this.imageAsset,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String,
        genericName: json['genericName'] as String,
        salt: json['salt'] as String,
        manufacturer: json['manufacturer'] as String,
        categoryId: json['categoryId'] as String,
        packSize: json['packSize'] as String,
        mrp: json['mrp'] as int,
        price: json['price'] as int,
        requiresPrescription: json['requiresPrescription'] as bool,
        inStock: json['inStock'] as bool,
        description: json['description'] as String,
        uses: (json['uses'] as List<dynamic>).cast<String>(),
        sideEffects: (json['sideEffects'] as List<dynamic>).cast<String>(),
        storage: json['storage'] as String,
        imageAsset: json['imageAsset'] as String?,
      );

  /// Stable identifier, e.g. `dolo-650`.
  final String id;

  /// Brand name, e.g. `Dolo 650`.
  final String name;

  /// Generic/INN name, e.g. `Paracetamol`.
  final String genericName;

  /// Salt composition, e.g. `Paracetamol 650mg`.
  final String salt;

  /// Manufacturer, e.g. `Micro Labs`.
  final String manufacturer;

  /// Id of the [Category] this product belongs to.
  final String categoryId;

  /// Pack description, e.g. `Strip of 15 tablets`.
  final String packSize;

  /// Maximum retail price in paise.
  final int mrp;

  /// Selling price in paise.
  final int price;

  /// Whether a doctor's prescription is required (Rx badge).
  final bool requiresPrescription;

  /// Out-of-stock products show a disabled button.
  final bool inStock;

  final String description;
  final List<String> uses;
  final List<String> sideEffects;
  final String storage;

  /// Bundled asset path of the product image; `null` → placeholder fallback.
  final String? imageAsset;

  /// Discount over MRP in whole percent (0 when there is none).
  int get discountPercent =>
      mrp <= price || mrp <= 0 ? 0 : ((mrp - price) * 100) ~/ mrp;

  /// Whether the selling price is below MRP.
  bool get hasDiscount => price < mrp;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'genericName': genericName,
        'salt': salt,
        'manufacturer': manufacturer,
        'categoryId': categoryId,
        'packSize': packSize,
        'mrp': mrp,
        'price': price,
        'requiresPrescription': requiresPrescription,
        'inStock': inStock,
        'description': description,
        'uses': uses,
        'sideEffects': sideEffects,
        'storage': storage,
        'imageAsset': imageAsset,
      };

  @override
  List<Object?> get props => [
        id,
        name,
        genericName,
        salt,
        manufacturer,
        categoryId,
        packSize,
        mrp,
        price,
        requiresPrescription,
        inStock,
        description,
        uses,
        sideEffects,
        storage,
        imageAsset,
      ];
}

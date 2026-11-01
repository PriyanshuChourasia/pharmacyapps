import 'package:equatable/equatable.dart';
import 'package:shared_models/shared_models.dart';

enum HomeStatus { loading, loaded, error }

/// Everything the Home page shows.
class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.loading,
    this.categories = const [],
    this.deals = const [],
    this.popular = const [],
    this.recommended = const [],
    this.brands = const [],
    this.cartQty = const {},
    this.address,
    this.error,
  });

  final HomeStatus status;
  final List<Category> categories;

  /// Highest-discount in-stock products.
  final List<Product> deals;
  final List<Product> popular;
  final List<Product> recommended;

  /// Distinct manufacturers.
  final List<String> brands;

  /// productId → quantity in the cart.
  final Map<String, int> cartQty;
  final Address? address;
  final String? error;

  int get cartCount => cartQty.values.fold(0, (sum, q) => sum + q);

  HomeState copyWith({
    HomeStatus? status,
    List<Category>? categories,
    List<Product>? deals,
    List<Product>? popular,
    List<Product>? recommended,
    List<String>? brands,
    Map<String, int>? cartQty,
    Address? address,
    String? error,
  }) => HomeState(
    status: status ?? this.status,
    categories: categories ?? this.categories,
    deals: deals ?? this.deals,
    popular: popular ?? this.popular,
    recommended: recommended ?? this.recommended,
    brands: brands ?? this.brands,
    cartQty: cartQty ?? this.cartQty,
    address: address ?? this.address,
    error: error,
  );

  @override
  List<Object?> get props => [
    status,
    categories,
    deals,
    popular,
    recommended,
    brands,
    cartQty,
    address,
    error,
  ];
}

import 'package:equatable/equatable.dart';

/// A medicine category shown on Home and used to filter the catalog
/// (Pain Relief, Cold & Flu, Diabetes, …).
class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.imageAsset,
    required this.iconKey,
  });

  /// Stable identifier, e.g. `pain_relief`.
  final String id;

  final String name;

  /// Bundled asset path of the category image (never fetched at runtime).
  final String imageAsset;

  /// Key mapped to an icon by the presentation layer (e.g. `heart`), so this
  /// package stays free of Flutter imports.
  final String iconKey;

  @override
  List<Object?> get props => [id, name, imageAsset, iconKey];
}

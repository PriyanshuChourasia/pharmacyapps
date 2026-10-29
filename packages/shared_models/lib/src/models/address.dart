import 'package:equatable/equatable.dart';

/// A delivery address. Demo addresses are seeded in checkout and kept
/// in memory for the app run.
class Address extends Equatable {
  const Address({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.pincode,
    required this.line1,
    required this.city,
  });

  final String id;
  final String fullName;

  /// 10-digit Indian mobile number.
  final String phone;

  /// 6-digit Indian pincode.
  final String pincode;

  final String line1;
  final String city;

  /// One-line representation for order summaries.
  String get summary => '$line1, $city - $pincode';

  @override
  List<Object?> get props => [id, fullName, phone, pincode, line1, city];
}

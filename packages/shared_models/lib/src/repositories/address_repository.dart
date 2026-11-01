import '../models/address.dart';

/// Delivery addresses, shared by the Home header, checkout and profile.
abstract interface class AddressRepository {
  List<Address> get addresses;

  /// The address deliveries currently go to.
  Address? get selected;

  /// Adds [address] (assigning an id when empty), selects it and returns it.
  Address add(Address address);

  void select(String id);

  /// Emits the selected address now and whenever it or the list changes.
  Stream<Address?> watchSelected();
}

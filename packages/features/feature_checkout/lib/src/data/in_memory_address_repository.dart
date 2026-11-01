import 'dart:async';

import 'package:shared_models/shared_models.dart';

/// [AddressRepository] seeded with two demo addresses, in memory.
class InMemoryAddressRepository implements AddressRepository {
  InMemoryAddressRepository() : _selectedId = _seed.first.id;

  static const List<Address> _seed = [
    Address(
      id: 'addr-home',
      fullName: 'Rahul Sharma',
      phone: '9876543210',
      pincode: '400053',
      line1: '12 MG Road, Andheri',
      city: 'Mumbai',
    ),
    Address(
      id: 'addr-pune',
      fullName: 'Rahul Sharma',
      phone: '9876543210',
      pincode: '411001',
      line1: '45 Park Street',
      city: 'Pune',
    ),
  ];

  final List<Address> _addresses = [..._seed];
  final StreamController<Address?> _changes =
      StreamController<Address?>.broadcast();
  String? _selectedId;

  @override
  List<Address> get addresses => List.unmodifiable(_addresses);

  @override
  Address? get selected =>
      _addresses.where((a) => a.id == _selectedId).firstOrNull;

  @override
  Address add(Address address) {
    final stored = address.id.isNotEmpty
        ? address
        : Address(
            id: 'addr-${DateTime.now().microsecondsSinceEpoch}',
            fullName: address.fullName,
            phone: address.phone,
            pincode: address.pincode,
            line1: address.line1,
            city: address.city,
          );
    _addresses.add(stored);
    _selectedId = stored.id;
    _changes.add(stored);
    return stored;
  }

  @override
  void select(String id) {
    if (!_addresses.any((a) => a.id == id)) return;
    _selectedId = id;
    _changes.add(selected);
  }

  @override
  Stream<Address?> watchSelected() async* {
    yield selected;
    yield* _changes.stream;
  }
}

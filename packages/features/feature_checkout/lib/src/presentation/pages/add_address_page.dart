import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_models/shared_models.dart';

/// Validated "Add new address" form. Saves to the [AddressRepository]
/// (which also selects it) and pops the new [Address].
class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _pincode = TextEditingController();
  final _line1 = TextEditingController();
  final _city = TextEditingController();

  @override
  void dispose() {
    for (final c in [_name, _phone, _pincode, _line1, _city]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _required(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label is required' : null;

  String? _digits(String? v, int count, String label) {
    final text = v?.trim() ?? '';
    if (text.isEmpty) return '$label is required';
    if (!RegExp('^\\d{$count}\$').hasMatch(text)) {
      return 'Enter a valid $count-digit $label';
    }
    return null;
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final saved = GetIt.instance<AddressRepository>().add(
      Address(
        id: '',
        fullName: _name.text.trim(),
        phone: _phone.text.trim(),
        pincode: _pincode.text.trim(),
        line1: _line1.text.trim(),
        city: _city.text.trim(),
      ),
    );
    context.pop(saved);
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon,
    String? Function(String?) validator, {
    TextInputType? keyboard,
    int? maxLength,
    bool digitsOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLength: maxLength,
        textInputAction: TextInputAction.next,
        textCapitalization: keyboard == null
            ? TextCapitalization.words
            : TextCapitalization.none,
        inputFormatters: digitsOnly
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          counterText: '',
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add new address')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _field(
              _name,
              'Full name',
              Icons.person_outline,
              (v) => _required(v, 'Full name'),
            ),
            _field(
              _phone,
              'Phone number',
              Icons.phone_outlined,
              (v) => _digits(v, 10, 'phone number'),
              keyboard: TextInputType.phone,
              maxLength: 10,
              digitsOnly: true,
            ),
            _field(
              _pincode,
              'Pincode',
              Icons.pin_drop_outlined,
              (v) => _digits(v, 6, 'pincode'),
              keyboard: TextInputType.number,
              maxLength: 6,
              digitsOnly: true,
            ),
            _field(
              _line1,
              'House / Street',
              Icons.home_outlined,
              (v) => _required(v, 'House / Street'),
            ),
            _field(
              _city,
              'City',
              Icons.location_city_outlined,
              (v) => _required(v, 'City'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: AppButton(label: 'Save address', onPressed: _save),
        ),
      ),
    );
  }
}

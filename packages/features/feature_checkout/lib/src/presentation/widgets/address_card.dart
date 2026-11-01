import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

/// Radio cards for the saved addresses plus "+ Add new address".
class AddressList extends StatelessWidget {
  const AddressList({
    super.key,
    required this.addresses,
    required this.selectedId,
    required this.onSelect,
    required this.onAddNew,
  });

  final List<Address> addresses;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final VoidCallback onAddNew;

  @override
  Widget build(BuildContext context) {
    return RadioGroup<String>(
      groupValue: selectedId,
      onChanged: (id) {
        if (id != null) onSelect(id);
      },
      child: Column(
        children: [
          for (final a in addresses)
            AddressCard(address: a, selected: a.id == selectedId),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onAddNew,
              icon: const Icon(Icons.add),
              label: const Text('Add new address'),
            ),
          ),
        ],
      ),
    );
  }
}

/// One address as a radio tile, highlighted with a teal border when chosen.
/// Must sit under a `RadioGroup<String>`.
class AddressCard extends StatelessWidget {
  const AddressCard({super.key, required this.address, required this.selected});

  final Address address;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primaryLight.withValues(alpha: 0.25)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: RadioListTile<String>(
        value: address.id,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        title: Text(
          address.fullName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text('${address.summary}\nPhone: ${address.phone}'),
        isThreeLine: true,
      ),
    );
  }
}

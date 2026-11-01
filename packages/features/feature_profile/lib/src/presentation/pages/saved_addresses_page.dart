import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_models/shared_models.dart';

/// Lists the saved addresses; tapping one makes it the delivery address.
class SavedAddressesPage extends StatelessWidget {
  const SavedAddressesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = GetIt.instance<AddressRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('Saved addresses')),
      body: StreamBuilder<Address?>(
        stream: repository.watchSelected(),
        builder: (context, snapshot) {
          final selectedId = snapshot.data?.id;
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              for (final a in repository.addresses)
                Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    side: BorderSide(
                      color: a.id == selectedId
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.home_outlined),
                    title: Text(
                      a.fullName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text('${a.summary}\nPhone: ${a.phone}'),
                    isThreeLine: true,
                    trailing: a.id == selectedId
                        ? const Chip(
                            label: Text('Default'),
                            visualDensity: VisualDensity.compact,
                          )
                        : null,
                    onTap: () => repository.select(a.id),
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: AppButton(
            label: 'Add new address',
            icon: Icons.add,
            onPressed: () => context.push(RoutePaths.addAddress),
          ),
        ),
      ),
    );
  }
}

import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/parcels/data/parcel_repository.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class ParcelListPage extends ConsumerWidget {
  const ParcelListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerId = ref.watch(sessionControllerProvider).ownerId;
    final repository = ParcelRepository(ref.watch(appDatabaseProvider));
    return AgroPage(
      title: 'Parcelas',
      actions: [
        IconButton(
          onPressed: () => context.push('/parcelas/nueva'),
          icon: const Icon(Icons.add),
          tooltip: 'Nueva parcela',
        ),
      ],
      child: ownerId == null
          ? const Center(child: Text('Sin sesión local'))
          : StreamBuilder(
              stream: repository.watchAll(ownerId),
              builder: (context, snapshot) => ListView(
                children: [
                  for (final parcel in snapshot.data ?? const [])
                    Card(
                      child: ListTile(
                        leading: Icon(
                          parcel.isActive
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                        ),
                        title: Text(parcel.name),
                        subtitle: Text(
                          parcel.isArchived
                              ? 'Archivada'
                              : parcel.locality ?? 'Sin localidad',
                        ),
                        onTap: () =>
                            context.push('/parcelas/${parcel.id}/editar'),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

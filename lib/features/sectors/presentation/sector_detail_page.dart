import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class SectorDetailPage extends ConsumerWidget {
  const SectorDetailPage({required this.sectorId, super.key});

  final String sectorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(appDatabaseProvider);
    return AgroPage(
      title: 'Detalle sector',
      child: FutureBuilder(
        future: (database.select(
          database.sectors,
        )..where((row) => row.id.equals(sectorId))).getSingle(),
        builder: (context, snapshot) {
          final sector = snapshot.data;
          if (sector == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: [
              ListTile(
                title: Text(sector.name),
                subtitle: Text(
                  'Sector ${sector.number} · ${sector.areaSquareMeters.toStringAsFixed(0)} m²',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.eco_outlined),
                title: const Text('Cambiar cultivo'),
                onTap: () => context.push('/cultivos'),
              ),
              ListTile(
                leading: const Icon(Icons.event_repeat_outlined),
                title: const Text('Rotación futura'),
                onTap: () => context.push('/sectores/$sectorId/rotacion'),
              ),
              ListTile(
                leading: const Icon(Icons.hive_outlined),
                title: const Text('Revisión apícola'),
                onTap: () => context.push('/sectores/$sectorId/apicultura'),
              ),
            ],
          );
        },
      ),
    );
  }
}

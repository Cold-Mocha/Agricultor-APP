import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/core/export/android_saf_exporter.dart';
import 'package:agrocampo/core/export/xlsx_exporter.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/export/data/export_repository.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class ExportPage extends ConsumerStatefulWidget {
  const ExportPage({super.key});
  @override
  ConsumerState<ExportPage> createState() => _ExportPageState();
}

final class _ExportPageState extends ConsumerState<ExportPage> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) => AgroPage(
    title: 'Exportar',
    subtitle: 'Copia XLSX íntegra de los datos disponibles en este dispositivo',
    child: ListView(
      children: [
        const Card(
          child: ListTile(
            leading: Icon(Icons.table_view_outlined),
            title: Text('Snapshot local XLSX v1'),
            subtitle: Text(
              'Incluye parcelas, sectores, labores, suelo, riego, producción y apicultura, incluso si hay respaldo pendiente.',
            ),
          ),
        ),
        FilledButton.icon(
          onPressed: _busy ? null : _export,
          icon: const Icon(Icons.save_alt),
          label: Text(
            _busy ? 'Preparando y validando…' : 'Elegir destino y guardar',
          ),
        ),
      ],
    ),
  );

  Future<void> _export() async {
    final ownerId = ref.read(sessionControllerProvider).ownerId;
    if (ownerId == null) return;
    setState(() => _busy = true);
    try {
      final snapshot = await ExportRepository(ref.read(appDatabaseProvider))
          .snapshot(ownerId);
      final bytes = await const XlsxExporter().encodeOffMainIsolate(snapshot);
      final saved = await const AndroidSafExporter().save(
        bytes,
        'AgroCampo-${snapshot.generatedAt.toIso8601String().substring(0, 10)}.xlsx',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              saved ? 'Exportación completada.' : 'Exportación cancelada.',
            ),
          ),
        );
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No fue posible completar la exportación. No se confirmó ningún archivo parcial.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }
}

import 'package:agrocampo/src/app/layout/agro_page.dart';
import 'package:agrocampo/src/modules/export/presentation/controllers/export_controller.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
            leading: Icon(LucideIcons.table),
            title: Text('Copia XLSX v1'),
            subtitle: Text(
              'Incluye sectores, labores, suelo, riego, producción y apicultura.',
            ),
          ),
        ),
        FilledButton.icon(
          onPressed: _busy ? null : _export,
          icon: const Icon(LucideIcons.download),
          label: Text(
            _busy ? 'Preparando y validando…' : 'Elegir destino y guardar',
          ),
        ),
      ],
    ),
  );

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final result = await ref.read(exportControllerProvider).export();
      if (result == ExportStatus.noSession) return;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result == ExportStatus.saved
                  ? 'Exportación completada.'
                  : 'Exportación cancelada.',
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

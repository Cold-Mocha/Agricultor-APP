import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/modules/export/infrastructure/android_saf_exporter.dart';
import 'package:agrocampo_backend/src/modules/export/infrastructure/persistence/export_repository.dart';
import 'package:agrocampo_backend/src/modules/export/infrastructure/xlsx_exporter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ExportStatus { saved, cancelled, noSession }

final exportFacadeProvider = Provider<ExportFacade>(ExportFacade.new);

final class ExportFacade {
  ExportFacade(this._ref);
  final Ref _ref;

  Future<ExportStatus> export(String ownerId) async {
    final snapshot = await ExportRepository(_ref.read(appDatabaseProvider))
        .snapshot(ownerId);
    final bytes = await const XlsxExporter().encodeOffMainIsolate(snapshot);
    final saved = await const AndroidSafExporter().save(
      bytes,
      'AgroCampo-${snapshot.generatedAt.toIso8601String().substring(0, 10)}.xlsx',
    );
    return saved ? ExportStatus.saved : ExportStatus.cancelled;
  }
}

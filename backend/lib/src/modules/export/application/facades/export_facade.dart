import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/modules/export/infrastructure/android_saf_exporter.dart';
import 'package:agrocampo_backend/src/modules/export/infrastructure/persistence/export_repository.dart';
import 'package:agrocampo_backend/src/modules/export/infrastructure/xlsx_exporter.dart';
import 'package:agrocampo_backend/src/modules/history/history_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ExportStatus { saved, cancelled, noSession }

final exportFacadeProvider = Provider<ExportFacade>(ExportFacade.new);
final exportDestinationProvider =
    Provider<Future<bool> Function(List<int>, String)>(
      (ref) => const AndroidSafExporter().save,
    );

final class ExportFacade {
  ExportFacade(this._ref);
  final Ref _ref;

  Future<ExportStatus> export(String ownerId) async {
    final database = _ref.read(appDatabaseProvider);
    final repository = ExportRepository(database);
    final snapshot = await database.transaction(
      () async => repository.snapshot(
        ownerId,
        history: await _ref.read(historyFacadeProvider).listAll(ownerId),
      ),
    );
    try {
      final bytes = await const XlsxExporter().encodeOffMainIsolate(snapshot);
      final saved = await _ref.read(exportDestinationProvider)(
        bytes,
        'AgroCampo-${snapshot.generatedAt.toIso8601String().substring(0, 10)}.xlsx',
      );
      await repository.recordDelivery(
        ownerId,
        snapshot.id,
        saved ? 'complete' : 'cancelled',
      );
      return saved ? ExportStatus.saved : ExportStatus.cancelled;
    } on Object {
      await repository.recordDelivery(ownerId, snapshot.id, 'failed');
      rethrow;
    }
  }
}

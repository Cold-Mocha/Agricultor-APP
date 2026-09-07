import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/backend_providers.dart';
import '../../../core/export/android_saf_exporter.dart';
import '../../../core/export/xlsx_exporter.dart';
import '../../auth/controllers/session_controller.dart';
import '../repositories/export_repository.dart';

enum ExportStatus { saved, cancelled, noSession }

final exportControllerProvider = Provider<ExportController>(
  ExportController.new,
);

final class ExportController {
  ExportController(this._ref);
  final Ref _ref;

  Future<ExportStatus> export() async {
    final ownerId = _ref.read(sessionControllerProvider).ownerId;
    if (ownerId == null) return ExportStatus.noSession;
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

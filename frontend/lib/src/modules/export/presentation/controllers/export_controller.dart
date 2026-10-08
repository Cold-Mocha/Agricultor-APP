import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final exportControllerProvider = Provider<ExportController>(
  ExportController.new,
);

final class ExportController {
  ExportController(this._ref);

  final Ref _ref;

  Future<ExportStatus> export() {
    final ownerId = _ref.read(unlockedOwnerIdProvider);
    if (ownerId == null) return Future.value(ExportStatus.noSession);
    return _ref.read(exportFacadeProvider).export(ownerId);
  }
}

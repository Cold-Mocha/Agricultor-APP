import 'package:agrocampo_backend/core/config/backend_providers.dart';
import 'package:agrocampo_backend/features/context/domain/agricultural_context.dart';
import 'package:agrocampo_backend/features/context/dto/context_options.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final contextOptionsControllerProvider = Provider<ContextOptionsController>(
  ContextOptionsController.new,
);

final class ContextOptionsController {
  ContextOptionsController(this._ref);
  final Ref _ref;

  Stream<List<ContextOption>> watchParcels(String ownerId) {
    final database = _ref.read(appDatabaseProvider);
    return (database.select(database.parcels)
          ..where(
            (row) =>
                row.ownerId.equals(ownerId) &
                row.deletedAt.isNull() &
                row.isArchived.equals(false),
          )
          ..orderBy([(row) => OrderingTerm.asc(row.name)]))
        .watch()
        .map(
          (rows) => rows
              .map((row) => ContextOption(id: row.id, name: row.name))
              .toList(growable: false),
        );
  }

  Stream<List<ContextOption>> watchSectors(String ownerId, String? parcelId) {
    final database = _ref.read(appDatabaseProvider);
    return (database.select(database.sectors)
          ..where(
            (row) =>
                row.ownerId.equals(ownerId) &
                row.parcelId.equals(parcelId ?? '') &
                row.deletedAt.isNull(),
          )
          ..orderBy([(row) => OrderingTerm.asc(row.number)]))
        .watch()
        .map(
          (rows) => rows
              .map((row) => ContextOption(id: row.id, name: row.name))
              .toList(growable: false),
        );
  }

  Future<BoundContextView> loadBound(BoundAgriculturalContext bound) async {
    final database = _ref.read(appDatabaseProvider);
    final parcel = bound.parcelId == null
        ? null
        : await (database.select(
            database.parcels,
          )..where((row) => row.id.equals(bound.parcelId!))).getSingleOrNull();
    final sector = bound.sectorId == null
        ? null
        : await (database.select(
            database.sectors,
          )..where((row) => row.id.equals(bound.sectorId!))).getSingleOrNull();
    return BoundContextView(parcelName: parcel?.name, sectorName: sector?.name);
  }
}

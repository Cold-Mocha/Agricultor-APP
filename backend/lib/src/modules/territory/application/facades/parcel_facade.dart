import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/modules/territory/contracts/dto/parcel_summary.dart';
import 'package:agrocampo_backend/src/modules/territory/infrastructure/persistence/parcel_repository.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final parcelFacadeProvider = Provider<ParcelFacade>(
  (ref) => ParcelFacade(ref.watch(appDatabaseProvider)),
);

final class ParcelFacade {
  ParcelFacade(this._database);
  final AppDatabase _database;
  ParcelSummary _summary(Parcel row) => ParcelSummary(
    id: row.id,
    name: row.name,
    isActive: row.isActive,
    isArchived: row.isArchived,
    locality: row.locality,
  );

  Stream<List<ParcelSummary>> watchAll(String ownerId) =>
      ParcelRepository(_database)
          .watchAll(ownerId)
          .map(
            (rows) => rows
                .map(
                  (row) => ParcelSummary(
                    id: row.id,
                    name: row.name,
                    isActive: row.isActive,
                    isArchived: row.isArchived,
                    locality: row.locality,
                  ),
                )
                .toList(growable: false),
          );

  Future<List<ParcelSummary>> listAll(String ownerId) async {
    final rows =
        await (_database.select(_database.parcels)
              ..where(
                (row) => row.ownerId.equals(ownerId) & row.deletedAt.isNull(),
              )
              ..orderBy([(row) => OrderingTerm.asc(row.name)]))
            .get();
    return rows.map(_summary).toList(growable: false);
  }

  Stream<ParcelSummary?> watchActive(String ownerId) =>
      (_database.select(_database.parcels)..where(
            (row) =>
                row.ownerId.equals(ownerId) &
                row.isActive.equals(true) &
                row.deletedAt.isNull(),
          ))
          .watchSingleOrNull()
          .map((row) => row == null ? null : _summary(row));

  Future<ParcelSummary?> loadOwned({
    required String ownerId,
    required String id,
  }) async {
    final row =
        await (_database.select(_database.parcels)..where(
              (row) =>
                  row.id.equals(id) &
                  row.ownerId.equals(ownerId) &
                  row.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    return row == null ? null : _summary(row);
  }

  /// Selects the local working parcel without creating a business mutation.
  Future<void> selectActiveForContext({
    required String ownerId,
    required String id,
  }) async {
    await _database.transaction(() async {
      await (_database.update(_database.parcels)
            ..where((row) => row.ownerId.equals(ownerId)))
          .write(const ParcelsCompanion(isActive: Value(false)));
      await (_database.update(_database.parcels)
            ..where((row) => row.id.equals(id) & row.ownerId.equals(ownerId)))
          .write(const ParcelsCompanion(isActive: Value(true)));
    });
  }

  Future<ParcelSummary?> load(String id) async {
    final row = await (_database.select(
      _database.parcels,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
    return row == null ? null : _summary(row);
  }

  Future<String> save(ParcelFormInput input) =>
      ParcelRepository(_database).save(
        ownerId: input.ownerId,
        id: input.id,
        name: input.name,
        locality: input.locality,
        isActive: input.isActive,
      );

  Future<void> archive({
    required String ownerId,
    required String id,
    required bool archived,
  }) =>
      ParcelRepository(_database)
          .archive(ownerId: ownerId, id: id, archived: archived);
}

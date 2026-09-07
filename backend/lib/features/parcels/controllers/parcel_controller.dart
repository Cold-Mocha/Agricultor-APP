import 'package:agrocampo_backend/core/config/backend_providers.dart';
import 'package:agrocampo_backend/core/database/app_database.dart';
import 'package:agrocampo_backend/features/context/controllers/agricultural_context_controller.dart';
import 'package:agrocampo_backend/features/parcels/dto/parcel_view.dart';
import 'package:agrocampo_backend/features/parcels/repositories/parcel_repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final parcelControllerProvider = Provider<ParcelController>(
  ParcelController.new,
);

final class ParcelController {
  ParcelController(this._ref);
  final Ref _ref;
  AppDatabase get _database => _ref.read(appDatabaseProvider);
  ParcelView _view(Parcel row) => ParcelView(
    id: row.id,
    name: row.name,
    isActive: row.isActive,
    isArchived: row.isArchived,
    locality: row.locality,
  );

  Stream<List<ParcelView>> watchAll(String ownerId) =>
      ParcelRepository(_database)
          .watchAll(ownerId)
          .map(
            (rows) => rows
                .map(
                  (row) => ParcelView(
                    id: row.id,
                    name: row.name,
                    isActive: row.isActive,
                    isArchived: row.isArchived,
                    locality: row.locality,
                  ),
                )
                .toList(growable: false),
          );

  Stream<ParcelView?> watchActive(String ownerId) =>
      (_database.select(_database.parcels)..where(
            (row) =>
                row.ownerId.equals(ownerId) &
                row.isActive.equals(true) &
                row.deletedAt.isNull(),
          ))
          .watchSingleOrNull()
          .map((row) => row == null ? null : _view(row));

  Future<ParcelView?> load(String id) async {
    final row = await (_database.select(
      _database.parcels,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
    return row == null ? null : _view(row);
  }

  Future<String> save(ParcelFormInput input) async {
    final id = await ParcelRepository(_database).save(
      ownerId: input.ownerId,
      id: input.id,
      name: input.name,
      locality: input.locality,
      isActive: input.isActive,
    );
    if (input.isActive) {
      await _ref
          .read(agriculturalContextControllerProvider.notifier)
          .selectParcel(id);
    }
    return id;
  }

  Future<void> archive({
    required String ownerId,
    required String id,
    required bool archived,
  }) =>
      ParcelRepository(_database)
          .archive(ownerId: ownerId, id: id, archived: archived);
}

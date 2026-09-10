import 'dart:convert';

import 'package:agrocampo_backend/src/platform/database/daos/form_draft_dao.dart';
import 'package:agrocampo_backend/src/platform/sync/persistence/daos/conflict_dao.dart';
import 'package:agrocampo_backend/src/platform/sync/persistence/daos/sync_cursor_dao.dart';
import 'package:agrocampo_backend/src/platform/sync/persistence/daos/sync_outbox_dao.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part '../../modules/agricultural_context/infrastructure/persistence/tables/app_preferences.dart';
part '../../modules/agro_ai/infrastructure/persistence/tables/ai_messages.dart';
part '../../modules/apiary/infrastructure/persistence/tables/apiary_inspections.dart';
part '../../modules/crop_cycles/infrastructure/persistence/tables/agricultural_seasons.dart';
part '../../modules/crop_cycles/infrastructure/persistence/tables/crop_seasons.dart';
part '../../modules/crop_cycles/infrastructure/persistence/tables/custom_crops.dart';
part '../../modules/crop_cycles/infrastructure/persistence/tables/official_crops.dart';
part '../../modules/export/infrastructure/persistence/tables/export_snapshots.dart';
part '../../modules/irrigation/infrastructure/persistence/tables/crop_irrigation_rules.dart';
part '../../modules/irrigation/infrastructure/persistence/tables/irrigation_estimates.dart';
part '../../modules/irrigation/infrastructure/persistence/tables/irrigation_records.dart';
part '../../modules/irrigation/infrastructure/persistence/tables/sector_irrigation_configs.dart';
part '../../modules/labors/infrastructure/persistence/tables/labors.dart';
part '../../modules/media/infrastructure/persistence/tables/photo_attachments.dart';
part '../../modules/production/infrastructure/persistence/tables/production_records.dart';
part '../../modules/profile/infrastructure/persistence/tables/local_profiles.dart';
part '../../modules/reminders/infrastructure/persistence/tables/reminders.dart';
part '../../modules/soil/infrastructure/persistence/tables/soil_measurements.dart';
part '../../modules/territory/infrastructure/persistence/tables/parcels.dart';
part '../../modules/territory/infrastructure/persistence/tables/sectors.dart';
part '../../modules/weather/infrastructure/persistence/tables/weather_cache.dart';
part '../notifications/persistence/tables/device_installations.dart';
part '../sync/persistence/tables/sync_conflicts.dart';
part '../sync/persistence/tables/sync_cursors.dart';
part '../sync/persistence/tables/sync_outbox.dart';
part 'app_database.g.dart';
part 'migrations/functional_core_v10.dart';
part 'migrations/functional_refinement_v11.dart';
part 'tables/form_drafts.dart';

@DriftDatabase(
  tables: [
    LocalProfiles,
    AppPreferences,
    SyncOutbox,
    SyncCursors,
    SyncConflicts,
    FormDrafts,
    Parcels,
    Sectors,
    OfficialCrops,
    CustomCrops,
    CropSeasons,
    AgriculturalSeasons,
    SectorIrrigationConfigs,
    Labors,
    SoilMeasurements,
    IrrigationRecords,
    CropIrrigationRules,
    IrrigationEstimates,
    ProductionRecords,
    PhotoAttachments,
    Reminders,
    DeviceInstallations,
    ApiaryInspections,
    WeatherCache,
    AiMessages,
    ExportSnapshots,
  ],
  daos: [SyncOutboxDao, SyncCursorDao, ConflictDao, FormDraftDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase({String name = 'agrocampo'}) : super(driftDatabase(name: name));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 11;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await customStatement('PRAGMA foreign_keys = ON');
      for (final statement in _functionalCoreV10Indexes) {
        await customStatement(statement);
      }
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(parcels);
      }
      if (from < 3) {
        if (from == 2) {
          await migrator.addColumn(parcels, parcels.polygonJson);
          await migrator.addColumn(parcels, parcels.areaSquareMeters);
        }
        await migrator.createTable(sectors);
        await migrator.createTable(officialCrops);
        await migrator.createTable(customCrops);
        await migrator.createTable(cropSeasons);
      }
      if (from < 4) {
        await migrator.createTable(labors);
        await migrator.createTable(soilMeasurements);
        await migrator.createTable(irrigationRecords);
      }
      if (from < 5) {
        await migrator.createTable(cropIrrigationRules);
        await migrator.createTable(irrigationEstimates);
      }
      if (from < 6) {
        await migrator.createTable(productionRecords);
      }
      if (from < 7) {
        await migrator.createTable(photoAttachments);
        await migrator.createTable(reminders);
        await migrator.createTable(deviceInstallations);
      }
      if (from < 8) {
        await migrator.createTable(apiaryInspections);
      }
      if (from < 9) {
        await migrator.createTable(weatherCache);
        await migrator.createTable(aiMessages);
        await migrator.createTable(exportSnapshots);
      }
      if (from < 10) {
        await transaction(() => _upgradeFunctionalCoreV10(this, migrator));
      }
      if (from < 11) {
        await transaction(() => _upgradeFunctionalRefinementV11(this, migrator));
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      // Idempotent so v10 databases created by older 002 builds also receive
      // the query indexes without a destructive schema bump.
      for (final statement in _functionalCoreV10Indexes) {
        await customStatement(statement);
      }
      await _ensureFunctionalRefinementV11Columns(this);
      for (final statement in _functionalRefinementV11Indexes) {
        await customStatement(statement);
      }
    },
  );
}

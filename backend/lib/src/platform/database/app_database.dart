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
part '../../modules/territory/infrastructure/persistence/tables/sectors.dart';
part '../../modules/weather/infrastructure/persistence/tables/weather_cache.dart';
part '../notifications/persistence/tables/device_installations.dart';
part '../sync/persistence/tables/sync_conflicts.dart';
part '../sync/persistence/tables/sync_cursors.dart';
part '../sync/persistence/tables/sync_outbox.dart';
part 'app_database.g.dart';
part 'migrations/sector_number_reuse_v13.dart';
part 'migrations/sector_only_v12.dart';
part 'tables/form_drafts.dart';

@DriftDatabase(
  tables: [
    LocalProfiles,
    AppPreferences,
    SyncOutbox,
    SyncCursors,
    SyncConflicts,
    FormDrafts,
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
  int get schemaVersion => 13;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await customStatement('PRAGMA foreign_keys = ON');
      for (final statement in _sectorOnlyV12Indexes) {
        await customStatement(statement);
      }
      for (final statement in _sectorNumberReuseV13Indexes) {
        await customStatement(statement);
      }
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 12) {
        await _resetForSectorOnlyV12(this, migrator);
      }
      if (from < 13) {
        await _allowSectorNumberReuseV13(this, migrator);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      for (final statement in _sectorOnlyV12Indexes) {
        await customStatement(statement);
      }
      for (final statement in _sectorNumberReuseV13Indexes) {
        await customStatement(statement);
      }
    },
  );
}

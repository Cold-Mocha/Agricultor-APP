import 'package:agrocampo/core/database/daos/conflict_dao.dart';
import 'package:agrocampo/core/database/daos/form_draft_dao.dart';
import 'package:agrocampo/core/database/daos/sync_cursor_dao.dart';
import 'package:agrocampo/core/database/daos/sync_outbox_dao.dart';
import 'package:agrocampo/core/database/tables/apiary_inspection_table.dart';
import 'package:agrocampo/core/database/tables/crop_irrigation_rule_table.dart';
import 'package:agrocampo/core/database/tables/external_service_tables.dart';
import 'package:agrocampo/core/database/tables/irrigation_estimate_table.dart';
import 'package:agrocampo/core/database/tables/labor_tables.dart';
import 'package:agrocampo/core/database/tables/media_reminder_tables.dart';
import 'package:agrocampo/core/database/tables/parcel_table.dart';
import 'package:agrocampo/core/database/tables/production_table.dart';
import 'package:agrocampo/core/database/tables/technical_tables.dart';
import 'package:agrocampo/core/database/tables/territory_tables.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';
part 'migrations/functional_core_v10.dart';

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
  int get schemaVersion => 10;

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
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      // Idempotent so v10 databases created by older 002 builds also receive
      // the query indexes without a destructive schema bump.
      for (final statement in _functionalCoreV10Indexes) {
        await customStatement(statement);
      }
    },
  );
}

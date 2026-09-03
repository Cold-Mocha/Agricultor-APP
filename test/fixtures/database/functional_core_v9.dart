import 'dart:io';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import '../../generated/migrations/schema_v9.dart' as v9;

const functionalCoreV9TableNames = <String>[
  'local_profiles',
  'app_preferences',
  'sync_outbox',
  'sync_cursors',
  'sync_conflicts',
  'form_drafts',
  'parcels',
  'sectors',
  'official_crops',
  'custom_crops',
  'crop_seasons',
  'labors',
  'soil_measurements',
  'irrigation_records',
  'crop_irrigation_rules',
  'irrigation_estimates',
  'production_records',
  'photo_attachments',
  'reminders',
  'device_installations',
  'apiary_inspections',
  'weather_cache',
  'ai_messages',
  'export_snapshots',
];

Future<void> createPopulatedFunctionalCoreV9(File file) async {
  final database = v9.DatabaseAtV9(NativeDatabase(file));
  const timestamp = '2026-01-02T12:00:00.000Z';
  final statements = <String>[
    "INSERT INTO local_profiles (id, display_name, locale, updated_at) VALUES ('owner-1','Propietaria fixture','es_CL','$timestamp')",
    "INSERT INTO app_preferences (owner_id, key, value, updated_at) VALUES ('owner-1','activeParcelId','parcel-1','$timestamp')",
    "INSERT INTO parcels (id, owner_id, name, is_active, is_archived, version, updated_at) VALUES ('parcel-1','owner-1','Parcela fixture',1,0,1,'$timestamp')",
    "INSERT INTO sectors (id, owner_id, parcel_id, number, name, kind, polygon_json, area_square_meters, version, updated_at) VALUES ('sector-1','owner-1','parcel-1',1,'Sector fixture','crop','[]',1000,1,'$timestamp')",
    "INSERT INTO official_crops (id, common_name, category, color_token, icon_asset, catalog_version) VALUES ('crop-official-1','Tomate','hortaliza','cropGreen','assets/icons/crops/default.svg',1)",
    "INSERT INTO custom_crops (id, owner_id, name, updated_at) VALUES ('crop-custom-1','owner-1','Cultivo local','$timestamp')",
    "INSERT INTO crop_seasons (id, owner_id, sector_id, crop_id, is_custom_crop, status, starts_on, updated_at) VALUES ('crop-season-1','owner-1','sector-1','crop-official-1',0,'active','$timestamp','$timestamp')",
    "INSERT INTO labors (id, owner_id, parcel_id, sector_id, type, details_json, occurred_at, updated_at) VALUES ('labor-1','owner-1','parcel-1','sector-1','other','{}','$timestamp','$timestamp')",
    "INSERT INTO soil_measurements (id, owner_id, sector_id, measured_at, updated_at) VALUES ('soil-1','owner-1','sector-1','$timestamp','$timestamp')",
    "INSERT INTO irrigation_records (id, owner_id, sector_id, irrigation_type, soil_type_code, irrigated_at, updated_at) VALUES ('irrigation-1','owner-1','sector-1','drip','medium','$timestamp','$timestamp')",
    "INSERT INTO crop_irrigation_rules (id, crop_id, soil_type_code, version, soil_multiplier_permille, efficiency_permille, minimum_duration_minutes, maximum_duration_minutes, source_title, source_reference, is_active) VALUES ('rule-1','crop-official-1','medium',1,1000,900,10,120,'Fixture','fixture-v9',0)",
    "INSERT INTO irrigation_estimates (id, owner_id, sector_id, rule_id, rule_version, soil_type_code, inputs_json, estimated_liters_milli, recommended_minutes, warnings_json, created_at) VALUES ('estimate-1','owner-1','sector-1','rule-1',1,'medium','{}',100000,30,'[]','$timestamp')",
    "INSERT INTO production_records (id, owner_id, parcel_id, sector_id, crop_id, quantity, unit, harvested_at, updated_at) VALUES ('production-1','owner-1','parcel-1','sector-1','crop-official-1',10,'kg','$timestamp','$timestamp')",
    "INSERT INTO photo_attachments (id, owner_id, aggregate_type, aggregate_id, local_path, content_hash, mime_type, upload_state, captured_at) VALUES ('photo-1','owner-1','labor','labor-1','fixture/photo.jpg','fixture-hash','image/jpeg','pending','$timestamp')",
    "INSERT INTO reminders (id, owner_id, sector_id, title, scheduled_at, is_completed, updated_at) VALUES ('reminder-1','owner-1','sector-1','Revisar sector','$timestamp',0,'$timestamp')",
    "INSERT INTO device_installations (id, owner_id, fcm_token, platform, updated_at) VALUES ('device-1','owner-1','fixture-token','android','$timestamp')",
    "INSERT INTO apiary_inspections (id, owner_id, sector_id, task_type, beekeeper_name, hive_count, queen_status, brood_status, feeding_status, health_notes, pest_notes, super_installed, inspected_at, updated_at) VALUES ('apiary-1','owner-1','sector-1','inspection','Apicultora',2,'present','normal','not_required','Sin novedades','Sin plagas',0,'$timestamp','$timestamp')",
    "INSERT INTO weather_cache (id, owner_id, locality, payload_json, fetched_at) VALUES ('weather-1','owner-1','Santiago','{}','$timestamp')",
    "INSERT INTO ai_messages (id, owner_id, role, content, created_at) VALUES ('message-1','owner-1','user','Consulta fixture','$timestamp')",
    "INSERT INTO export_snapshots (id, owner_id, status, manifest_json, created_at) VALUES ('export-1','owner-1','ready','{}','$timestamp')",
    "INSERT INTO form_drafts (owner_id, draft_key, payload_json, schema_version, updated_at) VALUES ('owner-1','labor','{}',1,'$timestamp')",
    "INSERT INTO sync_cursors (owner_id, stream, last_change_seq, updated_at) VALUES ('owner-1','owner-changes-v1',0,'$timestamp')",
    "INSERT INTO sync_conflicts (conflict_id, owner_id, aggregate_type, aggregate_id, local_json, remote_json, detected_at) VALUES ('conflict-1','owner-1','parcel','parcel-1','{}','{}','$timestamp')",
    "INSERT INTO sync_outbox (operation_id, owner_id, aggregate_type, aggregate_id, mutation_kind, payload_json, dependency_operation_id, state, attempt_count, created_at) VALUES ('operation-1','owner-1','parcel','parcel-1','update','{}',NULL,'pending',0,'$timestamp')",
  ];
  try {
    for (final statement in statements) {
      await database.customStatement(statement);
    }
  } finally {
    await database.close();
  }
}

Future<void> corruptFunctionalCoreV9AssignmentParent(File file) async {
  final database = v9.DatabaseAtV9(NativeDatabase(file));
  try {
    await database.customStatement('PRAGMA foreign_keys = OFF');
    await database.customStatement("DELETE FROM sectors WHERE id = 'sector-1'");
  } finally {
    await database.close();
  }
}

Future<({int version, bool hasAgriculturalSeasons})> inspectV9File(
  File file,
) async {
  final database = v9.DatabaseAtV9(NativeDatabase(file));
  try {
    final version = await database
        .customSelect('PRAGMA user_version')
        .map((row) => row.read<int>('user_version'))
        .getSingle();
    final newTableCount = await database
        .customSelect(
          "SELECT COUNT(*) AS amount FROM sqlite_master WHERE type = 'table' AND name = 'agricultural_seasons'",
        )
        .map((row) => row.read<int>('amount'))
        .getSingle();
    return (version: version, hasAgriculturalSeasons: newTableCount != 0);
  } finally {
    await database.close();
  }
}

Future<void> populateFunctionalCoreV9(AppDatabase database) async {
  final now = DateTime.utc(2026, 1, 2, 12);
  await database.batch((batch) {
    batch.insert(
      database.localProfiles,
      LocalProfilesCompanion.insert(
        id: 'owner-1',
        displayName: 'Propietaria fixture',
        updatedAt: now,
      ),
    );
    batch.insert(
      database.appPreferences,
      AppPreferencesCompanion.insert(
        ownerId: 'owner-1',
        key: 'activeParcelId',
        value: 'parcel-1',
        updatedAt: now,
      ),
    );
    batch.insert(
      database.parcels,
      ParcelsCompanion.insert(
        id: 'parcel-1',
        ownerId: 'owner-1',
        name: 'Parcela fixture',
        isActive: const Value(true),
        updatedAt: now,
      ),
    );
    batch.insert(
      database.sectors,
      SectorsCompanion.insert(
        id: 'sector-1',
        ownerId: 'owner-1',
        parcelId: 'parcel-1',
        number: 1,
        name: 'Sector fixture',
        polygonJson: '[{"latitude":-33.4,"longitude":-70.6},{"latitude":-33.4,"longitude":-70.59},{"latitude":-33.39,"longitude":-70.59}]',
        areaSquareMeters: 1000,
        updatedAt: now,
      ),
    );
    batch.insert(
      database.officialCrops,
      OfficialCropsCompanion.insert(
        id: 'crop-official-1',
        commonName: 'Tomate',
        category: 'hortaliza',
        colorToken: 'cropGreen',
        iconAsset: 'assets/icons/crops/default.svg',
      ),
    );
    batch.insert(
      database.customCrops,
      CustomCropsCompanion.insert(
        id: 'crop-custom-1',
        ownerId: 'owner-1',
        name: 'Cultivo local',
        updatedAt: now,
      ),
    );
    batch.insert(
      database.cropSeasons,
      CropSeasonsCompanion.insert(
        id: 'crop-season-1',
        ownerId: 'owner-1',
        sectorId: 'sector-1',
        cropId: 'crop-official-1',
        startsOn: now,
        updatedAt: now,
      ),
    );
    batch.insert(
      database.labors,
      LaborsCompanion.insert(
        id: 'labor-1',
        ownerId: 'owner-1',
        parcelId: 'parcel-1',
        sectorId: 'sector-1',
        type: 'other',
        occurredAt: now,
        updatedAt: now,
      ),
    );
    batch.insert(
      database.soilMeasurements,
      SoilMeasurementsCompanion.insert(
        id: 'soil-1',
        ownerId: 'owner-1',
        sectorId: 'sector-1',
        measuredAt: now,
        updatedAt: now,
      ),
    );
    batch.insert(
      database.irrigationRecords,
      IrrigationRecordsCompanion.insert(
        id: 'irrigation-1',
        ownerId: 'owner-1',
        sectorId: 'sector-1',
        irrigationType: 'drip',
        soilTypeCode: 'medium',
        irrigatedAt: now,
        updatedAt: now,
      ),
    );
    batch.insert(
      database.cropIrrigationRules,
      CropIrrigationRulesCompanion.insert(
        id: 'rule-1',
        cropId: 'crop-official-1',
        soilTypeCode: 'medium',
        version: 1,
        soilMultiplierPermille: 1000,
        efficiencyPermille: 900,
        minimumDurationMinutes: 10,
        maximumDurationMinutes: 120,
        sourceTitle: 'Fixture',
        sourceReference: 'fixture-v9',
      ),
    );
    batch.insert(
      database.irrigationEstimates,
      IrrigationEstimatesCompanion.insert(
        id: 'estimate-1',
        ownerId: 'owner-1',
        sectorId: 'sector-1',
        ruleId: 'rule-1',
        ruleVersion: 1,
        soilTypeCode: 'medium',
        inputsJson: '{}',
        estimatedLitersMilli: 100000,
        recommendedMinutes: 30,
        createdAt: now,
      ),
    );
    batch.insert(
      database.productionRecords,
      ProductionRecordsCompanion.insert(
        id: 'production-1',
        ownerId: 'owner-1',
        parcelId: 'parcel-1',
        sectorId: 'sector-1',
        cropId: 'crop-official-1',
        quantity: 10,
        unit: 'kg',
        harvestedAt: now,
        updatedAt: now,
      ),
    );
    batch.insert(
      database.photoAttachments,
      PhotoAttachmentsCompanion.insert(
        id: 'photo-1',
        ownerId: 'owner-1',
        aggregateType: 'labor',
        aggregateId: 'labor-1',
        localPath: 'fixture/photo.jpg',
        contentHash: 'fixture-hash',
        mimeType: 'image/jpeg',
        capturedAt: now,
      ),
    );
    batch.insert(
      database.reminders,
      RemindersCompanion.insert(
        id: 'reminder-1',
        ownerId: 'owner-1',
        sectorId: const Value('sector-1'),
        title: 'Revisar sector',
        scheduledAt: now.add(const Duration(days: 1)),
        updatedAt: now,
      ),
    );
    batch.insert(
      database.deviceInstallations,
      DeviceInstallationsCompanion.insert(
        id: 'device-1',
        ownerId: 'owner-1',
        fcmToken: 'fixture-token',
        updatedAt: now,
      ),
    );
    batch.insert(
      database.apiaryInspections,
      ApiaryInspectionsCompanion.insert(
        id: 'apiary-1',
        ownerId: 'owner-1',
        sectorId: 'sector-1',
        taskType: 'inspection',
        beekeeperName: 'Apicultora',
        hiveCount: 2,
        queenStatus: 'present',
        broodStatus: 'normal',
        feedingStatus: 'not_required',
        healthNotes: 'Sin novedades',
        pestNotes: 'Sin plagas',
        superInstalled: false,
        inspectedAt: now,
        updatedAt: now,
      ),
    );
    batch.insert(
      database.weatherCache,
      WeatherCacheCompanion.insert(
        id: 'weather-1',
        ownerId: 'owner-1',
        locality: 'Santiago',
        payloadJson: '{}',
        fetchedAt: now,
      ),
    );
    batch.insert(
      database.aiMessages,
      AiMessagesCompanion.insert(
        id: 'message-1',
        ownerId: 'owner-1',
        role: 'user',
        content: 'Consulta fixture',
        createdAt: now,
      ),
    );
    batch.insert(
      database.exportSnapshots,
      ExportSnapshotsCompanion.insert(
        id: 'export-1',
        ownerId: 'owner-1',
        status: 'ready',
        manifestJson: '{}',
        createdAt: now,
      ),
    );
    batch.insert(
      database.formDrafts,
      FormDraftsCompanion.insert(
        ownerId: 'owner-1',
        draftKey: 'labor',
        payloadJson: '{}',
        updatedAt: now,
      ),
    );
    batch.insert(
      database.syncCursors,
      SyncCursorsCompanion.insert(
        ownerId: 'owner-1',
        stream: 'owner-changes-v1',
        updatedAt: now,
      ),
    );
    batch.insert(
      database.syncConflicts,
      SyncConflictsCompanion.insert(
        conflictId: 'conflict-1',
        ownerId: 'owner-1',
        aggregateType: 'parcel',
        aggregateId: 'parcel-1',
        localJson: '{}',
        remoteJson: '{}',
        detectedAt: now,
      ),
    );
    batch.insert(
      database.syncOutbox,
      SyncOutboxCompanion.insert(
        operationId: 'operation-1',
        ownerId: 'owner-1',
        aggregateType: 'parcel',
        aggregateId: 'parcel-1',
        mutationKind: 'update',
        payloadJson: '{}',
        createdAt: now,
      ),
    );
  });
}

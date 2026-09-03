part of '../app_database.dart';

Future<void> _upgradeFunctionalCoreV10(
  AppDatabase database,
  Migrator migrator,
) async {
  await migrator.createTable(database.agriculturalSeasons);
  await migrator.createTable(database.sectorIrrigationConfigs);

  await migrator.addColumn(database.syncOutbox, database.syncOutbox.deviceId);
  await migrator.addColumn(
    database.syncOutbox,
    database.syncOutbox.protocolVersion,
  );
  await migrator.addColumn(
    database.syncOutbox,
    database.syncOutbox.payloadSchemaVersion,
  );
  await migrator.addColumn(
    database.syncOutbox,
    database.syncOutbox.requestHash,
  );
  await migrator.addColumn(
    database.syncOutbox,
    database.syncOutbox.lastAttemptedAt,
  );
  await migrator.addColumn(
    database.syncOutbox,
    database.syncOutbox.completedAt,
  );

  await migrator.addColumn(
    database.syncConflicts,
    database.syncConflicts.baseJson,
  );
  await migrator.addColumn(
    database.syncConflicts,
    database.syncConflicts.remoteVersion,
  );
  await migrator.addColumn(
    database.syncConflicts,
    database.syncConflicts.sourceOperationId,
  );
  await migrator.addColumn(
    database.syncConflicts,
    database.syncConflicts.state,
  );
  await migrator.addColumn(
    database.syncConflicts,
    database.syncConflicts.resolutionChoice,
  );
  await migrator.addColumn(
    database.syncConflicts,
    database.syncConflicts.resolutionOperationId,
  );
  await migrator.addColumn(
    database.syncConflicts,
    database.syncConflicts.errorCode,
  );

  await _addSyncColumns(migrator, database.parcels, [
    database.parcels.syncState,
    database.parcels.serverUpdatedAt,
    database.parcels.lastSyncErrorCode,
  ]);
  await _addSyncColumns(migrator, database.sectors, [
    database.sectors.syncState,
    database.sectors.serverUpdatedAt,
    database.sectors.lastSyncErrorCode,
  ]);

  for (final column in [
    database.customCrops.normalizedName,
    database.customCrops.description,
    database.customCrops.archivedAt,
    database.customCrops.version,
    database.customCrops.syncState,
    database.customCrops.serverUpdatedAt,
    database.customCrops.lastSyncErrorCode,
    database.customCrops.deletedAt,
  ]) {
    await migrator.addColumn(database.customCrops, column);
  }
  for (final column in [
    database.cropSeasons.agriculturalSeasonId,
    database.cropSeasons.notes,
    database.cropSeasons.version,
    database.cropSeasons.syncState,
    database.cropSeasons.serverUpdatedAt,
    database.cropSeasons.lastSyncErrorCode,
    database.cropSeasons.deletedAt,
  ]) {
    await migrator.addColumn(database.cropSeasons, column);
  }
  for (final column in [
    database.labors.cropAssignmentId,
    database.labors.detailsSchemaVersion,
    database.labors.status,
    database.labors.supersedesLaborId,
    database.labors.version,
    database.labors.syncState,
    database.labors.serverUpdatedAt,
    database.labors.lastSyncErrorCode,
    database.labors.deletedAt,
  ]) {
    await migrator.addColumn(database.labors, column);
  }
  for (final column in [
    database.irrigationRecords.laborId,
    database.irrigationRecords.configId,
    database.irrigationRecords.configVersion,
    database.irrigationRecords.durationSeconds,
    database.irrigationRecords.appliedVolumeMl,
    database.irrigationRecords.performedDetailsJson,
  ]) {
    await migrator.addColumn(database.irrigationRecords, column);
  }
  for (final column in [
    database.irrigationEstimates.irrigationLaborId,
    database.irrigationEstimates.cropAssignmentId,
    database.irrigationEstimates.configId,
    database.irrigationEstimates.configVersion,
    database.irrigationEstimates.algorithmVersion,
    database.irrigationEstimates.explanationJson,
    database.irrigationEstimates.calculatedAt,
  ]) {
    await migrator.addColumn(database.irrigationEstimates, column);
  }
  await migrator.addColumn(
    database.productionRecords,
    database.productionRecords.laborId,
  );
  for (final column in [
    database.cropIrrigationRules.reviewer,
    database.cropIrrigationRules.approvedVectorCount,
    database.cropIrrigationRules.baseMlPerPlant,
    database.cropIrrigationRules.minimumAdjustmentBp,
    database.cropIrrigationRules.maximumAdjustmentBp,
  ]) {
    await migrator.addColumn(database.cropIrrigationRules, column);
  }
  for (final column in [
    database.reminders.parcelId,
    database.reminders.description,
    database.reminders.sourceTimeZone,
    database.reminders.status,
    database.reminders.completedAt,
    database.reminders.cancelledAt,
    database.reminders.androidNotificationId,
    database.reminders.notificationState,
    database.reminders.version,
    database.reminders.syncState,
    database.reminders.serverUpdatedAt,
    database.reminders.lastSyncErrorCode,
    database.reminders.deletedAt,
  ]) {
    await migrator.addColumn(database.reminders, column);
  }
  for (final column in [
    database.weatherCache.parcelId,
    database.weatherCache.provider,
    database.weatherCache.observedAt,
    database.weatherCache.expiresAt,
    database.weatherCache.attribution,
    database.weatherCache.errorCode,
  ]) {
    await migrator.addColumn(database.weatherCache, column);
  }
  for (final column in [
    database.aiMessages.clientMessageId,
    database.aiMessages.state,
    database.aiMessages.replyToClientMessageId,
    database.aiMessages.remoteResponseId,
    database.aiMessages.policyVersion,
    database.aiMessages.errorCode,
  ]) {
    await migrator.addColumn(database.aiMessages, column);
  }

  await database.customStatement('''
    INSERT INTO agricultural_seasons (
      id, owner_id, parcel_id, name, starts_on, status,
      is_migration_backfill, version, sync_state, updated_at
    )
    SELECT
      'imported-season-' || id, owner_id, id, 'Temporada importada',
      updated_at, CASE WHEN is_archived = 1 THEN 'closed' ELSE 'active' END,
      1, 1, 'pending', updated_at
    FROM parcels
    WHERE deleted_at IS NULL
  ''');
  await database.customStatement('''
    UPDATE crop_seasons
    SET agricultural_season_id = (
      SELECT 'imported-season-' || sectors.parcel_id
      FROM sectors WHERE sectors.id = crop_seasons.sector_id
    )
    WHERE agricultural_season_id IS NULL
  ''');
  await database.customStatement('''
    UPDATE custom_crops
    SET normalized_name = lower(trim(name))
    WHERE normalized_name = ''
  ''');
  await database.customStatement('''
    UPDATE ai_messages SET client_message_id = id
    WHERE client_message_id = ''
  ''');

  for (final statement in _functionalCoreV10Indexes) {
    await database.customStatement(statement);
  }

  final orphanAssignments = await database
      .customSelect('''
        SELECT COUNT(*) AS amount FROM crop_seasons
        WHERE agricultural_season_id IS NULL
      ''')
      .map((row) => row.read<int>('amount'))
      .getSingle();
  if (orphanAssignments != 0) {
    throw StateError('v10_backfill_orphan_assignments');
  }
}

Future<void> _addSyncColumns(
  Migrator migrator,
  TableInfo<Table, Object?> table,
  List<GeneratedColumn<Object>> columns,
) async {
  for (final column in columns) {
    await migrator.addColumn(table, column);
  }
}

const _functionalCoreV10Indexes = <String>[
  'CREATE INDEX IF NOT EXISTS idx_outbox_eligible ON sync_outbox(owner_id, state, next_attempt_at, created_at)',
  'CREATE INDEX IF NOT EXISTS idx_parcels_active ON parcels(owner_id, is_active, is_archived, deleted_at)',
  'CREATE INDEX IF NOT EXISTS idx_sectors_parcel ON sectors(owner_id, parcel_id, deleted_at)',
  'CREATE INDEX IF NOT EXISTS idx_seasons_status ON agricultural_seasons(owner_id, parcel_id, status)',
  'CREATE INDEX IF NOT EXISTS idx_assignments_sector ON crop_seasons(owner_id, sector_id, starts_on DESC)',
  'CREATE INDEX IF NOT EXISTS idx_assignments_season ON crop_seasons(owner_id, agricultural_season_id, sector_id)',
  'CREATE INDEX IF NOT EXISTS idx_labors_history ON labors(owner_id, sector_id, season_id, occurred_at DESC, type, id)',
  'CREATE INDEX IF NOT EXISTS idx_soil_history ON soil_measurements(owner_id, sector_id, measured_at DESC, id)',
  'CREATE INDEX IF NOT EXISTS idx_irrigation_config_current ON sector_irrigation_configs(owner_id, sector_id, method, effective_from DESC)',
  'CREATE UNIQUE INDEX IF NOT EXISTS idx_production_labor ON production_records(labor_id) WHERE labor_id IS NOT NULL',
];

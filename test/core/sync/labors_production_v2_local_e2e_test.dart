import 'dart:io';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/geometry/geo_point.dart';
import 'package:agrocampo/core/notifications/local_notification_scheduler.dart';
import 'package:agrocampo/core/sync/protocol/supabase_sync_gateway.dart';
import 'package:agrocampo/core/sync/sync_coordinator.dart';
import 'package:agrocampo/features/crops/data/agricultural_season_repository.dart';
import 'package:agrocampo/features/crops/data/crop_repository.dart';
import 'package:agrocampo/features/crops/data/sector_crop_assignment_repository.dart';
import 'package:agrocampo/features/crops/domain/agricultural_season.dart';
import 'package:agrocampo/features/irrigation/data/irrigation_estimate_repository.dart';
import 'package:agrocampo/features/irrigation/data/irrigation_repository.dart';
import 'package:agrocampo/features/irrigation/data/sector_irrigation_config_repository.dart';
import 'package:agrocampo/features/irrigation/domain/irrigation_record.dart';
import 'package:agrocampo/features/irrigation/domain/sector_irrigation_config.dart';
import 'package:agrocampo/features/labors/data/labor_repository.dart';
import 'package:agrocampo/features/labors/domain/fertilization_details.dart';
import 'package:agrocampo/features/labors/domain/irrigation_labor_details.dart';
import 'package:agrocampo/features/labors/domain/labor_type.dart';
import 'package:agrocampo/features/labors/domain/other_labor_details.dart';
import 'package:agrocampo/features/labors/domain/phytosanitary_details.dart';
import 'package:agrocampo/features/labors/domain/pruning_details.dart';
import 'package:agrocampo/features/labors/domain/sowing_details.dart';
import 'package:agrocampo/features/parcels/data/parcel_repository.dart';
import 'package:agrocampo/features/production/data/production_repository.dart';
import 'package:agrocampo/features/production/domain/harvest_input.dart';
import 'package:agrocampo/features/reminders/data/reminder_repository.dart';
import 'package:agrocampo/features/reminders/domain/reminder.dart';
import 'package:agrocampo/features/sectors/data/sector_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test(
    'seven labor types, correction and production survive restart and sync',
    () async {
      const url = String.fromEnvironment('SUPABASE_URL');
      const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
      if (url.isEmpty || anonKey.isEmpty) return;
      final client = SupabaseClient(
        url,
        anonKey,
        authOptions: const AuthClientOptions(
          authFlowType: AuthFlowType.implicit,
        ),
      );
      addTearDown(client.dispose);
      final suffix = DateTime.now().microsecondsSinceEpoch;
      final auth = await client.auth.signUp(
        email: 'labors-e2e-$suffix@agrocampo.local',
        password: 'AgroCampo-$suffix!',
      );
      final ownerId = auth.user!.id;
      final directory = await Directory.systemTemp.createTemp('labors-v2-a-');
      final file = File('${directory.path}${Platform.pathSeparator}db.sqlite');
      var database = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(() async {
        await database.close();
        await directory.delete(recursive: true);
      });
      final parcelId = await ParcelRepository(database).save(
        ownerId: ownerId,
        name: 'Campo labores',
        isActive: true,
        boundary: const [
          GeoPoint(-38.75, -72.61),
          GeoPoint(-38.75, -72.57),
          GeoPoint(-38.71, -72.57),
          GeoPoint(-38.71, -72.61),
        ],
      );
      final sectorId = await SectorRepository(database).save(
        ownerId: ownerId,
        parcelId: parcelId,
        number: 1,
        name: 'Norte',
        polygon: const [
          GeoPoint(-38.74, -72.60),
          GeoPoint(-38.74, -72.59),
          GeoPoint(-38.73, -72.59),
          GeoPoint(-38.73, -72.60),
        ],
      );
      final seasonId = await AgriculturalSeasonRepository(database).save(
        ownerId: ownerId,
        parcelId: parcelId,
        name: '2026',
        startsOn: DateTime.utc(2026),
        endsOn: DateTime.utc(2027),
        status: AgriculturalSeasonStatus.active,
      );
      final crops = CropRepository(database);
      final cropId = await crops.createCustom(
        ownerId: ownerId,
        name: 'Ají local',
      );
      final assignmentRepository = SectorCropAssignmentRepository(database);
      final assignmentId = await assignmentRepository.plan(
        ownerId: ownerId,
        sectorId: sectorId,
        agriculturalSeasonId: seasonId,
        crop: await crops.getById(
          ownerId: ownerId,
          cropId: cropId,
          isCustom: true,
        ),
        effectiveFrom: DateTime.utc(2026),
      );
      await assignmentRepository.activate(
        ownerId: ownerId,
        assignmentId: assignmentId,
        effectiveAt: DateTime.utc(2026),
      );
      await SectorIrrigationConfigRepository(database).saveVersion(
        ownerId: ownerId,
        sectorId: sectorId,
        effectiveFrom: DateTime.utc(2026),
        input: const SectorIrrigationConfigInput(
          plantCount: 100,
          emitterCount: 200,
          flowMlMin: 4000,
        ),
      );
      final labors = LaborRepository(database);
      final occurredAt = DateTime.utc(2026, 3);
      final fertilizerId = await labors.save(
        ownerId: ownerId,
        parcelId: parcelId,
        sectorId: sectorId,
        type: LaborType.fertilization,
        occurredAt: occurredAt,
        details: const FertilizationDetails(
          product: 'Compost',
          amount: 20,
          unit: 'kg',
          applicationMethod: 'Banda',
        ).toEnvelope(),
      );
      await labors.save(
        ownerId: ownerId,
        parcelId: parcelId,
        sectorId: sectorId,
        type: LaborType.diseaseAndPestControl,
        occurredAt: occurredAt,
        details: const PhytosanitaryDetails(
          product: 'Jabón',
          target: 'Pulgón',
          dose: 2,
          unit: 'ml/L',
        ).toEnvelope(),
      );
      await labors.save(
        ownerId: ownerId,
        parcelId: parcelId,
        sectorId: sectorId,
        type: LaborType.sowing,
        occurredAt: occurredAt,
        details: const SowingDetails(seedQuantity: 4, unit: 'kg').toEnvelope(),
      );
      await labors.save(
        ownerId: ownerId,
        parcelId: parcelId,
        sectorId: sectorId,
        type: LaborType.pruning,
        occurredAt: occurredAt,
        details: const PruningDetails(
          method: 'Manual',
          plantCount: 12,
        ).toEnvelope(),
      );
      await labors.save(
        ownerId: ownerId,
        parcelId: parcelId,
        sectorId: sectorId,
        type: LaborType.irrigation,
        occurredAt: occurredAt,
        details: const IrrigationLaborDetails(
          method: 'drip',
          durationMinutes: 30,
        ).toEnvelope(),
      );
      await labors.save(
        ownerId: ownerId,
        parcelId: parcelId,
        sectorId: sectorId,
        type: LaborType.other,
        occurredAt: occurredAt,
        customName: 'Cerco',
        notes: 'Reparación',
        details: const OtherLaborDetails(
          name: 'Cerco',
          description: 'Reparación',
        ).toEnvelope(),
      );
      await labors.correct(
        ownerId: ownerId,
        originalLaborId: fertilizerId,
        details: const FertilizationDetails(
          product: 'Compost',
          amount: 25,
          unit: 'kg',
          applicationMethod: 'Banda',
        ).toEnvelope(),
      );
      await ProductionRepository(database).save(
        ownerId: ownerId,
        parcelId: parcelId,
        sectorId: sectorId,
        seasonId: seasonId,
        cropAssignmentId: assignmentId,
        input: HarvestInput(
          cropId: cropId,
          quantity: 450,
          unit: 'kg',
          harvestedAt: occurredAt,
        ),
      );
      final waterPreview = await IrrigationEstimateRepository(database)
          .calculateForSector(
            ownerId: ownerId,
            parcelId: parcelId,
            sectorId: sectorId,
            soilTypeCode: 'loamy',
            occurredAt: occurredAt,
            performedDurationSeconds: 1800,
          );
      await IrrigationRepository(database).savePerformed(
        ownerId: ownerId,
        parcelId: parcelId,
        sectorId: sectorId,
        occurredAt: occurredAt,
        preview: waterPreview,
        input: const BasicIrrigationInput(
          type: IrrigationType.drip,
          soilType: SoilType.loamy,
          durationMinutes: 30,
        ),
      );
      await ReminderRepository(database, _NoopScheduler()).save(
        ownerId: ownerId,
        input: ReminderInput(
          title: 'Revisar riego',
          scheduledAt: DateTime.utc(2027, 1),
          parcelId: parcelId,
          sectorId: sectorId,
        ),
      );
      await database.close();
      database = AppDatabase.forTesting(NativeDatabase(file));
      expect(
        await database.select(database.productionRecords).get(),
        hasLength(1),
      );
      expect(
        (await database.select(database.labors).get())
            .map((row) => row.type)
            .toSet(),
        containsAll(<String>{
          'fertilization',
          'diseaseAndPestControl',
          'sowing',
          'pruning',
          'irrigation',
          'other',
          'harvest',
        }),
      );

      final gateway = SupabaseSyncGateway(client);
      for (var cycle = 0; cycle < 30; cycle++) {
        await SyncCoordinator(database, gateway).synchronize(ownerId);
        final pending = await (database.select(
          database.syncOutbox,
        )..where((row) => row.state.isNotIn(const ['done']))).get();
        if (pending.isEmpty) break;
      }
      expect(
        await (database.select(
          database.syncOutbox,
        )..where((row) => row.state.isNotIn(const ['done']))).get(),
        isEmpty,
      );

      final secondDirectory = await Directory.systemTemp.createTemp(
        'labors-v2-b-',
      );
      final secondDb = AppDatabase.forTesting(
        NativeDatabase(
          File('${secondDirectory.path}${Platform.pathSeparator}db.sqlite'),
        ),
      );
      addTearDown(() async {
        await secondDb.close();
        await secondDirectory.delete(recursive: true);
      });
      await SyncCoordinator(secondDb, gateway).synchronize(ownerId);
      expect(
        await secondDb.select(secondDb.productionRecords).get(),
        hasLength(1),
      );
      expect(await secondDb.select(secondDb.labors).get(), hasLength(9));
      expect(
        await secondDb.select(secondDb.sectorIrrigationConfigs).get(),
        hasLength(1),
      );
      expect(
        await secondDb.select(secondDb.irrigationRecords).get(),
        hasLength(1),
      );
      expect(await secondDb.select(secondDb.reminders).get(), hasLength(1));
      expect(
        (await secondDb.select(secondDb.labors).get()).where(
          (row) => row.supersedesLaborId == fertilizerId,
        ),
        hasLength(1),
      );
    },
  );
}

final class _NoopScheduler implements LocalNotificationScheduler {
  @override
  Future<void> initialize() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<void> schedule({
    required int id,
    required String title,
    required DateTime scheduledAt,
    String? payload,
  }) async {}
  @override
  Future<void> cancel(int id) async {}
}

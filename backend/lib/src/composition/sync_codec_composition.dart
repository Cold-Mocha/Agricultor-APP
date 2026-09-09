import 'package:agrocampo_backend/src/modules/crop_cycles/infrastructure/sync/agricultural_season_sync_codec.dart';
import 'package:agrocampo_backend/src/modules/crop_cycles/infrastructure/sync/custom_crop_sync_codec.dart';
import 'package:agrocampo_backend/src/modules/crop_cycles/infrastructure/sync/sector_crop_assignment_sync_codec.dart';
import 'package:agrocampo_backend/src/modules/irrigation/infrastructure/sync/irrigation_sync_codec.dart';
import 'package:agrocampo_backend/src/modules/labors/infrastructure/sync/labor_sync_codec.dart';
import 'package:agrocampo_backend/src/modules/reminders/infrastructure/sync/reminder_sync_codec.dart';
import 'package:agrocampo_backend/src/modules/territory/infrastructure/sync/parcel_sync_codec.dart';
import 'package:agrocampo_backend/src/modules/territory/infrastructure/sync/sector_sync_codec.dart';
import 'package:agrocampo_backend/src/platform/sync/protocol/aggregate_sync_registry.dart';

AggregateSyncRegistry createAgroCampoSyncRegistry() =>
    AggregateSyncRegistry(const [
      ParcelSyncCodec(),
      SectorSyncCodec(),
      AgriculturalSeasonSyncCodec(),
      CustomCropSyncCodec(),
      SectorCropAssignmentSyncCodec(),
      LaborSyncCodec(),
      IrrigationConfigSyncCodec(),
      ReminderSyncCodec(),
    ]);

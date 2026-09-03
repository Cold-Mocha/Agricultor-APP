import 'package:agrocampo/core/sync/protocol/aggregate_sync_codec.dart';
import 'package:agrocampo/core/sync/protocol/agricultural_season_sync_codec.dart';
import 'package:agrocampo/core/sync/protocol/custom_crop_sync_codec.dart';
import 'package:agrocampo/core/sync/protocol/irrigation_sync_codec.dart';
import 'package:agrocampo/core/sync/protocol/labor_sync_codec.dart';
import 'package:agrocampo/core/sync/protocol/parcel_sync_codec.dart';
import 'package:agrocampo/core/sync/protocol/reminder_sync_codec.dart';
import 'package:agrocampo/core/sync/protocol/sector_crop_assignment_sync_codec.dart';
import 'package:agrocampo/core/sync/protocol/sector_sync_codec.dart';

final class AggregateSyncRegistry {
  AggregateSyncRegistry([Iterable<AggregateSyncCodec>? codecs])
    : _codecs = {
        for (final codec
            in codecs ??
                const [
                  ParcelSyncCodec(),
                  SectorSyncCodec(),
                  AgriculturalSeasonSyncCodec(),
                  CustomCropSyncCodec(),
                  SectorCropAssignmentSyncCodec(),
                  LaborSyncCodec(),
                  IrrigationConfigSyncCodec(),
                  ReminderSyncCodec(),
                ])
          codec.aggregateType: codec,
      };

  final Map<String, AggregateSyncCodec> _codecs;

  AggregateSyncCodec require(String aggregateType) {
    final codec = _codecs[aggregateType];
    if (codec == null) {
      throw StateError('unsupported_sync_aggregate:$aggregateType');
    }
    return codec;
  }

  bool supports(String aggregateType) => _codecs.containsKey(aggregateType);
}

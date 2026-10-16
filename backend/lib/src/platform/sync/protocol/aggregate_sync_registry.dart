import 'package:agrocampo_backend/src/platform/sync/protocol/aggregate_sync_codec.dart';

final class AggregateSyncRegistry {
  AggregateSyncRegistry(Iterable<AggregateSyncCodec> codecs)
    : _codecs = {for (final codec in codecs) codec.aggregateType: codec};

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

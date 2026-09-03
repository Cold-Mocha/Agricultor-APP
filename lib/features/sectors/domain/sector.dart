import 'package:agrocampo/core/geometry/geo_point.dart';

final class Sector {
  const Sector({
    required this.id,
    required this.ownerId,
    required this.parcelId,
    required this.number,
    required this.name,
    required this.kind,
    required this.polygon,
    required this.areaSquareMeters,
    required this.version,
    required this.syncState,
    this.deletedAt,
  });

  final String id;
  final String ownerId;
  final String parcelId;
  final int number;
  final String name;
  final String kind;
  final List<GeoPoint> polygon;
  final double areaSquareMeters;
  final int version;
  final String syncState;
  final DateTime? deletedAt;
}

import 'package:agrocampo_backend/src/modules/territory/domain/value_objects/geo_point.dart';

final class MapSectorGeometry {
  const MapSectorGeometry({
    required this.id,
    required this.number,
    required this.name,
    required this.kind,
    required this.polygon,
  });

  final String id;
  final int number;
  final String name;
  final String kind;
  final List<GeoPoint> polygon;
}

/// Minimal sector projection exposed to context coordination.
final class TerritoryContextSector {
  const TerritoryContextSector({
    required this.id,
    required this.parcelId,
    required this.name,
  });

  final String id;
  final String parcelId;
  final String name;
}

final class MapGeometryFormInput {
  const MapGeometryFormInput({
    required this.parcelId,
    required this.polygon,
    this.sectorId,
  });

  final String parcelId;
  final String? sectorId;
  final List<GeoPoint> polygon;
}

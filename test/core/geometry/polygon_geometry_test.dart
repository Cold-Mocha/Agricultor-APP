import 'package:agrocampo/core/geometry/geo_point.dart';
import 'package:agrocampo/core/geometry/polygon_geometry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const parent = [
    GeoPoint(-38.74, -72.60),
    GeoPoint(-38.74, -72.59),
    GeoPoint(-38.73, -72.59),
    GeoPoint(-38.73, -72.60),
  ];
  const child = [
    GeoPoint(-38.739, -72.599),
    GeoPoint(-38.739, -72.595),
    GeoPoint(-38.735, -72.595),
    GeoPoint(-38.735, -72.599),
  ];

  test('area is deterministic and positive', () {
    final first = PolygonGeometry.areaSquareMeters(parent);
    final second = PolygonGeometry.areaSquareMeters(parent);
    expect(first, greaterThan(900000));
    expect(second, first);
  });

  test('sector containment rejects vertices outside parcel', () {
    expect(PolygonGeometry.isContained(child, parent), isTrue);
    expect(
      PolygonGeometry.isContained([
        ...child,
        const GeoPoint(-38.70, -72.50),
      ], parent),
      isFalse,
    );
  });
}

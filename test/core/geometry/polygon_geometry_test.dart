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

  test('normalizes closing/consecutive duplicates without mutating input', () {
    final source = [parent.first, parent.first, ...parent, parent.first];
    final normalized = PolygonGeometry.normalize(source);
    expect(normalized, hasLength(4));
    expect(source, hasLength(7));
  });

  test('rejects repeated vertices, self intersections and zero area', () {
    expect(
      PolygonGeometry.validationError([
        parent[0],
        parent[1],
        parent[2],
        parent[1],
      ]),
      'polygon_has_duplicate_points',
    );
    expect(
      PolygonGeometry.validationError([
        parent[0],
        parent[2],
        parent[1],
        parent[3],
      ]),
      'polygon_self_intersects',
    );
    expect(
      PolygonGeometry.validationError(const [
        GeoPoint(-38.74, -72.60),
        GeoPoint(-38.74, -72.59),
        GeoPoint(-38.74, -72.58),
      ]),
      'polygon_area_zero',
    );
  });
}

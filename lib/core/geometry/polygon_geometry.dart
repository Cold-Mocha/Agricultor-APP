import 'dart:math' as math;

import 'package:agrocampo/core/geometry/geo_point.dart';

abstract final class PolygonGeometry {
  static const _earthRadiusMeters = 6371008.8;

  static double areaSquareMeters(List<GeoPoint> polygon) {
    if (polygon.length < 3) return 0;
    final latitudeOrigin =
        polygon.map((point) => point.latitude).reduce((a, b) => a + b) /
        polygon.length;
    final cosOrigin = math.cos(latitudeOrigin * math.pi / 180);
    var twiceArea = 0.0;
    for (var index = 0; index < polygon.length; index++) {
      final current = polygon[index];
      final next = polygon[(index + 1) % polygon.length];
      final currentX =
          current.longitude * math.pi / 180 * _earthRadiusMeters * cosOrigin;
      final currentY = current.latitude * math.pi / 180 * _earthRadiusMeters;
      final nextX =
          next.longitude * math.pi / 180 * _earthRadiusMeters * cosOrigin;
      final nextY = next.latitude * math.pi / 180 * _earthRadiusMeters;
      twiceArea += currentX * nextY - nextX * currentY;
    }
    return twiceArea.abs() / 2;
  }

  static bool contains(GeoPoint point, List<GeoPoint> polygon) {
    if (polygon.length < 3) return false;
    var inside = false;
    for (
      var current = 0, previous = polygon.length - 1;
      current < polygon.length;
      previous = current++
    ) {
      final a = polygon[current];
      final b = polygon[previous];
      final crosses =
          (a.latitude > point.latitude) != (b.latitude > point.latitude) &&
          point.longitude <
              (b.longitude - a.longitude) *
                      (point.latitude - a.latitude) /
                      (b.latitude - a.latitude) +
                  a.longitude;
      if (crosses) inside = !inside;
    }
    return inside;
  }

  static bool isContained(List<GeoPoint> child, List<GeoPoint> parent) =>
      child.length >= 3 && child.every((point) => contains(point, parent));
}

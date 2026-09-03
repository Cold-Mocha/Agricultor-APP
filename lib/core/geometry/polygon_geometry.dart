import 'dart:math' as math;

import 'package:agrocampo/core/geometry/geo_point.dart';

abstract final class PolygonGeometry {
  static const _earthRadiusMeters = 6371008.8;
  static const _epsilon = 1e-10;

  static List<GeoPoint> normalize(List<GeoPoint> polygon) {
    final normalized = <GeoPoint>[];
    for (final point in polygon) {
      if (!point.latitude.isFinite ||
          !point.longitude.isFinite ||
          point.latitude < -90 ||
          point.latitude > 90 ||
          point.longitude < -180 ||
          point.longitude > 180) {
        throw ArgumentError.value(point, 'polygon', 'coordinate_out_of_range');
      }
      if (normalized.isEmpty || !_samePoint(normalized.last, point)) {
        normalized.add(point);
      }
    }
    if (normalized.length > 1 &&
        _samePoint(normalized.first, normalized.last)) {
      normalized.removeLast();
    }
    return List.unmodifiable(normalized);
  }

  static String? validationError(List<GeoPoint> source) {
    List<GeoPoint> polygon;
    try {
      polygon = normalize(source);
    } on ArgumentError {
      return 'coordinate_out_of_range';
    }
    if (polygon.length < 3) return 'polygon_requires_three_points';
    for (var index = 0; index < polygon.length; index++) {
      for (var other = index + 1; other < polygon.length; other++) {
        if (_samePoint(polygon[index], polygon[other])) {
          return 'polygon_has_duplicate_points';
        }
      }
    }
    if (hasSelfIntersections(polygon)) return 'polygon_self_intersects';
    if (areaSquareMeters(polygon) <= .01) return 'polygon_area_zero';
    return null;
  }

  static bool hasSelfIntersections(List<GeoPoint> source) {
    final polygon = normalize(source);
    for (var first = 0; first < polygon.length; first++) {
      final firstNext = (first + 1) % polygon.length;
      for (var second = first + 1; second < polygon.length; second++) {
        final secondNext = (second + 1) % polygon.length;
        if (first == second || firstNext == second || secondNext == first) {
          continue;
        }
        if (_segmentsIntersect(
          polygon[first],
          polygon[firstNext],
          polygon[second],
          polygon[secondNext],
        )) {
          return true;
        }
      }
    }
    return false;
  }

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
      validationError(child) == null &&
      validationError(parent) == null &&
      child.every((point) => contains(point, parent)) &&
      !_boundariesIntersect(child, parent);

  static bool _samePoint(GeoPoint a, GeoPoint b) =>
      (a.latitude - b.latitude).abs() < _epsilon &&
      (a.longitude - b.longitude).abs() < _epsilon;

  static double _orientation(GeoPoint a, GeoPoint b, GeoPoint c) =>
      (b.longitude - a.longitude) * (c.latitude - a.latitude) -
      (b.latitude - a.latitude) * (c.longitude - a.longitude);

  static bool _segmentsIntersect(
    GeoPoint a,
    GeoPoint b,
    GeoPoint c,
    GeoPoint d,
  ) {
    final o1 = _orientation(a, b, c);
    final o2 = _orientation(a, b, d);
    final o3 = _orientation(c, d, a);
    final o4 = _orientation(c, d, b);
    return ((o1 > _epsilon && o2 < -_epsilon) ||
            (o1 < -_epsilon && o2 > _epsilon)) &&
        ((o3 > _epsilon && o4 < -_epsilon) ||
            (o3 < -_epsilon && o4 > _epsilon));
  }

  static bool _boundariesIntersect(
    List<GeoPoint> child,
    List<GeoPoint> parent,
  ) {
    for (var childIndex = 0; childIndex < child.length; childIndex++) {
      for (var parentIndex = 0; parentIndex < parent.length; parentIndex++) {
        if (_segmentsIntersect(
          child[childIndex],
          child[(childIndex + 1) % child.length],
          parent[parentIndex],
          parent[(parentIndex + 1) % parent.length],
        )) {
          return true;
        }
      }
    }
    return false;
  }
}

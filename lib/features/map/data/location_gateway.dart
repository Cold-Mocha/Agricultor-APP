import 'package:agrocampo/core/geometry/geo_point.dart';
import 'package:geolocator/geolocator.dart';

abstract interface class LocationGateway {
  Future<GeoPoint> currentPosition();
}

final class GeolocatorLocationGateway implements LocationGateway {
  @override
  Future<GeoPoint> currentPosition() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw StateError('location_permission_denied');
    }
    final position = await Geolocator.getCurrentPosition();
    return GeoPoint(position.latitude, position.longitude);
  }
}

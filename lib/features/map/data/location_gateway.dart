import 'package:agrocampo/core/geometry/geo_point.dart';
import 'package:geolocator/geolocator.dart';

abstract interface class LocationGateway {
  Future<GeoPoint> currentPosition();
}

final class GeolocatorLocationGateway implements LocationGateway {
  GeolocatorLocationGateway([LocationPlatform? platform])
    : _platform = platform ?? const GeolocatorPlatformAdapter();

  final LocationPlatform _platform;

  @override
  Future<GeoPoint> currentPosition() async {
    if (!await _platform.isServiceEnabled()) {
      throw StateError('location_service_disabled');
    }
    var permission = await _platform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _platform.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw StateError('location_permission_denied');
    }
    final position = await _platform.currentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
    return GeoPoint(position.latitude, position.longitude);
  }
}

abstract interface class LocationPlatform {
  Future<bool> isServiceEnabled();
  Future<LocationPermission> checkPermission();
  Future<LocationPermission> requestPermission();
  Future<Position> currentPosition({
    required LocationSettings locationSettings,
  });
}

final class GeolocatorPlatformAdapter implements LocationPlatform {
  const GeolocatorPlatformAdapter();

  @override
  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  @override
  Future<LocationPermission> checkPermission() => Geolocator.checkPermission();

  @override
  Future<LocationPermission> requestPermission() =>
      Geolocator.requestPermission();

  @override
  Future<Position> currentPosition({
    required LocationSettings locationSettings,
  }) => Geolocator.getCurrentPosition(locationSettings: locationSettings);
}

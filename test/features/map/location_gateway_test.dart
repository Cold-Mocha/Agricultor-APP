import 'package:agrocampo/features/map/data/location_gateway.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  test(
    'returns a precise position when service and permission are available',
    () async {
      final gateway = GeolocatorLocationGateway(
        _FakeLocationPlatform(permission: LocationPermission.whileInUse),
      );
      final point = await gateway.currentPosition();
      expect(point.latitude, -38.7397);
      expect(point.longitude, -72.5984);
    },
  );

  test(
    'requests denied permission and preserves manual fallback on denial',
    () async {
      final platform = _FakeLocationPlatform(
        permission: LocationPermission.denied,
      );
      await expectLater(
        GeolocatorLocationGateway(platform).currentPosition(),
        throwsA(isA<StateError>()),
      );
      expect(platform.requested, isTrue);
    },
  );

  test('reports disabled service without requesting permission', () async {
    final platform = _FakeLocationPlatform(
      permission: LocationPermission.whileInUse,
      serviceEnabled: false,
    );
    await expectLater(
      GeolocatorLocationGateway(platform).currentPosition(),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'location_service_disabled',
        ),
      ),
    );
    expect(platform.requested, isFalse);
  });
}

final class _FakeLocationPlatform implements LocationPlatform {
  _FakeLocationPlatform({required this.permission, this.serviceEnabled = true});

  LocationPermission permission;
  final bool serviceEnabled;
  bool requested = false;

  @override
  Future<LocationPermission> checkPermission() async => permission;

  @override
  Future<Position> currentPosition({
    required LocationSettings locationSettings,
  }) async => Position(
    longitude: -72.5984,
    latitude: -38.7397,
    timestamp: DateTime.utc(2026, 8, 29),
    accuracy: 3,
    altitude: 0,
    altitudeAccuracy: 1,
    heading: 0,
    headingAccuracy: 1,
    speed: 0,
    speedAccuracy: 1,
  );

  @override
  Future<bool> isServiceEnabled() async => serviceEnabled;

  @override
  Future<LocationPermission> requestPermission() async {
    requested = true;
    return permission;
  }
}

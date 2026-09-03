import 'dart:io';

import 'package:agrocampo/core/auth/biometric_unlock_gateway.dart';
import 'package:agrocampo/core/notifications/local_notification_scheduler.dart';
import 'package:agrocampo/core/sync/sync_scheduler.dart';
import 'package:agrocampo/features/map/data/location_gateway.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:integration_test/integration_test.dart';
import 'package:local_auth/local_auth.dart';

import 'android_map_device_test.dart' as map_device;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  map_device.main();

  testWidgets(
    'Android exposes biometric capability and covers success cancel unavailable',
    (tester) async {
      expect(Platform.isAndroid, isTrue);
      final pluginGateway = LocalAuthBiometricUnlockGateway();
      final capability = await pluginGateway.isAvailable();
      expect(capability, isA<bool>());

      const interactiveExpectation = String.fromEnvironment(
        'AGROCAMPO_BIOMETRIC_EXPECTED',
        defaultValue: 'capability',
      );
      if (interactiveExpectation == 'success') {
        expect(
          await pluginGateway.authenticate(),
          BiometricUnlockResult.success,
          reason: 'Autentica con la biometría cuando aparezca el diálogo.',
        );
      } else if (interactiveExpectation == 'cancelled') {
        expect(
          await pluginGateway.authenticate(),
          BiometricUnlockResult.cancelled,
          reason: 'Cancela el diálogo biométrico cuando aparezca.',
        );
      }

      expect(
        await LocalAuthBiometricUnlockGateway(
          _BiometricDriver(supported: false),
        ).authenticate(),
        BiometricUnlockResult.unavailable,
      );
      final mapped = _BiometricDriver(
        biometrics: const [BiometricType.fingerprint],
      );
      expect(
        await LocalAuthBiometricUnlockGateway(mapped).authenticate(),
        BiometricUnlockResult.success,
      );
      mapped.authenticated = false;
      expect(
        await LocalAuthBiometricUnlockGateway(mapped).authenticate(),
        BiometricUnlockResult.cancelled,
      );
    },
  );

  testWidgets(
    'Android keeps manual map flow available for denied or disabled GPS',
    (tester) async {
      await expectLater(
        GeolocatorLocationGateway(
          _LocationDriver(
            permission: LocationPermission.denied,
            requestedPermission: LocationPermission.denied,
          ),
        ).currentPosition(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'location_permission_denied',
          ),
        ),
      );
      await expectLater(
        GeolocatorLocationGateway(
          _LocationDriver(
            permission: LocationPermission.whileInUse,
            serviceEnabled: false,
          ),
        ).currentPosition(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'location_service_disabled',
          ),
        ),
      );
      expect(await Geolocator.isLocationServiceEnabled(), isA<bool>());
    },
  );

  testWidgets(
    'Android schedules inexact reminders and registers WorkManager safely',
    (tester) async {
      final scheduler = PluginLocalNotificationScheduler();
      await scheduler.initialize();
      expect(await scheduler.requestPermission(), isTrue);
      const notificationId = 2002115;
      await scheduler.schedule(
        id: notificationId,
        title: 'Validación AgroCampo',
        scheduledAt: DateTime.now().add(const Duration(hours: 2)),
        payload: '/mas/recordatorios/device-test',
      );
      final plugin = FlutterLocalNotificationsPlugin();
      final pending = await plugin.pendingNotificationRequests();
      expect(pending.map((request) => request.id), contains(notificationId));
      await scheduler.cancel(notificationId);
      expect(
        (await plugin.pendingNotificationRequests()).map(
          (request) => request.id,
        ),
        isNot(contains(notificationId)),
      );

      final workManager = WorkManagerSyncScheduler();
      await workManager.initialize();
      await workManager.schedule(ownerId: 'android-platform-test-owner');
      await workManager.cancel(ownerId: 'android-platform-test-owner');
    },
  );
}

final class _BiometricDriver implements LocalAuthDriver {
  _BiometricDriver({this.supported = true, this.biometrics = const []});

  final bool supported;
  final List<BiometricType> biometrics;
  bool authenticated = true;

  @override
  Future<bool> authenticate() async => authenticated;

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async => biometrics;

  @override
  Future<bool> isDeviceSupported() async => supported;
}

final class _LocationDriver implements LocationPlatform {
  _LocationDriver({
    required this.permission,
    this.requestedPermission,
    this.serviceEnabled = true,
  });

  final LocationPermission permission;
  final LocationPermission? requestedPermission;
  final bool serviceEnabled;

  @override
  Future<LocationPermission> checkPermission() async => permission;

  @override
  Future<Position> currentPosition({
    required LocationSettings locationSettings,
  }) async => Position(
    longitude: -72.5984,
    latitude: -38.7397,
    timestamp: DateTime.utc(2026, 8, 30),
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
  Future<LocationPermission> requestPermission() async =>
      requestedPermission ?? permission;
}

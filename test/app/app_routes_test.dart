import 'package:agrocampo/app/routing/app_router.dart';
import 'package:agrocampo/app/routing/app_routes.dart';
import 'package:agrocampo/features/auth/domain/session_state.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/labors/domain/labor_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('context routes preserve ids and labor type', () {
    expect(
      AppRoutes.quadrantMap('parcel 1'),
      '/sectores/parcela/parcel%201/mapa',
    );
    expect(AppRoutes.sector('sector 1'), '/sectores/sector%201');
    expect(
      AppRoutes.labor(LaborType.diseaseAndPestControl, sectorId: 'sector 1'),
      '/registrar/labor/diseaseAndPestControl?sectorId=sector+1',
    );
    expect(
      AppRoutes.irrigationFor(sectorId: 'sector-1'),
      '/registrar/riego?sectorId=sector-1',
    );
  });

  test('empty sector context is omitted from routes', () {
    expect(AppRoutes.soilFor(), AppRoutes.soil);
    expect(AppRoutes.registerFor(sectorId: ''), AppRoutes.register);
  });

  test(
    'every canonical secondary route resolves for a signed-in owner',
    () async {
      final container = ProviderContainer(
        overrides: [
          sessionControllerProvider.overrideWithBuild(
            (ref, notifier) => const SessionState.signedIn('owner-1'),
          ),
        ],
      );
      addTearDown(container.dispose);
      final router = container.read(appRouterProvider);
      addTearDown(router.dispose);
      final locations = [
        AppRoutes.profile,
        AppRoutes.profileNotifications,
        AppRoutes.newParcel,
        AppRoutes.quadrantMap('parcel-1'),
        AppRoutes.sector('sector-1'),
        AppRoutes.sectorRotation('sector-1'),
        AppRoutes.sectorHistory('sector-1'),
        AppRoutes.labor(LaborType.fertilization, sectorId: 'sector-1'),
        AppRoutes.soilFor(sectorId: 'sector-1'),
        AppRoutes.irrigationFor(sectorId: 'sector-1'),
        AppRoutes.irrigationConfigurationFor(sectorId: 'sector-1'),
        AppRoutes.productionFor(sectorId: 'sector-1'),
        AppRoutes.photoFor(sectorId: 'sector-1'),
        AppRoutes.seasons,
        AppRoutes.cropCatalog,
        AppRoutes.history,
        AppRoutes.reminders,
        AppRoutes.synchronization,
        AppRoutes.conflict('conflict-1'),
        AppRoutes.export,
        AppRoutes.settings,
      ];

      for (final location in locations) {
        router.go(location);
        await Future<void>.delayed(Duration.zero);
        expect(
          router.routerDelegate.currentConfiguration.isError,
          isFalse,
          reason: 'No resolvió $location',
        );
      }
    },
  );
}

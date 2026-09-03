import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/theme/agro_theme.dart';
import 'package:agrocampo/core/network/connectivity_service.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/sectors/presentation/sector_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';
import '../../helpers/territory_fixture.dart';

final class _OnlineConnectivity implements ConnectivityService {
  @override
  Stream<ConnectionSignal> watch() => Stream.value(ConnectionSignal.available);
}

void main() {
  testWidgets('Sectores presents stored models as quadrant cards and map', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final database = createInMemoryDatabase();
    await seedAgriculturalContextFixture(database);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          unlockedOwnerIdProvider.overrideWithValue('owner-1'),
          connectivityServiceProvider.overrideWithValue(_OnlineConnectivity()),
        ],
        child: MaterialApp(
          theme: AgroTheme.light,
          home: const SectorListPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cuadrantes'), findsOneWidget);
    expect(find.text('Cuadrante 1'), findsOneWidget);
    expect(find.text('Trigo'), findsOneWidget);
    expect(find.text('Cultivo activo'), findsOneWidget);
    expect(find.text('Mapa de cuadrantes'), findsWidgets);
    expect(find.text('Resumen del historial'), findsOneWidget);
    expect(find.textContaining('sector-1'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await database.close();
  });
}

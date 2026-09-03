import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/theme/agro_theme.dart';
import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/network/connectivity_service.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/profile/presentation/profile_page.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

final class _OnlineConnectivity implements ConnectivityService {
  @override
  Stream<ConnectionSignal> watch() => Stream.value(ConnectionSignal.available);
}

void main() {
  testWidgets('Perfil shows stored identity, location and coherent groups', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final database = createInMemoryDatabase();
    await database
        .into(database.localProfiles)
        .insert(
          LocalProfilesCompanion.insert(
            id: 'owner-1',
            displayName: 'María Soto',
            emailDisplay: const Value('maria@example.com'),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    await database
        .into(database.parcels)
        .insert(
          ParcelsCompanion.insert(
            id: 'parcel-1',
            ownerId: 'owner-1',
            name: 'Parcela',
            locality: const Value('Curicó'),
            isActive: const Value(true),
            updatedAt: DateTime.now().toUtc(),
          ),
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          unlockedOwnerIdProvider.overrideWithValue('owner-1'),
          connectivityServiceProvider.overrideWithValue(_OnlineConnectivity()),
        ],
        child: MaterialApp(theme: AgroTheme.light, home: const ProfilePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('María Soto'), findsOneWidget);
    expect(find.text('maria@example.com'), findsOneWidget);
    expect(find.text('Curicó'), findsWidgets);
    expect(find.text('Información personal'), findsOneWidget);
    expect(find.text('Notificaciones'), findsOneWidget);
    expect(find.text('Seguridad y biometría'), findsOneWidget);
    expect(find.text('Ayuda y soporte'), findsOneWidget);
    expect(find.text('Contacto'), findsOneWidget);
    expect(find.text('Privacidad'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await database.close();
  });
}

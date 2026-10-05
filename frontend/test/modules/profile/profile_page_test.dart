import 'package:agrocampo/src/app/theme/agro_theme.dart';
import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo/src/modules/profile/presentation/pages/profile_page.dart';
import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:agrocampo_backend/src/platform/network/connectivity_service.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../backend/test/helpers/in_memory_database.dart';

final class _OnlineConnectivity implements ConnectivityService {
  @override
  Stream<ConnectionSignal> watch() => Stream.value(ConnectionSignal.available);
}

void main() {
  testWidgets('Perfil shows only the login user and coherent groups', (
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
            emailDisplay: const Value('mario@agrocampo.app'),
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

    expect(find.text('Mario'), findsOneWidget);
    expect(find.text('María Soto'), findsNothing);
    expect(find.textContaining('@'), findsNothing, reason: 'no email shown');
    expect(find.textContaining('propietario'), findsNothing);
    expect(find.byTooltip('Editar información personal'), findsNothing);
    expect(find.text('Ubicación'), findsNothing);
    expect(find.textContaining('parcela'), findsNothing);
    expect(find.text('Información personal'), findsNothing);
    expect(find.text('Notificaciones'), findsOneWidget);
    expect(find.text('Tema'), findsOneWidget);
    for (final removed in const [
      'Idioma',
      'Seguridad y biometría',
      'Ayuda y soporte',
      'Contacto',
      'Privacidad',
      'Estado del respaldo',
    ]) {
      expect(find.text(removed), findsNothing, reason: '$removed was removed');
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await database.close();
  });
}

import 'package:agrocampo/src/app/theme/agro_theme.dart';
import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo/src/modules/reminders/presentation/pages/reminders_page.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:agrocampo_backend/src/platform/network/connectivity_service.dart';
import 'package:agrocampo_backend/src/platform/notifications/local_notification_scheduler.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../backend/test/helpers/in_memory_database.dart';
import '../../../../backend/test/helpers/reminder_test_payload.dart';

final class _OnlineConnectivity implements ConnectivityService {
  @override
  Stream<ConnectionSignal> watch() => Stream.value(ConnectionSignal.available);
}

final class _NoopScheduler implements LocalNotificationScheduler {
  @override
  Future<void> initialize() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<void> schedule({
    required int id,
    required String title,
    required DateTime scheduledAt,
    String? payload,
  }) async {}
  @override
  Future<void> cancel(int id) async {}
}

final class _NoopAlertNotifier implements FieldAlertNotifier {
  @override
  Future<void> show({
    required int id,
    required String title,
    String? body,
  }) async {}
}

Future<void> _pumpPage(
  WidgetTester tester, {
  required AppDatabase database,
  SessionState session = const SessionState.signedIn('owner-1'),
}) async {
  // The alerts come first; a tall surface keeps the reminders list built.
  tester.view.physicalSize = const Size(430, 2600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        connectivityServiceProvider.overrideWithValue(_OnlineConnectivity()),
        localNotificationSchedulerProvider.overrideWithValue(_NoopScheduler()),
        fieldAlertNotifierProvider.overrideWithValue(_NoopAlertNotifier()),
        reminderNotificationPayloadBuilderProvider.overrideWithValue(
          reminderTestPayload,
        ),
        sessionControllerProvider.overrideWithBuild((ref, notifier) => session),
      ],
      child: MaterialApp(theme: AgroTheme.light, home: const RemindersPage()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('disables scheduling without an active session', (tester) async {
    final database = createInMemoryDatabase();
    await _pumpPage(
      tester,
      database: database,
      session: const SessionState.signedOut(),
    );

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Programar recordatorio'),
    );
    expect(button.onPressed, isNull);
    expect(find.text('Aún no hay recordatorios'), findsNothing);
    await database.close();
  });

  testWidgets('shows the empty state before the first reminder', (
    tester,
  ) async {
    final database = createInMemoryDatabase();
    await _pumpPage(tester, database: database);

    expect(find.text('Aún no hay recordatorios'), findsOneWidget);
    await database.close();
  });

  testWidgets('lists reminders and only offers the menu on scheduled ones', (
    tester,
  ) async {
    final database = createInMemoryDatabase();
    final now = DateTime.now().toUtc();
    await database.batch((batch) {
      batch.insertAll(database.reminders, [
        RemindersCompanion.insert(
          id: 'r1',
          ownerId: 'owner-1',
          title: 'Revisar riego goteo',
          scheduledAt: now.add(const Duration(days: 1)),
          updatedAt: now,
        ),
        RemindersCompanion.insert(
          id: 'r2',
          ownerId: 'owner-1',
          title: 'Aplicar fungicida',
          scheduledAt: now.add(const Duration(days: 2)),
          status: const Value('completed'),
          updatedAt: now,
        ),
        RemindersCompanion.insert(
          id: 'r3',
          ownerId: 'owner-1',
          title: 'Rotar cuadrante 4',
          scheduledAt: now.add(const Duration(days: 3)),
          notificationState: const Value('permissionDenied'),
          updatedAt: now,
        ),
      ]);
    });

    await _pumpPage(tester, database: database);

    expect(find.text('Revisar riego goteo'), findsOneWidget);
    expect(find.text('Aplicar fungicida'), findsOneWidget);
    expect(find.text('Rotar cuadrante 4'), findsOneWidget);
    expect(
      find.textContaining('Permiso denegado; recordatorio conservado'),
      findsOneWidget,
    );
    expect(find.textContaining('Programado'), findsNWidgets(2));
    expect(find.textContaining('Completado'), findsOneWidget);
    expect(find.textContaining('scheduled'), findsNothing);
    expect(find.textContaining(RegExp(r'\d{2}:\d{2}:\d{2}\.')), findsNothing);
    // Only the two "scheduled" reminders (r1, r3) expose the action menu;
    // the completed one (r2) does not.
    expect(find.byType(PopupMenuButton<String>), findsNWidgets(2));
    await database.close();
  });

  testWidgets('editing a reminder preloads its title into the form', (
    tester,
  ) async {
    final database = createInMemoryDatabase();
    final now = DateTime.now().toUtc();
    await database
        .into(database.reminders)
        .insert(
          RemindersCompanion.insert(
            id: 'r1',
            ownerId: 'owner-1',
            title: 'Revisar riego goteo',
            description: const Value('Sector 3, línea principal'),
            scheduledAt: now.add(const Duration(days: 1)),
            updatedAt: now,
          ),
        );

    await _pumpPage(tester, database: database);
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();

    final titleField = tester.widget<TextField>(
      find.widgetWithText(TextField, 'Título').first,
    );
    expect(titleField.controller?.text, 'Revisar riego goteo');
    expect(
      find.widgetWithText(FilledButton, 'Guardar cambios'),
      findsOneWidget,
    );
    await database.close();
  });

  testWidgets('each field alert has its switch and editable threshold', (
    tester,
  ) async {
    final database = createInMemoryDatabase();
    await _pumpPage(tester, database: database);

    for (final title in const [
      'Fin de temporada',
      'Helada',
      'Temperatura baja',
      'Temperatura alta',
    ]) {
      expect(find.text(title), findsOneWidget, reason: '$title card');
    }
    expect(find.text('7 d'), findsOneWidget, reason: 'season end default');
    expect(find.text('30 °C'), findsNothing, reason: 'heat starts disabled');

    await tester.tap(find.widgetWithText(SwitchListTile, 'Temperatura alta'));
    await tester.pumpAndSettle();
    expect(find.text('30 °C'), findsOneWidget);

    await tester.tap(find.byTooltip('Subir máxima'));
    await tester.pumpAndSettle();
    expect(find.text('31 °C'), findsOneWidget);

    final saved = await tester.runAsync(
      () => database.select(database.appPreferences).get(),
    );
    expect(
      saved!.singleWhere((row) => row.key == 'field_alerts').value,
      contains('"heat":{"enabled":true,"threshold":31.0}'),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await database.close();
  });
}

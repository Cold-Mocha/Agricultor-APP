import 'package:agrocampo/src/app/theme/agro_theme.dart';
import 'package:agrocampo/src/modules/agro_ai/presentation/pages/agro_ai_page.dart';
import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:agrocampo_backend/src/platform/network/connectivity_service.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../backend/test/helpers/in_memory_database.dart';

final class _OnlineConnectivity implements ConnectivityService {
  @override
  Stream<ConnectionSignal> watch() => Stream.value(ConnectionSignal.available);
}

void main() {
  Future<AppDatabase> pumpPage(
    WidgetTester tester, {
    required AppDatabase database,
    SessionState session = const SessionState.signedIn('owner-1'),
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          connectivityServiceProvider.overrideWithValue(_OnlineConnectivity()),
          sessionControllerProvider.overrideWithBuild(
            (ref, notifier) => session,
          ),
        ],
        child: MaterialApp(theme: AgroTheme.light, home: const AgroAiPage()),
      ),
    );
    await tester.pumpAndSettle();
    return database;
  }

  testWidgets('prompts sign in when there is no active session', (
    tester,
  ) async {
    final database = createInMemoryDatabase();
    await pumpPage(
      tester,
      database: database,
      session: const SessionState.signedOut(),
    );

    expect(find.text('Inicia sesión para consultar.'), findsOneWidget);
    await database.close();
  });

  testWidgets('shows the empty state before the first question', (
    tester,
  ) async {
    final database = createInMemoryDatabase();
    await pumpPage(tester, database: database);

    expect(find.text('Haz tu primera consulta'), findsOneWidget);
    await database.close();
  });

  testWidgets('lists prior messages and only offers retry on the failed one', (
    tester,
  ) async {
    final database = createInMemoryDatabase();
    await database.batch((batch) {
      batch.insertAll(database.aiMessages, [
        AiMessagesCompanion.insert(
          id: 'm1',
          ownerId: 'owner-1',
          role: 'user',
          content: '¿Cuándo conviene regar tomates en verano?',
          state: const Value('sent'),
          createdAt: DateTime.now().toUtc(),
        ),
        AiMessagesCompanion.insert(
          id: 'm2',
          ownerId: 'owner-1',
          clientMessageId: const Value('failed-1'),
          role: 'user',
          content: '¿Qué plaga ataca la frambuesa?',
          state: const Value('error'),
          createdAt: DateTime.now().toUtc(),
        ),
      ]);
    });

    await pumpPage(tester, database: database);

    expect(
      find.text('¿Cuándo conviene regar tomates en verano?'),
      findsOneWidget,
    );
    expect(find.text('¿Qué plaga ataca la frambuesa?'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
    await database.close();
  });

  testWidgets('disables the send action until a question is typed', (
    tester,
  ) async {
    final database = createInMemoryDatabase();
    await pumpPage(tester, database: database);

    final sendButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Enviar consulta'),
    );
    expect(sendButton.onPressed, isNull);

    await tester.enterText(
      find.byType(TextField),
      '¿Cuándo conviene fertilizar?',
    );
    await tester.pumpAndSettle();

    final enabledButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Enviar consulta'),
    );
    expect(enabledButton.onPressed, isNotNull);
    await database.close();
  });

  testWidgets(
    'keeps offline degradation explicit when AgroIA is not configured',
    (tester) async {
      final database = createInMemoryDatabase();
      await pumpPage(tester, database: database);

      await tester.enterText(
        find.byType(TextField),
        '¿Cuándo conviene regar paltos?',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Enviar consulta'));
      await tester.pumpAndSettle();

      // The failed message is persisted and the question stays in the
      // field so it can be resent.
      expect(find.text('¿Cuándo conviene regar paltos?'), findsNWidgets(2));
      expect(
        find.widgetWithText(TextField, '¿Cuándo conviene regar paltos?'),
        findsOneWidget,
      );
      expect(find.text('Reintentar'), findsOneWidget);
      expect(
        find.text(
          'AgroIA no está disponible. Tus registros offline siguen funcionando.',
        ),
        findsOneWidget,
      );
      await database.close();
    },
  );
}

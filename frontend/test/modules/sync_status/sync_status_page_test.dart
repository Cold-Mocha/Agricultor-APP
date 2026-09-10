import 'package:agrocampo/src/modules/sync_status/presentation/pages/sync_status_page.dart';
import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../backend/test/helpers/in_memory_database.dart';

void main() {
  testWidgets('shows truthful pending, retry and blocked states', (
    tester,
  ) async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    for (final entry in const [
      ('retry', 'retry_wait'),
      ('blocked', 'blocked'),
    ]) {
      await database.syncOutboxDao.enqueue(
        SyncOutboxCompanion.insert(
          operationId: entry.$1,
          ownerId: 'owner-1',
          aggregateType: 'parcel',
          aggregateId: entry.$1,
          mutationKind: 'update',
          payloadJson: '{}',
          state: Value(entry.$2),
          createdAt: DateTime.utc(2026),
        ),
      );
    }
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const MaterialApp(
          home: SyncStatusPage(ownerIdOverride: 'owner-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cambios pendientes'), findsOneWidget);
    expect(find.text('Esperando reintento'), findsOneWidget);
    expect(find.text('Cambios que necesitan atención'), findsOneWidget);
    expect(find.text('Sincronizar ahora'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}

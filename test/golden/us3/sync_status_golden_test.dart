import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/theme/agro_theme.dart';
import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/sync_status/presentation/sync_status_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  testWidgets('sync status follows the approved visual system', (tester) async {
    final database = createInMemoryDatabase();
    await database.syncOutboxDao.enqueue(
      SyncOutboxCompanion.insert(
        operationId: 'op-1',
        ownerId: 'owner-1',
        aggregateType: 'parcel',
        aggregateId: 'parcel-1',
        mutationKind: 'create',
        payloadJson: '{}',
        createdAt: DateTime.utc(2026),
      ),
    );
    await tester.binding.setSurfaceSize(const Size(412, 915));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          theme: AgroTheme.light,
          home: const SyncStatusPage(ownerIdOverride: 'owner-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(SyncStatusPage),
      matchesGoldenFile('sync_status.png'),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await database.close();
  });
}

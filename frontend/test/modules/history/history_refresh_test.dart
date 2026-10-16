import 'dart:async';

import 'package:agrocampo/src/app/theme/agro_theme.dart';
import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo/src/modules/history/presentation/pages/history_page.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../backend/test/helpers/in_memory_database.dart';

Future<void> _seed(AppDatabase db) async {
  await db
      .into(db.sectors)
      .insert(
        SectorsCompanion.insert(
          id: 'qa',
          ownerId: 'owner',
          number: 26,
          name: 'QA 26',
          polygonJson: '[]',
          areaSquareMeters: 43,
          updatedAt: DateTime.utc(2026),
          deletedAt: Value(DateTime.utc(2026)),
          syncState: const Value('synced'),
        ),
      );
  await db
      .into(db.labors)
      .insert(
        LaborsCompanion.insert(
          id: 'qa-labor',
          ownerId: 'owner',
          sectorId: 'qa',
          type: 'other',
          customName: const Value('Actividad QA'),
          occurredAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        ),
      );
}

void main() {
  testWidgets(
    'refresh is single-flight and removes an absent selected sector from view',
    (tester) async {
      tester.view.physicalSize = const Size(430, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = createInMemoryDatabase();
      addTearDown(db.close);
      await _seed(db);
      final finish = Completer<void>();
      var calls = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            unlockedOwnerIdProvider.overrideWithValue('owner'),
            historyRefreshActionProvider.overrideWithValue((owner) async {
              expect(owner, 'owner');
              calls++;
              await finish.future;
              await (db.update(
                db.sectors,
              )..where((row) => row.id.equals('qa'))).write(
                const SectorsCompanion(syncState: Value('remote_missing')),
              );
              return const HistoryRefreshResult(unavailableSectorIds: ['qa']);
            }),
          ],
          child: MaterialApp(
            theme: AgroTheme.light,
            home: const HistoryPage(initialSectorId: 'qa'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Actividad QA'), findsOneWidget);
      await tester.tap(find.byTooltip('Actualizar datos'));
      await tester.pump();
      final busy = tester.widget<IconButton>(
        find.byWidgetPredicate(
          (widget) =>
              widget is IconButton && widget.tooltip == 'Actualizando datos',
        ),
      );
      expect(busy.onPressed, isNull);
      expect(calls, 1);
      finish.complete();
      await tester.pumpAndSettle();
      expect(find.text('Datos actualizados.'), findsOneWidget);
      expect(find.text('Actividad QA'), findsNothing);
      expect(find.text('Todos los sectores'), findsWidgets);
      expect(await db.select(db.sectors).get(), hasLength(1));
      expect(await db.select(db.labors).get(), hasLength(1));
      expect(calls, 1);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'failed refresh keeps local history and offers retry without false success',
    (tester) async {
      final db = createInMemoryDatabase();
      addTearDown(db.close);
      await _seed(db);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            unlockedOwnerIdProvider.overrideWithValue('owner'),
            historyRefreshActionProvider.overrideWithValue(
              (_) => Future.error(StateError('offline')),
            ),
          ],
          child: MaterialApp(
            theme: AgroTheme.light,
            home: const HistoryPage(initialSectorId: 'qa'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Actualizar datos'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'No se pudo actualizar. Comprueba la conexión e inténtalo de nuevo.',
        ),
        findsOneWidget,
      );
      expect(find.text('Datos actualizados.'), findsNothing);
      expect(find.text('Actividad QA'), findsOneWidget);
      final button = tester.widget<IconButton>(
        find.byWidgetPredicate(
          (widget) =>
              widget is IconButton && widget.tooltip == 'Actualizar datos',
        ),
      );
      expect(button.onPressed, isNotNull);
      expect((await db.select(db.sectors).getSingle()).syncState, 'synced');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
}

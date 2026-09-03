import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/parcels/data/parcel_repository.dart';
import 'package:agrocampo/shared/presentation/components/agricultural_context_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/in_memory_database.dart';

void main() {
  testWidgets('shows agricultural labels and never exposes raw ids', (
    tester,
  ) async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    final parcelId = await ParcelRepository(database)
        .save(ownerId: 'owner-1', name: 'Parcela El Molino', isActive: true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          unlockedOwnerIdProvider.overrideWithValue('owner-1'),
        ],
        child: const MaterialApp(
          home: Scaffold(body: AgriculturalContextSelector()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Parcela El Molino'), findsOneWidget);
    expect(find.text(parcelId), findsNothing);
    expect(find.bySemanticsLabel('Contexto agrícola activo'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}

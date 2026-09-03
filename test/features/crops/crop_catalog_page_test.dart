import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/crops/presentation/crop_catalog_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  testWidgets('catalog shows official and creates a custom crop offline', (
    tester,
  ) async {
    final database = createInMemoryDatabase();
    await database
        .into(database.officialCrops)
        .insert(
          OfficialCropsCompanion.insert(
            id: 'maiz',
            commonName: 'Maíz',
            category: 'cereal',
            colorToken: 'cropCereal',
            iconAsset: 'assets/icons/crops/custom-crop.svg',
          ),
        );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          unlockedOwnerIdProvider.overrideWithValue('owner-1'),
        ],
        child: const MaterialApp(home: CropCatalogPage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Maíz');
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'Maíz'), findsOneWidget);
    expect(find.text('Oficial'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Crear cultivo personalizado'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre'),
      'Zapallo local',
    );
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Zapallo local');
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'Zapallo local'), findsOneWidget);
    expect(find.textContaining('Personalizado'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await database.close();
  });
}

import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/theme/agro_theme.dart';
import 'package:agrocampo/features/crops/presentation/crop_catalog_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  testWidgets('crop catalog uses approved pictograms and responsive grid', (
    tester,
  ) async {
    final database = createInMemoryDatabase();
    await tester.binding.setSurfaceSize(const Size(412, 915));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          theme: AgroTheme.light,
          home: const CropCatalogPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(CropCatalogPage),
      matchesGoldenFile('crop_catalog.png'),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await database.close();
  });
}

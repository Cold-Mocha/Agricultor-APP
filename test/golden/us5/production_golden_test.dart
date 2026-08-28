import 'package:agrocampo/app/theme/agro_theme.dart';
import 'package:agrocampo/features/production/presentation/production_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('production form follows the approved system', (tester) async {
    await tester.binding.setSurfaceSize(const Size(412, 915));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AgroTheme.light,
          home: const ProductionPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(ProductionPage),
      matchesGoldenFile('production.png'),
    );
  });
}

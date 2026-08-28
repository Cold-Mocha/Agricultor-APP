import 'package:agrocampo/app/theme/agro_theme.dart';
import 'package:agrocampo/features/irrigation/presentation/irrigation_record_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('irrigation clearly exposes unavailable rule state', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(412, 915));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AgroTheme.light,
          home: const IrrigationRecordPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Regla agronómica no disponible'),
      findsOneWidget,
    );
    await expectLater(
      find.byType(IrrigationRecordPage),
      matchesGoldenFile('irrigation_unavailable.png'),
    );
  });
}

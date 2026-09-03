import 'package:agrocampo/app/theme/agro_theme.dart';
import 'package:agrocampo/features/irrigation/domain/irrigation_record.dart';
import 'package:agrocampo/features/irrigation/presentation/irrigation_record_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';
import '../../helpers/signed_in_widget_scope.dart';
import '../../helpers/territory_fixture.dart';

void main() {
  testWidgets(
    'drip unavailable state and record-only alternatives are explicit',
    (tester) async {
      final database = createInMemoryDatabase();
      final container = signedInWidgetContainer(database);
      addTearDown(database.close);
      addTearDown(container.dispose);
      await seedAgriculturalContextFixture(database);
      await selectFixtureAgriculturalContext(container);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
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
      await tester.enterText(find.byType(TextField).first, '30');
      final calculateButton = find.widgetWithText(
        TextButton,
        'Calcular de forma determinística',
      );
      await tester.scrollUntilVisible(
        calculateButton,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(calculateButton);
      await tester.pump();
      await tester.tap(calculateButton);
      await tester.pumpAndSettle();
      expect(find.textContaining('Configura plantas, goteros'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('irrigation-type')),
        -250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const ValueKey('irrigation-type')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(IrrigationType.furrow.name).last);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        calculateButton,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(calculateButton);
      await tester.pump();
      await tester.tap(calculateButton);
      await tester.pumpAndSettle();
      expect(
        find.textContaining('solo calcula recomendaciones'),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );
}

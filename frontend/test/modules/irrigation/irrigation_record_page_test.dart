import 'package:agrocampo/src/app/theme/agro_theme.dart';
import 'package:agrocampo/src/modules/irrigation/presentation/pages/irrigation_record_page.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_status_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../backend/test/helpers/in_memory_database.dart';
import '../../../../backend/test/helpers/territory_fixture.dart';
import '../../helpers/signed_in_widget_scope.dart';

void main() {
  testWidgets(
    'record-only method explains calculation limit without a selected sector',
    (tester) async {
      final database = createInMemoryDatabase();
      final container = signedInWidgetContainer(database);
      addTearDown(database.close);
      addTearDown(container.dispose);
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
      await tester.tap(find.byKey(const ValueKey('irrigation-type')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Surco').last);
      await tester.pumpAndSettle();
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
      expectBannerAndNotice(
        'Sólo se calculan recomendaciones para riego por goteo.',
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );

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
      expect(find.text('Goteo'), findsOneWidget);
      expect(find.text('No lo sé'), findsOneWidget);
      expect(find.text('drip'), findsNothing);
      expect(find.text('unknown'), findsNothing);
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
      expectBannerAndNotice('Configura plantas, goteros');

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('irrigation-type')),
        -250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const ValueKey('irrigation-type')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Surco').last);
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
      expectBannerAndNotice('Sólo se calculan recomendaciones');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );
}

void expectBannerAndNotice(String message) {
  expect(
    find.descendant(
      of: find.byType(AgroStatusBanner),
      matching: find.textContaining(message),
    ),
    findsOneWidget,
    reason: 'the status banner keeps the calculation message visible',
  );
  expect(
    find.descendant(
      of: find.byType(SnackBar),
      matching: find.textContaining(message),
    ),
    findsOneWidget,
    reason: 'a bottom notice tells the user what is missing',
  );
}

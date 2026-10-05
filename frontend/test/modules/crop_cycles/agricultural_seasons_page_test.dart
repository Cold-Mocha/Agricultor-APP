import 'package:agrocampo/src/app/theme/agro_theme.dart';
import 'package:agrocampo/src/modules/crop_cycles/presentation/pages/agricultural_seasons_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../backend/test/helpers/in_memory_database.dart';
import '../../../../backend/test/helpers/territory_fixture.dart';
import '../../helpers/signed_in_widget_scope.dart';

void main() {
  testWidgets('seasons say which quadrant is being configured', (tester) async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    final container = signedInWidgetContainer(database);
    addTearDown(container.dispose);
    await tester.runAsync(() async {
      await seedAgriculturalContextFixture(database);
      await selectFixtureAgriculturalContext(container);
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AgroTheme.light,
          home: const AgriculturalSeasonsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Configurando Sector 1'), findsOneWidget);
    expect(find.byKey(const Key('active-sector-selector')), findsNothing);
    expect(
      find.text('01/01/2025'),
      findsOneWidget,
      reason: 'the season title is its start–end date range, not its name',
    );
    expect(
      find.text('Activa'),
      findsOneWidget,
      reason: 'the status stays in the preview of the seasons list',
    );
    expect(find.text('Temporada 2025/26'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}

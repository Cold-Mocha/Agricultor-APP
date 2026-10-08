import 'package:agrocampo/src/app/theme/agro_theme.dart';
import 'package:agrocampo/src/modules/crop_cycles/presentation/pages/agricultural_season_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../backend/test/helpers/in_memory_database.dart';
import '../../helpers/signed_in_widget_scope.dart';

void main() {
  testWidgets('a season is edited by start, end and description only', (
    tester,
  ) async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    final container = signedInWidgetContainer(database);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AgroTheme.light,
          home: const AgriculturalSeasonFormPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Término'), findsOneWidget);
    expect(find.text('Descripción:'), findsOneWidget);
    expect(find.text('Nombre'), findsNothing);
    expect(find.byType(DropdownButtonFormField<Object>), findsNothing);
    expect(
      find.text('Estado:'),
      findsNothing,
      reason: 'the status follows the dates and is shown in the seasons list',
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}

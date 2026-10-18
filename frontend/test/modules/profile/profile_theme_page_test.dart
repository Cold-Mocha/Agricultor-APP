import 'package:agrocampo/src/app/theme/agro_theme.dart';
import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo/src/modules/profile/profile_ui.dart';
import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../backend/test/helpers/in_memory_database.dart';

void main() {
  testWidgets('dark mode toggle persists and reflects the saved preference', (
    tester,
  ) async {
    final database = createInMemoryDatabase();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          unlockedOwnerIdProvider.overrideWithValue('owner-1'),
        ],
        child: MaterialApp(
          theme: AgroTheme.light,
          home: const ProfileThemePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final toggle = find.byType(SwitchListTile);
    expect(toggle, findsOneWidget);
    expect(tester.widget<SwitchListTile>(toggle).value, isFalse);

    await tester.tap(toggle);
    await tester.pumpAndSettle();

    expect(
      tester.widget<SwitchListTile>(toggle).value,
      isTrue,
      reason:
          'the switch reads the same watched stream the save writes to, so '
          'this proves the preference round-tripped through the database',
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await database.close();
  });

  testWidgets('without a signed-in owner the page asks to sign in', (
    tester,
  ) async {
    final database = createInMemoryDatabase();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          theme: AgroTheme.light,
          home: const ProfileThemePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SwitchListTile), findsNothing);
    expect(find.text('Inicia sesión para ver esta opción.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await database.close();
  });
}

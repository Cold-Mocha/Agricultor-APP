import 'package:agrocampo/src/app/theme/agro_theme.dart';
import 'package:agrocampo/src/modules/profile/profile_ui.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpPrivacy(WidgetTester tester, {required bool localMode}) =>
    tester.pumpWidget(
      ProviderScope(
        overrides: [isLocalModeProvider.overrideWithValue(localMode)],
        child: MaterialApp(
          theme: AgroTheme.light,
          home: const ProfileInformationPage(
            kind: ProfileInformationKind.privacy,
          ),
        ),
      ),
    );

void main() {
  testWidgets('privacy in local mode only talks about this device', (
    tester,
  ) async {
    await _pumpPrivacy(tester, localMode: true);

    expect(find.text('Datos en este dispositivo'), findsOneWidget);
    expect(find.textContaining('Supabase'), findsNothing);
    expect(find.textContaining('cuenta'), findsNothing);
  });

  testWidgets('privacy online keeps the account explanation', (tester) async {
    await _pumpPrivacy(tester, localMode: false);

    expect(find.text('Datos por cuenta'), findsOneWidget);
  });
}

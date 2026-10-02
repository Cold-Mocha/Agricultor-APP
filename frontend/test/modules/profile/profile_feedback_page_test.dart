import 'package:agrocampo/src/app/shell/agro_feedback_host.dart';
import 'package:agrocampo/src/app/theme/agro_theme.dart';
import 'package:agrocampo/src/modules/profile/profile_ui.dart';
import 'package:agrocampo/src/shared/design_system/feedback/agro_feedback_scope.dart';
import 'package:agrocampo/src/shared/design_system/feedback/agro_sound_effects.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/signed_in_widget_scope.dart';

void main() {
  late AppDatabase database;
  late ProviderContainer container;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    container = signedInWidgetContainer(database);
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AgroTheme.light,
          builder: (context, child) => AgroFeedbackHost(
            soundEffects: const SilentAgroSoundEffects(),
            child: child!,
          ),
          home: const ProfileFeedbackPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  bool switchValue(WidgetTester tester, String key) =>
      tester.widget<SwitchListTile>(find.byKey(ValueKey(key))).value;

  testWidgets('sound and animations start enabled', (tester) async {
    await pumpPage(tester);

    expect(find.text('Efectos de sonido'), findsOneWidget);
    expect(find.text('Animaciones'), findsOneWidget);
    expect(switchValue(tester, 'feedback-sound-switch'), isTrue);
    expect(switchValue(tester, 'feedback-animations-switch'), isTrue);
  });

  testWidgets('turning sound off persists and silences the feedback scope', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.tap(find.byKey(const ValueKey('feedback-sound-switch')));
    await tester.pumpAndSettle();

    expect(switchValue(tester, 'feedback-sound-switch'), isFalse);
    final stored = await tester.runAsync(
      () => container
          .read(profileFacadeProvider)
          .watchFeedbackPreferences('owner-1')
          .first,
    );
    expect(stored, const FeedbackPreferences(soundEffectsEnabled: false));
    final scope = tester.widget<AgroFeedbackScope>(
      find.byType(AgroFeedbackScope),
    );
    expect(scope.soundEnabled, isFalse);
  });

  testWidgets('turning animations off behaves like reduced motion', (
    tester,
  ) async {
    await pumpPage(tester);
    final context = tester.element(find.byType(ProfileFeedbackPage));
    expect(MediaQuery.of(context).disableAnimations, isFalse);

    await tester.tap(find.byKey(const ValueKey('feedback-animations-switch')));
    await tester.pumpAndSettle();

    expect(switchValue(tester, 'feedback-animations-switch'), isFalse);
    expect(
      MediaQuery.of(tester.element(find.byType(ProfileFeedbackPage)))
          .disableAnimations,
      isTrue,
    );
  });

  testWidgets('system reduce motion locks the animations switch off', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await pumpPage(tester);

    final tile = tester.widget<SwitchListTile>(
      find.byKey(const ValueKey('feedback-animations-switch')),
    );
    expect(tile.value, isFalse);
    expect(tile.onChanged, isNull);
    expect(find.textContaining('reducir movimiento'), findsOneWidget);
  });
}

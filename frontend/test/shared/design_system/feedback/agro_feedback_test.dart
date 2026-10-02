import 'package:agrocampo/src/app/theme/agro_theme.dart';
import 'package:agrocampo/src/shared/design_system/feedback/agro_feedback.dart';
import 'package:agrocampo/src/shared/design_system/feedback/agro_feedback_scope.dart';
import 'package:agrocampo/src/shared/design_system/feedback/agro_sound_effects.dart';
import 'package:agrocampo/src/shared/design_system/feedback/agro_success_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final class _RecordingSoundEffects implements AgroSoundEffects {
  final played = <AgroSound>[];

  @override
  Future<void> play(AgroSound sound) async => played.add(sound);

  @override
  Future<void> dispose() async {}
}

Future<BuildContext> _pump(
  WidgetTester tester, {
  required AgroSoundEffects sounds,
  bool soundEnabled = true,
  bool reducedMotion = false,
}) async {
  late BuildContext captured;
  await tester.pumpWidget(
    MaterialApp(
      theme: AgroTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reducedMotion),
        child: AgroFeedbackScope(
          soundEffects: sounds,
          soundEnabled: soundEnabled,
          child: child!,
        ),
      ),
      home: Scaffold(
        body: Builder(
          builder: (context) {
            captured = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );
  return captured;
}

void main() {
  testWidgets('a saved record plays its sound, shows the check and the text', (
    tester,
  ) async {
    final sounds = _RecordingSoundEffects();
    final context = await _pump(tester, sounds: sounds);

    AgroFeedback.recordSaved(context, 'Riego guardado localmente.');
    await tester.pump();

    expect(sounds.played, [AgroSound.recordSaved]);
    expect(find.byType(AgroSuccessCheckMark), findsOneWidget);
    expect(find.text('Riego guardado localmente.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(
      find.byType(AgroSuccessCheckMark),
      findsNothing,
      reason: 'the check leaves on its own and never blocks the screen',
    );
  });

  testWidgets('reduced motion keeps the text and sound but drops the check', (
    tester,
  ) async {
    final sounds = _RecordingSoundEffects();
    final context = await _pump(tester, sounds: sounds, reducedMotion: true);

    AgroFeedback.recordSaved(context, 'Medición guardada localmente.');
    await tester.pump();

    expect(sounds.played, [AgroSound.recordSaved]);
    expect(find.byType(AgroSuccessCheckMark), findsNothing);
    expect(find.text('Medición guardada localmente.'), findsOneWidget);
  });

  testWidgets('disabled sound keeps every message silent', (tester) async {
    final sounds = _RecordingSoundEffects();
    final context = await _pump(tester, sounds: sounds, soundEnabled: false);

    AgroFeedback.saved(context, 'Perfil guardado en este dispositivo.');
    AgroFeedback.error(context, 'Escribe un nombre visible.');
    AgroFeedback.tap(context, () {})!();
    await tester.pump();

    expect(sounds.played, isEmpty);
    expect(find.text('Perfil guardado en este dispositivo.'), findsOneWidget);
  });

  testWidgets('each event maps to its own sound and info stays silent', (
    tester,
  ) async {
    final sounds = _RecordingSoundEffects();
    final context = await _pump(tester, sounds: sounds);
    var pressed = false;

    AgroFeedback.saved(context, 'Exportación completada.');
    AgroFeedback.error(context, 'No se pudo guardar.');
    AgroFeedback.info(context, 'Exportación cancelada.');
    AgroFeedback.tap(context, () => pressed = true)!();

    expect(sounds.played, [AgroSound.saved, AgroSound.error, AgroSound.tap]);
    expect(pressed, isTrue);
    expect(
      AgroFeedback.tap(context, null),
      isNull,
      reason: 'a disabled button must stay disabled',
    );
  });

  test('every sound has a bundled OGG asset and a gentle volume', () {
    for (final sound in AgroSound.values) {
      expect(sound.asset, startsWith('sounds/'));
      expect(sound.asset, endsWith('.ogg'));
      expect(sound.volume, inInclusiveRange(0.1, 0.8));
    }
  });
}

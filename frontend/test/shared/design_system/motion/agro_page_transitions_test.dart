import 'package:agrocampo/src/app/theme/agro_theme.dart';
import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/shared/design_system/motion/agro_motion_effects.dart';
import 'package:agrocampo/src/shared/design_system/motion/agro_page_transitions.dart';
import 'package:agrocampo/src/shared/design_system/motion/agro_press_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpNavigator(WidgetTester tester, {required bool reduced}) =>
    tester.pumpWidget(
      MaterialApp(
        theme: AgroTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const Scaffold(body: Text('Detalle')),
                ),
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );

void main() {
  test('page transitions use the AgroMotion tokens and exit faster', () {
    const builder = AgroPageTransitionsBuilder();
    expect(builder.transitionDuration, AgroMotion.standard);
    expect(builder.reverseTransitionDuration, AgroMotion.exit);
    expect(
      builder.reverseTransitionDuration < builder.transitionDuration,
      isTrue,
    );
    expect(
      AgroTheme.light.pageTransitionsTheme.builders[TargetPlatform.android],
      isA<AgroPageTransitionsBuilder>(),
    );
  });

  testWidgets('a pushed page fades in while motion is allowed', (tester) async {
    await _pumpNavigator(tester, reduced: false);
    await tester.tap(find.text('Abrir'));
    await tester.pump();
    await tester.pump(AgroMotion.standard ~/ 2);

    final fades = tester.widgetList<FadeTransition>(
      find.ancestor(
        of: find.text('Detalle'),
        matching: find.byType(FadeTransition),
      ),
    );
    expect(fades.any((fade) => fade.opacity.value < 1), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('Detalle'), findsOneWidget);
  });

  testWidgets('reduced motion shows the pushed page without a fade', (
    tester,
  ) async {
    await _pumpNavigator(tester, reduced: true);
    await tester.tap(find.text('Abrir'));
    await tester.pump();
    await tester.pump(AgroMotion.standard ~/ 2);

    final fades = tester.widgetList<FadeTransition>(
      find.ancestor(
        of: find.text('Detalle'),
        matching: find.byType(FadeTransition),
      ),
    );
    expect(fades.every((fade) => fade.opacity.value == 1), isTrue);
  });

  test('stagger delay stops growing after the maximum steps', () {
    expect(agroStaggerDelay(0), Duration.zero);
    expect(agroStaggerDelay(1), AgroMotion.staggerStep);
    final cap = AgroMotion.staggerStep * AgroMotion.staggerMaxSteps;
    expect(agroStaggerDelay(AgroMotion.staggerMaxSteps), cap);
    expect(agroStaggerDelay(40), cap);
  });

  testWidgets('press scale shrinks while pressed and settles on release', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: AgroPressScale(
            child: SizedBox(
              width: 100,
              height: 100,
              child: GestureDetector(
                onTap: () {},
                child: const ColoredBox(color: Colors.green),
              ),
            ),
          ),
        ),
      ),
    );
    double scale() =>
        tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(AgroPressScale)),
    );
    await tester.pump();
    expect(scale(), AgroMotion.pressedScale);

    await gesture.up();
    await tester.pump();
    expect(scale(), 1);
  });
}

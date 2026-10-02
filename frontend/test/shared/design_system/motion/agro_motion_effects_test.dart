import 'package:agrocampo/src/shared/design_system/motion/agro_motion_effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _withReducedMotion({required bool reduced, required Widget child}) =>
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: child,
      ),
    );

void main() {
  testWidgets('agroPrefersReducedMotion reflects the platform signal', (
    tester,
  ) async {
    late bool reduced;
    late bool notReduced;
    await tester.pumpWidget(
      _withReducedMotion(
        reduced: true,
        child: Builder(
          builder: (context) {
            reduced = agroPrefersReducedMotion(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await tester.pumpWidget(
      _withReducedMotion(
        reduced: false,
        child: Builder(
          builder: (context) {
            notReduced = agroPrefersReducedMotion(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(reduced, isTrue);
    expect(notReduced, isFalse);
  });

  testWidgets('agroEntrance wraps content in Animate when motion is allowed', (
    tester,
  ) async {
    await tester.pumpWidget(
      _withReducedMotion(
        reduced: false,
        child: Builder(
          builder: (context) => const Text('Guardado').agroEntrance(context),
        ),
      ),
    );

    expect(find.byType(Animate), findsOneWidget);
    expect(find.text('Guardado'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Guardado'), findsOneWidget);
  });

  testWidgets('agroEntrance is a no-op under reduced motion', (tester) async {
    await tester.pumpWidget(
      _withReducedMotion(
        reduced: true,
        child: Builder(
          builder: (context) => const Text('Guardado').agroEntrance(context),
        ),
      ),
    );

    expect(find.byType(Animate), findsNothing);
    expect(find.text('Guardado'), findsOneWidget);
  });

  testWidgets('agroStaggeredEntrance animates every item when allowed', (
    tester,
  ) async {
    final items = [
      const Text('Riego'),
      const Text('Suelo'),
      const Text('Fertilización'),
    ];
    await tester.pumpWidget(
      _withReducedMotion(
        reduced: false,
        child: Builder(
          builder: (context) => Column(
            children: items.agroStaggeredEntrance(context),
          ),
        ),
      ),
    );

    expect(find.byType(Animate), findsNWidgets(items.length));
    for (final item in items) {
      expect(find.text((item as Text).data!), findsOneWidget);
    }
    await tester.pumpAndSettle();
  });

  testWidgets(
    'agroStaggeredEntrance skips stagger and animation under reduced motion',
    (tester) async {
      final items = [const Text('Riego'), const Text('Suelo')];
      await tester.pumpWidget(
        _withReducedMotion(
          reduced: true,
          child: Builder(
            builder: (context) => Column(
              children: items.agroStaggeredEntrance(context),
            ),
          ),
        ),
      );

      expect(find.byType(Animate), findsNothing);
      expect(find.text('Riego'), findsOneWidget);
      expect(find.text('Suelo'), findsOneWidget);
    },
  );
}

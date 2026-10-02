import 'package:agrocampo/src/app/theme/agro_theme.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, {required bool reduced}) =>
    tester.pumpWidget(
      MaterialApp(
        theme: AgroTheme.light,
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduced),
          child: const Scaffold(body: AgroSkeletonList(itemCount: 2)),
        ),
      ),
    );

void main() {
  testWidgets('skeleton reserves blocks and announces loading', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pump(tester, reduced: false);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const ValueKey('agro-skeleton-block')), findsNWidgets(3));
    expect(find.bySemanticsLabel('Cargando'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.hasRunningAnimations, isTrue, reason: 'pulses by default');
    semantics.dispose();
  });

  testWidgets('skeleton stays still under reduced motion', (tester) async {
    await _pump(tester, reduced: true);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const ValueKey('agro-skeleton-block')), findsNWidgets(3));
    expect(tester.hasRunningAnimations, isFalse);
  });
}

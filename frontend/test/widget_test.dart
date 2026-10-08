import 'package:agrocampo/src/app/theme/agro_theme.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('foundation renders an accessible empty state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AgroTheme.light,
        home: const Scaffold(
          body: AgroEmptyState(
            title: 'Sin cuadrantes',
            message: 'Dibuja tu primer cuadrante para comenzar.',
          ),
        ),
      ),
    );

    expect(find.text('Sin cuadrantes'), findsOneWidget);
    expect(
      find.text('Dibuja tu primer cuadrante para comenzar.'),
      findsOneWidget,
    );
  });
}

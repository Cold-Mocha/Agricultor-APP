import 'package:agrocampo/app/theme/agro_theme.dart';
import 'package:agrocampo/shared/presentation/components/agro_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('foundation renders an accessible empty state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AgroTheme.light,
        home: const Scaffold(
          body: AgroEmptyState(
            title: 'Sin parcelas',
            message: 'Crea tu primera parcela para comenzar.',
          ),
        ),
      ),
    );

    expect(find.text('Sin parcelas'), findsOneWidget);
    expect(find.text('Crea tu primera parcela para comenzar.'), findsOneWidget);
  });
}

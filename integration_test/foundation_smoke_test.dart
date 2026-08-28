import 'package:agrocampo/app/theme/agro_theme.dart';
import 'package:agrocampo/shared/presentation/components/foundation_placeholder_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('foundation launches with the Spanish offline-first shell copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AgroTheme.light,
        home: const FoundationPlaceholderPage(
          title: 'Inicio',
          message: 'Crea tu primera parcela para comenzar.',
        ),
      ),
    );

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Crea tu primera parcela para comenzar.'), findsOneWidget);
  });
}

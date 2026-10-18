import 'package:agrocampo/src/app/theme/agro_theme.dart';
import 'package:agrocampo/src/modules/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('PIN accepts exactly six digits', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AgroTheme.light, home: const LoginPage()),
      ),
    );
    final pin = find.byType(TextFormField).last;

    await tester.enterText(pin, '12ab34567');
    expect(
      tester
          .widget<EditableText>(
            find.descendant(of: pin, matching: find.byType(EditableText)),
          )
          .controller
          .text,
      '123456',
      reason: 'letters are dropped and input stops at six digits',
    );

    await tester.enterText(find.byType(TextFormField).first, 'Mario');
    await tester.enterText(pin, '123');
    expect(tester.state<FormState>(find.byType(Form)).validate(), isFalse);
    await tester.pump();
    expect(find.text('El PIN tiene 6 dígitos.'), findsOneWidget);
    expect(find.text('Ej.: Mario'), findsNothing);
  });
}

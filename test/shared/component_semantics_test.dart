import 'package:agrocampo/app/theme/agro_theme.dart';
import 'package:agrocampo/shared/presentation/components/agro_status_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('status banner exposes updates as a live region', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AgroTheme.light,
        home: const AgroStatusBanner(
          message: 'Guardado sin conexión',
          status: AgroStatus.info,
        ),
      ),
    );

    final semantics = tester.getSemantics(find.byType(AgroStatusBanner));
    expect(semantics.getSemanticsData().flagsCollection.isLiveRegion, isTrue);
  });
}

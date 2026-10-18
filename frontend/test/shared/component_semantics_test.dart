import 'package:agrocampo/src/app/theme/agro_theme.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_action_tile.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_navigation_card.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_status_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
    await tester.pumpAndSettle();
  });

  testWidgets('navigation cards expose one descriptive action', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AgroTheme.light,
        home: Scaffold(
          body: AgroNavigationCard(
            icon: LucideIcons.map,
            title: 'Mapa de cuadrantes',
            subtitle: 'Revisa la distribución de los cuadrantes.',
            onTap: () => taps += 1,
          ),
        ),
      ),
    );

    final semantics = tester.getSemantics(find.byType(AgroNavigationCard));
    final data = semantics.getSemanticsData();
    expect(data.label, contains('Mapa de cuadrantes'));
    expect(data.flagsCollection.isButton, isTrue);
    await tester.tap(find.byType(AgroNavigationCard));
    expect(taps, 1);
  });

  testWidgets('action grid becomes one column with large text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AgroTheme.light,
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: SizedBox(
              width: 400,
              child: AgroAdaptiveGrid(
                children: [
                  AgroActionTile(
                    key: const ValueKey('riego'),
                    icon: LucideIcons.droplet,
                    label: 'Riego',
                    onTap: () {},
                  ),
                  AgroActionTile(
                    key: const ValueKey('suelo'),
                    icon: LucideIcons.flaskConical,
                    label: 'Suelo',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final riego = tester.getTopLeft(find.byKey(const ValueKey('riego')));
    final suelo = tester.getTopLeft(find.byKey(const ValueKey('suelo')));
    expect(suelo.dx, riego.dx);
    expect(suelo.dy, greaterThan(riego.dy));
  });
}

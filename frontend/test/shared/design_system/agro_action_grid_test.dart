import 'package:agrocampo/src/app/theme/agro_theme.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_action_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  testWidgets('fixed two-column grid lays six actions in three rows', (
    tester,
  ) async {
    // Narrower than the 360 px breakpoint where the adaptive grid uses one.
    await tester.pumpWidget(
      MaterialApp(
        theme: AgroTheme.light,
        home: Scaffold(
          body: SizedBox(
            width: 328,
            child: AgroAdaptiveGrid(
              columns: 2,
              children: [
                for (var index = 0; index < 6; index++)
                  AgroActionTile(
                    icon: LucideIcons.droplet,
                    label: 'Acción $index',
                    onTap: () {},
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    final rects = [
      for (var index = 0; index < 6; index++)
        tester.getRect(find.text('Acción $index')),
    ];
    expect(rects.map((rect) => rect.left).toSet(), hasLength(2));
    expect(rects.map((rect) => rect.top).toSet(), hasLength(3));
  });
}

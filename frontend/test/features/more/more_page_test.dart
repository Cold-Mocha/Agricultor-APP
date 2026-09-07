import 'package:agrocampo/app/theme/agro_theme.dart';
import 'package:agrocampo/features/more/presentation/more_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Más groups field organization and data tools', (tester) async {
    tester.view.physicalSize = const Size(430, 1300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AgroTheme.light, home: const MorePage()),
      ),
    );

    expect(find.text('Campo'), findsOneWidget);
    expect(find.text('Organización'), findsOneWidget);
    expect(find.text('Respaldo y datos'), findsOneWidget);
    expect(find.text('Temporadas'), findsOneWidget);
    expect(find.text('Catálogo de cultivos'), findsOneWidget);
    expect(find.text('Historial agrícola'), findsOneWidget);
    expect(find.text('Recordatorios'), findsOneWidget);
    expect(find.text('Sincronización'), findsOneWidget);
    expect(find.text('Exportar XLSX'), findsOneWidget);
    expect(find.text('Perfil'), findsNothing);
  });
}

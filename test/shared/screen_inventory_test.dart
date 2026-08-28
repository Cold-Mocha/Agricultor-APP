import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all MVP screens have an implemented route or shell destination', () {
    final router = File('lib/app/routing/app_router.dart').readAsStringSync();
    for (final route in [
      '/inicio',
      '/sectores',
      '/mapa',
      '/registrar',
      '/agroia',
      '/mas',
      '/parcelas',
      '/cultivos',
      '/suelo',
      '/riego',
      '/historial',
      '/produccion',
      '/fotografias',
      '/recordatorios',
      '/exportar',
      '/sincronizacion',
      '/perfil',
    ]) {
      expect(router, contains("'$route'"), reason: 'Ruta MVP ausente: $route');
    }
    expect(router, isNot(contains('FoundationPlaceholderPage')));
  });
}

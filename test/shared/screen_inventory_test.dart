import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all MVP screens have an implemented route or shell destination', () {
    final router = File('lib/app/routing/app_router.dart').readAsStringSync();
    final routes = File('lib/app/routing/app_routes.dart').readAsStringSync();
    for (final route in [
      '/inicio',
      '/inicio/perfil',
      '/inicio/parcelas',
      '/sectores',
      '/registrar',
      '/registrar/suelo',
      '/registrar/riego',
      '/registrar/produccion',
      '/registrar/foto',
      '/agroia',
      '/mas',
      '/mas/temporadas',
      '/mas/catalogo',
      '/mas/historial',
      '/mas/recordatorios',
      '/mas/exportar',
      '/mas/sincronizacion',
      '/mas/configuracion',
    ]) {
      expect(routes, contains("'$route'"), reason: 'Ruta MVP ausente: $route');
    }
    expect(router, contains("path: 'parcela/:parcelId/mapa'"));
    expect(router, contains("path: 'labor/:laborType'"));
    expect(router, contains("path: 'conflictos/:id'"));
    expect(router, isNot(contains('FoundationPlaceholderPage')));
  });
}

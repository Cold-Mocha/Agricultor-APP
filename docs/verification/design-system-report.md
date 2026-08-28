# Verificación de diseño y accesibilidad

Fecha: 2026-08-28. Referencia: `master.md`.

## Resultado

- Material 3, Inter y tokens AgroCampo centralizan color, tipografía, espaciado y radios.
- Las cinco ramas principales son Inicio, Sectores, Registrar, AgroIA y Más; las pantallas contextuales usan la pila Android.
- Ninguna ruta MVP conserva placeholders. El inventario automatizado cubre los destinos exigidos.
- Los estados offline, pendientes, vacíos y errores se expresan con texto e icono, no sólo color.
- Los formularios usan controles Material accesibles, etiquetas persistentes y acciones con texto.
- Los goldens US1–US8 cubren catálogo, labores, sincronización, riego, producción, fotos, apicultura y exportación a 412 × 915 dp.

## Evidencia automática

`test/shared/design_policy_test.dart`, `test/shared/component_semantics_test.dart`, `test/shared/screen_inventory_test.dart` y `test/golden/`.

## Responsive

Las vistas emplean `ListView`, `Expanded`, grids adaptables y componentes sin coordenadas absolutas. El mapa mantiene alternativa textual cuando su base remota no está disponible.

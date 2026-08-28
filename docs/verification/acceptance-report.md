# Informe de aceptación

La implementación cubre T003–T084 y los requisitos funcionales trazados en `tasks.md`. La suite valida repositorios locales, reglas, contratos externos, outbox idempotente, exportación OpenXML y políticas visuales. Los flujos de integración cubren territorio, labores/suelo/riego, sincronización, cálculo, historial/producción, fotos/recordatorios, apicultura y clima/IA/exportación.

## Gates

- `flutter analyze`: sin incidencias.
- `flutter test`: 43 pruebas aprobadas, incluido inventario, redacción de logs y rendimiento XLSX.
- Goldens US1–US8: aprobados.
- APK debug y AAB release interno: compilados correctamente tras US8/polish.
- pgTAP y Deno: artefactos preparados; requieren Supabase CLI/Deno y servicios locales configurados.
- Credenciales reales: intencionalmente ausentes.

La aceptación de publicación queda condicionada a inyectar secretos del entorno, ejecutar pgTAP/Deno en CI y firmar con el keystore del propietario.

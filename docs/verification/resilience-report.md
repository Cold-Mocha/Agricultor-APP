# Informe de migración y resiliencia

La base local está en esquema 9 y conserva una cadena incremental 1→9. Cada versión crea exclusivamente las tablas de su fase; `PRAGMA foreign_keys = ON` se activa al crear y abrir.

Los writes de negocio y outbox son atómicos. Las pruebas cubren rollback forzado, pérdida de ACK con 100 reintentos idempotentes, continuidad offline, recuperación tras interrupción y separación de fallos de clima/AgroIA respecto del núcleo local.

`drift_schemas/drift_schema_v9.json` fija el inventario esperado. Las migraciones remotas son append-only (`0001`–`0011`); RLS se habilita en la misma migración que crea cada agregado sensible.

Antes de distribuir una actualización se debe ejecutar la suite completa contra una copia anonimizada y conservar copia recuperable del archivo SQLite. Si una migración remota falla, no se reescribe: se añade una migración correctiva.

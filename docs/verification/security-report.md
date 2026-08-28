# Informe de seguridad

Fecha: 2026-08-28.

## Controles implantados

- Sesión local en `flutter_secure_storage`; no se persisten contraseñas.
- Todas las filas remotas con `owner_id` habilitan RLS y comparan `auth.uid()`.
- El bucket `photos` es privado; rutas y políticas quedan limitadas al primer segmento del propietario.
- WeatherAPI, Gemini y Firebase se invocan en Edge Functions. Sus claves proceden exclusivamente de secretos del entorno.
- Las funciones validan JWT, tamaño/tipo de entrada y normalizan respuestas; la app degrada cada servicio sin bloquear operaciones offline.
- FCM usa OAuth de cuenta de servicio en servidor y deep links internos; los tokens se consultan sólo por propietario.
- `SafeLogger` elimina token, key, secret, password, prompt y coordenadas; los errores registran tipo, no contenido.
- `.gitignore` excluye `.env`, keystores, `key.properties` y `google-services.json`.

## Evidencia

pgTAP en `supabase/tests/database/`, tests de funciones en `supabase/functions/*/tests/` y `test/core/observability/safe_logger_test.dart`.

## Operación

Rotar secretos en Supabase/Firebase ante exposición. No publicar un AAB firmado con la clave debug. La cuenta de servicio Firebase debe tener sólo permiso para enviar mensajes.

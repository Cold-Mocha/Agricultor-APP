# Guías de despliegue de AgroCampo

Este directorio documenta, paso a paso, todo lo que queda pendiente de **interacción
humana directa** (crear cuentas, proyectos y credenciales en servicios externos) para
llevar AgroCampo a producción. Todo lo que se podía resolver sin esa interacción
—pipeline de CI, plantillas de configuración, scripts y guardas de seguridad— ya
está resuelto en este mismo cambio; ver `docs/deployment/06-ci-cd-pipeline.md`.

No repite las 5 tareas de `specs/003-agrocampo-functional-refinement/tasks.md`
pendientes de dispositivo Android (T030, T115, T120, T121, T124): esas requieren un
emulador/dispositivo API 24+ y están documentadas en
`docs/verification/003-remaining-plan.md`. Este directorio cubre exclusivamente la
infraestructura de despliegue (Supabase, Firebase, IA, firma Android, CI/CD).

## Checklist de interacción humana pendiente

Nada de lo siguiente se puede automatizar por completo porque cada paso exige crear
una cuenta o un proyecto en un servicio de terceros y aceptar sus condiciones. Orden
recomendado (el primero desbloquea el resto):

| # | Pendiente | Por qué es humano | Guía |
|---|---|---|---|
| 1 | Crear el proyecto Supabase remoto | Alta de cuenta/proyecto en supabase.com | [`01-supabase-project.md`](01-supabase-project.md) |
| 2 | Crear el proyecto Firebase y habilitar FCM | Alta de cuenta/proyecto en Firebase Console | [`02-firebase-fcm.md`](02-firebase-fcm.md) |
| 3 | Generar la API key de Gemini (AgroIA) | Alta en Google AI Studio | [`03-gemini-ai-agroia.md`](03-gemini-ai-agroia.md) |
| 4 | Generar el keystore de firma Android | Decisión y custodia de una contraseña propia | [`04-android-release-signing.md`](04-android-release-signing.md) |
| 5 | Fijar coordenadas reales de la parcela | Dato del negocio, no del código | [`05-weather-coordinates.md`](05-weather-coordinates.md) |
| 6 | Cargar los secretos anteriores en GitHub Actions | Sólo el dueño del repo puede escribir secretos | [`06-ci-cd-pipeline.md`](06-ci-cd-pipeline.md) |

## Verificar el estado localmente

```bash
./scripts/check_deployment_readiness.sh
```

Este script lee `frontend/.env` y `backend/supabase/.env` (ambos locales y
gitignored) y reporta, sin imprimir ningún secreto, qué integraciones ya están
configuradas y cuáles siguen pendientes. No crea ni completa nada por sí mismo.

## Qué NO requiere interacción humana (ya resuelto)

- Pipeline de CI (`.github/workflows/ci.yml`): analiza, formatea y prueba
  backend/frontend, corre el guard de arquitectura, valida el prototipo estático, y
  levanta un stack Supabase local desechable para pgTAP y Edge Functions — todo sin
  secretos.
- Pipeline de build Android (`.github/workflows/android-release.yml`): siempre
  construye un APK de depuración; construye un release firmado sólo cuando los
  secretos existen, y si no existen sigue generando un artefacto de smoke test
  marcado explícitamente como no apto para Play Store — nunca finge un release real.
- Guarda de configuración de producción
  (`backend/tool/verify_runtime_config_guard.dart`, ejecutado en cada push): prueba
  automáticamente que la app rechaza compilarse en modo producción sin
  `SUPABASE_URL`/`SUPABASE_PUBLISHABLE_KEY`, para que nadie debilite esa protección
  sin que CI lo note.
- Plantillas `.env.example` (`backend/supabase/.env.example`,
  `frontend/.env.example`) que documentan cada variable requerida.

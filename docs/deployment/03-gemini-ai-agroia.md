# 3. Generar la API key de Gemini (AgroIA)

**Por qué es un paso humano:** requiere una cuenta Google y aceptar los términos de
Google AI Studio / Google Cloud; una API key es un secreto que no debe generarse ni
elegirse automáticamente.

`backend/supabase/functions/agro-ai/index.ts` ya está implementada y probada
(`backend/supabase/functions/agro-ai/tests/prompt_eval_test.ts`, cubierta en CI vía
`deno test`); sólo le falta la credencial en el entorno de Supabase real.

## Pasos

1. Crear/usar una cuenta Google y entrar a https://aistudio.google.com/app/apikey.
2. Generar una API key. Confirmar que el modelo por defecto del código
   (`gemini-2.5-flash`, ver `backend/supabase/functions/agro-ai/index.ts:19`) está
   disponible para esa key; si se prefiere otro modelo, fijar `GEMINI_MODEL`.
3. Completar `backend/supabase/.env` (copiado desde `backend/supabase/.env.example`):

   ```bash
   GEMINI_API_KEY=<la-key-generada>
   GEMINI_MODEL=gemini-2.5-flash
   ```

4. Cargarla en el proyecto Supabase remoto (no en el repo, no en logs):

   ```bash
   supabase --workdir backend secrets set --env-file backend/supabase/.env
   ```

## Política de privacidad ya implementada (no tocar sin revisar spec.md)

El propio código y sus tests documentan restricciones de producto que ya están
vigentes y que la guía G11 de `specs/003-agrocampo-functional-refinement/quickstart.md`
verifica: las requests a Gemini sólo llevan ID de mensaje, texto del usuario, locale
y metadata de política — nunca datos de parcela, historial, riego, producción o
fotos; ninguna respuesta ejecuta cálculos críticos ni escribe datos. Esto ya corre
en CI (`.github/workflows/ci.yml`, job `supabase-local`) contra los tests unitarios
de Deno; falta repetir el flujo end-to-end (`agro_ai_privacy_flow_test.dart`) en
dispositivo Android, cubierto por T115/T117 en `docs/verification/003-remaining-plan.md`.

## Verificación

```bash
./scripts/check_deployment_readiness.sh
```

Después de cargar el secreto, probar manualmente contra el proyecto remoto:

```bash
curl -i -X POST "https://<project-ref>.supabase.co/functions/v1/agro-ai" \
  -H "Authorization: Bearer <SUPABASE_PUBLISHABLE_KEY>" \
  -H "Content-Type: application/json" \
  -d '{"message":"¿Cuándo conviene regar tomates en verano?"}'
```

Una respuesta 401 significa que falta la cabecera de autorización (comportamiento
esperado, ya probado); una respuesta 200 con texto confirma que `GEMINI_API_KEY`
quedó bien cargada.

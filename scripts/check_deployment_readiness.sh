#!/usr/bin/env bash
# Informa, sin exponer secretos, qué integraciones de AgroCampo están listas para
# producción y cuáles siguen pendientes de credenciales/decisión humana.
#
# Lee archivos .env locales (gitignored) si existen; nunca los crea ni los llena.
# Uso:
#   ./scripts/check_deployment_readiness.sh
#
# Ver docs/deployment/README.md para el detalle de cada paso pendiente.

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

ok=0
missing=0

status_line() {
  local label="$1"
  local present="$2"
  local hint="$3"
  if [ "$present" = "1" ]; then
    printf '  [OK]      %s\n' "$label"
    ok=$((ok + 1))
  else
    printf '  [PENDIENTE] %s — %s\n' "$label" "$hint"
    missing=$((missing + 1))
  fi
}

is_set_in_env_file() {
  # $1 = archivo .env, $2 = nombre de variable
  local file="$1" key="$2"
  [ -f "$file" ] || return 1
  grep -Eq "^${key}=.+" "$file" 2>/dev/null
}

echo "=== AgroCampo — estado de integraciones de despliegue ==="
echo
echo "-- backend/supabase/.env (secretos de Edge Functions) --"
ENV_SUPA="backend/supabase/.env"
if [ ! -f "$ENV_SUPA" ]; then
  echo "  (no existe $ENV_SUPA — copiar desde backend/supabase/.env.example)"
fi
is_set_in_env_file "$ENV_SUPA" GEMINI_API_KEY && s=1 || s=0
status_line "GEMINI_API_KEY (AgroIA)" "$s" "generar en https://aistudio.google.com/app/apikey — docs/deployment/03-gemini-ai-agroia.md"

is_set_in_env_file "$ENV_SUPA" OPEN_METEO_DEFAULT_LATITUDE && s=1 || s=0
status_line "OPEN_METEO_DEFAULT_LATITUDE/LONGITUDE" "$s" "coordenadas reales de la parcela — docs/deployment/05-weather-coordinates.md"

is_set_in_env_file "$ENV_SUPA" FIREBASE_SERVICE_ACCOUNT_JSON && s=1 || s=0
status_line "FIREBASE_SERVICE_ACCOUNT_JSON (push FCM)" "$s" "crear proyecto Firebase y descargar cuenta de servicio — docs/deployment/02-firebase-fcm.md"

echo
echo "-- frontend/.env (valores públicos de build) --"
ENV_FRONT="frontend/.env"
if [ ! -f "$ENV_FRONT" ]; then
  echo "  (no existe $ENV_FRONT — copiar desde frontend/.env.example)"
fi
is_set_in_env_file "$ENV_FRONT" SUPABASE_URL && s=1 || s=0
status_line "SUPABASE_URL" "$s" "crear proyecto Supabase remoto — docs/deployment/01-supabase-project.md"

is_set_in_env_file "$ENV_FRONT" SUPABASE_PUBLISHABLE_KEY && s=1 || s=0
status_line "SUPABASE_PUBLISHABLE_KEY" "$s" "Project Settings → API en el proyecto Supabase remoto"

echo
echo "-- Firma de release Android --"
if [ -f "frontend/android/key.properties" ]; then
  status_line "frontend/android/key.properties" 1 ""
else
  status_line "frontend/android/key.properties" 0 "generar keystore de release — docs/deployment/04-android-release-signing.md"
fi

echo
echo "-- GitHub Actions secrets (no verificable localmente) --"
echo "  Revisar manualmente en GitHub → Settings → Secrets and variables → Actions:"
echo "  SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY, MAP_TILE_URL,"
echo "  ANDROID_KEYSTORE_BASE64, ANDROID_KEYSTORE_PASSWORD, ANDROID_KEY_ALIAS, ANDROID_KEY_PASSWORD"
echo "  (ver docs/deployment/06-ci-cd-pipeline.md)"

echo
echo "=== Resumen: $ok listas, $missing pendientes de interacción humana ==="
if [ "$missing" -gt 0 ]; then
  echo "Ninguna de las pendientes se puede resolver automáticamente: todas requieren"
  echo "crear una cuenta/proyecto externo o generar un secreto. Ver docs/deployment/."
fi
exit 0

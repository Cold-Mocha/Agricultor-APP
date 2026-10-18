#!/usr/bin/env bash
# Informa, sin exponer secretos, qué integraciones de AgroCampo están listas para
# producción y cuáles siguen pendientes de credenciales/decisión humana.
#
# Lee el .env de la raíz (gitignored) si existe; nunca lo crea ni lo llena.
# Uso:
#   ./scripts/check_deployment_readiness.sh
#
# Ver docs/deployment.md para el detalle de cada paso pendiente.

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
# shellcheck source=lib/env.sh
source scripts/lib/env.sh

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

echo "=== AgroCampo — estado de integraciones de despliegue ==="
echo
if [ ! -f "$ENV_FILE" ]; then
  echo "  (no existe $ENV_FILE — copiar desde .env.example)"
fi
load_env

echo "-- [FUNCTIONS] secretos de Edge Functions --"
env_is_set GEMINI_API_KEY && s=1 || s=0
status_line "GEMINI_API_KEY (AgroIA)" "$s" "generar en https://aistudio.google.com/app/apikey — docs/deployment.md#3-gemini-agroia"

env_is_set OPEN_METEO_DEFAULT_LATITUDE && env_is_set OPEN_METEO_DEFAULT_LONGITUDE && s=1 || s=0
status_line "OPEN_METEO_DEFAULT_LATITUDE/LONGITUDE" "$s" "coordenadas reales de la parcela — docs/deployment.md#5-coordenadas-de-la-parcela"

env_is_set FIREBASE_SERVICE_ACCOUNT_JSON && s=1 || s=0
status_line "FIREBASE_SERVICE_ACCOUNT_JSON (push FCM)" "$s" "crear proyecto Firebase y descargar cuenta de servicio — docs/deployment.md#2-firebase-y-fcm"

echo
echo "-- [APP] valores públicos de build --"
env_is_set SUPABASE_URL && s=1 || s=0
status_line "SUPABASE_URL" "$s" "crear proyecto Supabase remoto — docs/deployment.md#1-proyecto-supabase"

env_is_set SUPABASE_PUBLISHABLE_KEY && s=1 || s=0
status_line "SUPABASE_PUBLISHABLE_KEY" "$s" "Project Settings → API en el proyecto Supabase remoto"

echo
echo "-- Firma de release Android --"
if [ -f "frontend/android/key.properties" ]; then
  status_line "frontend/android/key.properties" 1 ""
else
  status_line "frontend/android/key.properties" 0 "generar keystore de release — docs/deployment.md#4-firma-android"
fi

echo
echo "-- GitHub Actions secrets (no verificable localmente) --"
echo "  Revisar manualmente en GitHub → Settings → Secrets and variables → Actions:"
echo "  SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY, MAP_TILE_URL,"
echo "  ANDROID_KEYSTORE_BASE64, ANDROID_KEYSTORE_PASSWORD, ANDROID_KEY_ALIAS, ANDROID_KEY_PASSWORD"
echo "  (ver docs/deployment.md#6-cicd)"

echo
echo "=== Resumen: $ok listas, $missing pendientes de interacción humana ==="
if [ "$missing" -gt 0 ]; then
  echo "Ninguna de las pendientes se puede resolver automáticamente: todas requieren"
  echo "crear una cuenta/proyecto externo o generar un secreto. Ver docs/deployment.md."
fi
exit 0

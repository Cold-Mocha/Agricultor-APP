#!/usr/bin/env bash
# Construye localmente el mismo artefacto de release que produce
# .github/workflows/android-release.yml, a partir de frontend/.env y
# frontend/android/key.properties (ambos gitignored). No crea credenciales; sólo
# las consume si ya existen.
#
# Uso:
#   cp frontend/.env.example frontend/.env   # completar valores reales
#   # generar key.properties con scripts/generate_release_keystore.sh, o a mano
#   ./scripts/build_android_release.sh

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

ENV_FILE="frontend/.env"
if [ -f "$ENV_FILE" ]; then
  # shellcheck disable=SC1090
  set -a; source "$ENV_FILE"; set +a
fi

if [ ! -f "frontend/android/key.properties" ]; then
  echo "AVISO: frontend/android/key.properties no existe todavía." >&2
  echo "El build quedará firmado con la clave debug (NO apto para Play Store)." >&2
  echo "Ver docs/deployment/04-android-release-signing.md o scripts/generate_release_keystore.sh." >&2
fi

DEFINES=()
if [ -n "${MAP_TILE_URL:-}" ]; then
  DEFINES+=("--dart-define=MAP_TILE_URL=$MAP_TILE_URL")
fi
if [ -n "${MAP_INITIAL_LATITUDE:-}" ]; then
  DEFINES+=("--dart-define=MAP_INITIAL_LATITUDE=$MAP_INITIAL_LATITUDE")
fi
if [ -n "${MAP_INITIAL_LONGITUDE:-}" ]; then
  DEFINES+=("--dart-define=MAP_INITIAL_LONGITUDE=$MAP_INITIAL_LONGITUDE")
fi

if [ -n "${SUPABASE_URL:-}" ] && [ -n "${SUPABASE_PUBLISHABLE_KEY:-}" ]; then
  DEFINES+=("--dart-define=AGROCAMPO_ENV=${AGROCAMPO_ENV:-production}")
  DEFINES+=("--dart-define=SUPABASE_URL=$SUPABASE_URL")
  DEFINES+=("--dart-define=SUPABASE_PUBLISHABLE_KEY=$SUPABASE_PUBLISHABLE_KEY")
else
  echo "AVISO: SUPABASE_URL/SUPABASE_PUBLISHABLE_KEY no configurados en frontend/.env." >&2
  echo "El build usará el modo development sin backend remoto (offline-only)." >&2
fi

pushd frontend >/dev/null
flutter pub get
flutter build apk --release "${DEFINES[@]}"
flutter build appbundle --release "${DEFINES[@]}"
popd >/dev/null

echo
echo "APK:  frontend/build/app/outputs/flutter-apk/app-release.apk"
echo "AAB:  frontend/build/app/outputs/bundle/release/app-release.aab"
[ -f "frontend/android/key.properties" ] || echo "Recuerda: este artefacto está firmado con la clave debug, no lo subas a Play Console."

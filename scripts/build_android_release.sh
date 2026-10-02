#!/usr/bin/env bash
# Construye localmente el mismo artefacto de release que produce
# .github/workflows/android-release.yml, a partir del .env de la raíz y de
# frontend/android/key.properties (ambos gitignored). No crea credenciales; sólo
# las consume si ya existen.
#
# Uso:
#   cp .env.example .env   # completar la sección [APP]
#   # generar key.properties con scripts/generate_release_keystore.sh, o a mano
#   ./scripts/build_android_release.sh

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
# shellcheck source=lib/env.sh
source scripts/lib/env.sh
load_env

if [ ! -f "frontend/android/key.properties" ]; then
  echo "AVISO: frontend/android/key.properties no existe todavía." >&2
  echo "El build quedará firmado con la clave debug (NO apto para Play Store)." >&2
  echo "Ver docs/deployment.md o scripts/generate_release_keystore.sh." >&2
fi

DEFINES=()
for key in MAP_TILE_URL MAP_INITIAL_LATITUDE MAP_INITIAL_LONGITUDE; do
  if env_is_set "$key"; then
    DEFINES+=("--dart-define=$key=$(env_value "$key")")
  fi
done

if env_is_set SUPABASE_URL && env_is_set SUPABASE_PUBLISHABLE_KEY; then
  app_env="$(env_value AGROCAMPO_ENV)"
  DEFINES+=("--dart-define=AGROCAMPO_ENV=${app_env:-production}")
  DEFINES+=("--dart-define=SUPABASE_URL=$(env_value SUPABASE_URL)")
  DEFINES+=("--dart-define=SUPABASE_PUBLISHABLE_KEY=$(env_value SUPABASE_PUBLISHABLE_KEY)")
else
  echo "AVISO: SUPABASE_URL/SUPABASE_PUBLISHABLE_KEY no configurados en $ENV_FILE." >&2
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

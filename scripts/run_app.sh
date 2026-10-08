#!/usr/bin/env bash
# Ejecuta la app en el emulador/dispositivo conectado con los valores públicos del
# .env de la raíz (sección [APP]). Si el .env no define AGROCAMPO_ONLINE, arranca en
# modo local (sin login ni Supabase).
#
# Uso:
#   ./scripts/run_app.sh                 # flutter run
#   ./scripts/run_app.sh -d emulator-5554 --release
#
# Los argumentos extra se pasan tal cual a `flutter run`.

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
# shellcheck source=lib/env.sh
source scripts/lib/env.sh
load_env
build_dart_defines
env_is_set AGROCAMPO_ONLINE || DART_DEFINES+=("--dart-define=AGROCAMPO_ONLINE=false")

cd frontend
flutter run "${DART_DEFINES[@]}" "$@"

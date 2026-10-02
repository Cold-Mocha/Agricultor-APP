#!/usr/bin/env bash
# Ejecuta la app en el emulador/dispositivo conectado con los valores públicos del
# .env de la raíz (sección [APP]). Sin .env, arranca en modo development local.
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

cd frontend
flutter run "${DART_DEFINES[@]}" "$@"

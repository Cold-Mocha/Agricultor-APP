#!/usr/bin/env bash
# Entrega a Supabase sólo los secretos de Edge Functions del .env de la raíz
# (sección [FUNCTIONS]). Las variables públicas del APK no se envían.
#
# Uso:
#   ./scripts/supabase_secrets.sh push    # carga los secretos en el proyecto vinculado
#   ./scripts/supabase_secrets.sh serve   # sirve las Edge Functions localmente con ellos
#
# El archivo filtrado es temporal (permisos 600) y se borra al terminar.

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
# shellcheck source=lib/env.sh
source scripts/lib/env.sh

command="${1:-}"
case "$command" in
  push | serve) ;;
  *)
    echo "Uso: $0 push|serve" >&2
    exit 2
    ;;
esac

if [ ! -f "$ENV_FILE" ]; then
  echo "No existe $ENV_FILE — copiar desde .env.example y completar la sección [FUNCTIONS]." >&2
  exit 1
fi
load_env

tmp_env="$(mktemp)"
trap 'rm -f "$tmp_env"' EXIT
write_function_env "$tmp_env"

if [ "$command" = "push" ]; then
  if [ ! -s "$tmp_env" ]; then
    echo "No hay secretos de Edge Functions definidos en $ENV_FILE." >&2
    exit 1
  fi
  supabase --workdir backend secrets set --env-file "$tmp_env"
else
  supabase --workdir backend functions serve --env-file "$tmp_env"
fi

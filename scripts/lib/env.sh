#!/usr/bin/env bash
# Lectura del .env central de AgroCampo. Se carga con `source`; no imprime valores.
#
# El archivo se parsea línea a línea sin evaluarlo como shell, para que valores como
# FIREBASE_SERVICE_ACCOUNT_JSON (JSON con espacios y comillas) no se ejecuten.

ENV_FILE="${AGROCAMPO_ENV_FILE:-.env}"

# Embebidas en el APK: sólo valores públicos.
APP_PUBLIC_KEYS=(
  AGROCAMPO_ENV
  SUPABASE_URL
  SUPABASE_PUBLISHABLE_KEY
  MAP_TILE_URL
  MAP_INITIAL_LATITUDE
  MAP_INITIAL_LONGITUDE
)

# Secretos de Edge Functions: nunca se pasan a Flutter.
FUNCTION_SECRET_KEYS=(
  GEMINI_API_KEY
  GEMINI_MODEL
  OPEN_METEO_FORECAST_URL
  OPEN_METEO_DEFAULT_LATITUDE
  OPEN_METEO_DEFAULT_LONGITUDE
  FIREBASE_SERVICE_ACCOUNT_JSON
)

declare -A ENV_VALUES=()
declare -A ENV_LINES=()

load_env() {
  [ -f "$ENV_FILE" ] || return 0
  local line key value
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%$'\r'}"
    [[ "$line" =~ ^[[:space:]]*(#|$) ]] && continue
    [[ "$line" == *=* ]] || continue
    key="${line%%=*}"
    key="${key#export }"
    key="${key//[[:space:]]/}"
    value="${line#*=}"
    if [[ "$value" =~ ^\"(.*)\"$ ]] || [[ "$value" =~ ^\'(.*)\'$ ]]; then
      value="${BASH_REMATCH[1]}"
    fi
    ENV_VALUES["$key"]="$value"
    ENV_LINES["$key"]="$key=${line#*=}"
  done <"$ENV_FILE"
}

env_value() {
  printf '%s' "${ENV_VALUES[$1]:-}"
}

env_is_set() {
  [ -n "${ENV_VALUES[$1]:-}" ]
}

# Llena el arreglo DART_DEFINES con las variables públicas definidas en el .env.
build_dart_defines() {
  DART_DEFINES=()
  local key
  for key in "${APP_PUBLIC_KEYS[@]}"; do
    if env_is_set "$key"; then
      DART_DEFINES+=("--dart-define=$key=$(env_value "$key")")
    fi
  done
}

# Escribe en $1 sólo los secretos de Edge Functions definidos, con permisos 600.
write_function_env() {
  local target="$1" key
  : >"$target"
  chmod 600 "$target"
  for key in "${FUNCTION_SECRET_KEYS[@]}"; do
    if env_is_set "$key"; then
      printf '%s\n' "${ENV_LINES[$key]}" >>"$target"
    fi
  done
}

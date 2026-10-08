#!/usr/bin/env bash
# Genera un keystore de release nuevo para AgroCampo y el frontend/android/key.properties
# correspondiente. Requiere el JDK (keytool), que ya trae Android Studio/Flutter.
#
# Este script SÓLO crea el archivo local; la decisión de qué contraseña usar y la
# custodia posterior del keystore siguen siendo un paso humano — ver
# docs/deployment.md#4-firma-android. Perder este archivo o su
# contraseña impide volver a actualizar la app ya publicada en Play Store: haz
# backup fuera del repositorio (está en .gitignore a propósito).

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

KEYSTORE_PATH="frontend/android/app/release.keystore"
KEY_PROPERTIES_PATH="frontend/android/key.properties"
ALIAS="agrocampo-release"

if [ -f "$KEYSTORE_PATH" ]; then
  echo "Ya existe $KEYSTORE_PATH — bórralo manualmente primero si quieres regenerarlo." >&2
  exit 1
fi

command -v keytool >/dev/null || {
  echo "keytool no está en PATH (viene con el JDK/Android Studio)." >&2
  exit 1
}

echo "Se te pedirá una contraseña de keystore y datos del certificado (organización, etc.)."
keytool -genkey -v \
  -keystore "$KEYSTORE_PATH" \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias "$ALIAS"

read -rsp "Repite la misma contraseña para confirmarla en key.properties: " STORE_PASSWORD
echo

cat > "$KEY_PROPERTIES_PATH" <<EOF
storePassword=$STORE_PASSWORD
keyPassword=$STORE_PASSWORD
keyAlias=$ALIAS
storeFile=app/release.keystore
EOF

echo
echo "Creado: $KEYSTORE_PATH y $KEY_PROPERTIES_PATH (ambos gitignored)."
echo "Siguiente paso: subir el keystore como secreto de GitHub Actions."
echo "  base64 -w0 $KEYSTORE_PATH   # copiar la salida a ANDROID_KEYSTORE_BASE64"
echo "Detalle completo: docs/deployment.md#4-firma-android"

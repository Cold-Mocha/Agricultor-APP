# 4. Generar el keystore de firma Android

**Por qué es un paso humano:** un keystore de release representa la identidad del
publicador en Play Store de forma permanente; su contraseña debe elegirla y
custodiarla una persona, nunca generarse ni commitearse automáticamente. Perder el
keystore de un app ya publicada impide subir actualizaciones futuras.

Hoy `frontend/android/app/build.gradle.kts` ya contempla este flujo (busca
`rootProject.file("key.properties")` y cae a la firma debug si no existe), así que
no falta código: falta generar el archivo y sus secretos derivados.

## Pasos

1. Generar el keystore localmente:

   ```bash
   ./scripts/generate_release_keystore.sh
   ```

   Pide una contraseña interactivamente y crea:
   - `frontend/android/app/release.keystore` (gitignored)
   - `frontend/android/key.properties` (gitignored)

   Alternativa manual con `keytool` si se prefiere no usar el script: ver los
   comandos exactos dentro de `scripts/generate_release_keystore.sh`.

2. **Hacer backup del keystore y su contraseña fuera del repositorio** (gestor de
   contraseñas + almacenamiento cifrado). No hay forma de recuperarlo si se pierde.

3. Cargarlo como secretos de GitHub Actions para que
   `.github/workflows/android-release.yml` pueda firmar builds de CI:

   ```bash
   base64 -w0 frontend/android/app/release.keystore
   ```

   Crear en GitHub → Settings → Secrets and variables → Actions:

   | Secreto | Valor |
   |---|---|
   | `ANDROID_KEYSTORE_BASE64` | salida del comando `base64` anterior |
   | `ANDROID_KEYSTORE_PASSWORD` | la contraseña elegida en el paso 1 |
   | `ANDROID_KEY_ALIAS` | `agrocampo-release` (o el alias elegido) |
   | `ANDROID_KEY_PASSWORD` | la contraseña de la clave (normalmente igual a la del store) |

   Detalle completo de todos los secretos del pipeline:
   [`06-ci-cd-pipeline.md`](06-ci-cd-pipeline.md).

4. Build local de verificación:

   ```bash
   ./scripts/build_android_release.sh
   ```

## Verificación

- `./scripts/check_deployment_readiness.sh` reporta `key.properties` como `[OK]`.
- `.github/workflows/android-release.yml`, job `release-build`, deja de emitir el
  aviso `::warning::` sobre artefacto no apto para Play Store una vez cargados los
  4 secretos de la tabla anterior.
- El AAB (`frontend/build/app/outputs/bundle/release/app-release.aab`) es el
  artefacto que se sube a Play Console — no el APK.

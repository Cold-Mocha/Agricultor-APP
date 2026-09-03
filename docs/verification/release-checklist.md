# Checklist de release Android

- [x] Application ID `cl.agrocampo.app`, minSdk 24, target/compile SDK 36.
- [x] Java 17 y core library desugaring habilitados.
- [x] Permisos Internet, ubicación, cámara y notificaciones declarados.
- [x] Claves externas sólo por entorno/secrets; archivos sensibles ignorados.
- [x] Análisis, unit/widget tests y goldens limpios.
- [x] APK release interno generado con configuración Supabase/Open-Meteo/mapa: 76.766.022 bytes, SHA-256 `A6E829D890C094D3CD148116B22D44DDC90B989A696401728B039087E08A4965`.
- [x] AAB release interno generado: 67.096.597 bytes, SHA-256 `957F75376E18BA3CB02BA70F2E7BF33A05AC692F4770435C82C2E78F5AF0E925`.
- [ ] Integration tests instrumentados en emulador/dispositivo Android.
- [x] Edge Function tests Deno: 5 aprobados, incluidos contrato Open-Meteo y geometría autorizada.
- [ ] Supabase pgTAP en entorno local/CI.
- [x] OpenStreetMap sin API key, con user agent `cl.agrocampo.app` y atribución visible.
- [x] Supabase remoto migrado (0001–0019), `weather-proxy` y `agro-ai` desplegados, y Open-Meteo configurado server-side.
- [ ] Firebase y Gemini configurados mediante valores de entorno/secrets.
- [ ] Keystore de producción y `key.properties` aportados por el propietario.
- [ ] Refirmar/generar `app-release.aab` con keystore de producción y archivar mapping/símbolos.

Un APK/AAB con firma debug sirve sólo para evaluación interna y nunca debe subirse a Play Console.

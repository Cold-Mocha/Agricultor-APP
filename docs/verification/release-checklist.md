# Checklist de release Android

- [x] Application ID `cl.agrocampo.app`, minSdk 24, target/compile SDK 36.
- [x] Java 17 y core library desugaring habilitados.
- [x] Permisos Internet, ubicación, cámara y notificaciones declarados.
- [x] Claves externas sólo por entorno/secrets; archivos sensibles ignorados.
- [x] Análisis, unit/widget tests y goldens limpios.
- [x] APK debug generado: 225.809.944 bytes, SHA-256 `78214B1A5CF82CB771C323016C964C104F737272B4720521DD88A60FB3F94D70`.
- [x] AAB release interno generado: 67.096.597 bytes, SHA-256 `957F75376E18BA3CB02BA70F2E7BF33A05AC692F4770435C82C2E78F5AF0E925`.
- [ ] Integration tests instrumentados en emulador/dispositivo Android.
- [ ] Supabase pgTAP y Edge Function tests en entorno local/CI.
- [ ] `GOOGLE_MAPS_ANDROID_KEY`, Supabase, Firebase, WeatherAPI y Gemini configurados.
- [ ] Keystore de producción y `key.properties` aportados por el propietario.
- [ ] Refirmar/generar `app-release.aab` con keystore de producción y archivar mapping/símbolos.

Un APK/AAB con firma debug sirve sólo para evaluación interna y nunca debe subirse a Play Console.

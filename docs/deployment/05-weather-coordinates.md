# 5. Fijar las coordenadas reales de la parcela

**Por qué es un paso humano:** es un dato del negocio (dónde está la explotación
agrícola real), no algo que se pueda inferir del código o generar automáticamente.

Open-Meteo (`backend/supabase/functions/weather-proxy/index.ts`) es gratuito y no
necesita API key, pero usa una latitud/longitud *fallback* cuando la request no trae
coordenadas explícitas de un sector. Hoy esas variables están vacías.

## Pasos

1. Obtener la latitud/longitud real de la parcela (Google Maps, GPS del predio,
   etc.). El valor de ejemplo usado en tests/documentación es Temuco, Chile
   (`-38.7363, -72.5974`) — **no usar ese valor en producción**, es sólo un fixture.
2. Completar `backend/supabase/.env`:

   ```bash
   OPEN_METEO_DEFAULT_LATITUDE=<latitud-real>
   OPEN_METEO_DEFAULT_LONGITUDE=<longitud-real>
   ```

3. Cargarlo al proyecto remoto:

   ```bash
   supabase --workdir backend secrets set --env-file backend/supabase/.env
   ```

4. Si además se quiere que el mapa (`frontend`) centre la vista inicial ahí en vez
   del fallback de Temuco (`frontend/lib/src/modules/territory/presentation/pages/territory_map_page.dart`),
   completar también en `frontend/.env`:

   ```bash
   MAP_INITIAL_LATITUDE=<latitud-real>
   MAP_INITIAL_LONGITUDE=<longitud-real>
   ```

## Verificación

```bash
./scripts/check_deployment_readiness.sh
```

El propio `weather-proxy` normaliza y expone `attribution_url` apuntando a
Open-Meteo; no requiere facturación mientras el volumen de requests se mantenga
dentro de su capa gratuita (ver https://open-meteo.com/en/pricing).

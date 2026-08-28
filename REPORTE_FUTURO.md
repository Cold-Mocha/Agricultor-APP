# Reporte Futuro: Labores, Cuadrantes y Mapa Real

> **Documento histórico/no normativo.** Registra decisiones y estado del prototipo `index.html`.
> No es un módulo funcional ni añade alcance al MVP Android. La única fuente funcional oficial es
> `specs/001-agrocampo-android-mvp/`; toda decisión visual vigente pertenece a `master.md`.

## Objetivo

Este reporte consolida mejoras solicitadas para AgroCampo. La app actual ya esta publicada como sitio estatico en GitHub Pages; los hitos de labores, 8 cuadrantes, registro y apicultura quedaron implementados en `index.html` con pruebas de aceptacion actualizadas.

Google Maps quedo preparado para activacion con API key, pero no se puede dejar como mapa real definitivo sin coordenadas reales de la parcela ni configuracion de Google Cloud.

## Cambios Solicitados

### 1. Inicio: Labores

Estado: implementado.

Cambiar el titulo `Acciones rapidas` por `Labores`.

Las labores principales deben ser:

- Riego
- Suelo
- Fertilizacion
- Control de Enfermedades y Plagas

La recomendacion es que cada labor abra directamente la pantalla correspondiente. Para `Fertilizacion` y `Control de Enfermedades y Plagas`, se puede abrir `Registrar` con el tipo de accion preseleccionado.

### 2. Ocho Cuadrantes

Estado: implementado con datos fijos en `state.sectors`, `state.mapSections` e historial inicial.

Actualizar la app para trabajar con 8 cuadrantes:

| Cuadrante | Cultivo / Actividad |
| --- | --- |
| 1 | Frambuesa |
| 2 | Arandanos |
| 3 | Papas |
| 4 | Sandia y melones |
| 5 | Maiz |
| 6 | Physalis |
| 7 | Frutilla |
| 8 | Apicultura |

Se deben actualizar `state.sectors`, datos mock, iconos, colores, historial inicial y pantallas que listan cuadrantes.

### 3. Mapa Con Google Maps Embebido Real

Estado: preparado sin activarlo por defecto.

La mejora deseada es reemplazar o complementar el mapa estatico actual con Google Maps embebido real.

Requisitos tecnicos:

- Definir coordenadas reales de la parcela.
- Guardar coordenadas por cuadrante o poligono.
- Integrar Google Maps JavaScript API.
- Configurar una API key de Google Cloud.
- Restringir la API key al dominio de GitHub Pages.
- Dibujar poligonos por cuadrante sobre el mapa.
- Al pinchar un cuadrante, abrir el detalle correspondiente en tiempo real.

Implementacion actual:

- Se mantiene el mapa estatico como respaldo.
- `state.googleMaps` contiene `apiKey`, `enabled`, `center` y `zoom`.
- `state.mapSections[].gps` guarda coordenadas fijas por cuadrante.
- Si `state.googleMaps.enabled` es `true` y existe `apiKey`, la app carga Google Maps JavaScript API y dibuja poligonos clickeables.

Riesgos y dependencias:

- GitHub Pages es estatico; la API key queda expuesta en frontend, por eso debe estar restringida por dominio.
- Google Maps puede tener costos si supera el uso gratuito.
- Para guardar cambios reales de coordenadas se necesitara backend o almacenamiento externo. Sin backend, las coordenadas seran datos fijos en `index.html`.

Implementacion recomendada:

1. Mantener el mapa estatico como respaldo.
2. Agregar coordenadas mock por cuadrante.
3. Integrar Google Maps con poligonos de solo lectura.
4. Luego habilitar edicion de vertices si se define persistencia.

### 4. Registro

Estado: implementado.

En `Registrar`, el Paso 1 debe mostrar los 8 cuadrantes.

El Paso 2 se mantiene conceptualmente igual, pero debe usar nombres mas agronomicos:

- Suelo
- Riego
- Fertilizacion
- Control de Enfermedades y Plagas
- Cultivo
- Cosecha
- Apicultura
- Otra

El Paso 3 para suelo debe incluir:

- Humedad
- pH
- Temperatura del Suelo
- EC / Electro Conductividad
- N / Nitrogeno
- P / Fosforo
- K / Potasio

### 5. Apicultura Para Cuadrante 8

Estado: implementado en el registro y en la ficha del cuadrante 8.

Cuando el usuario seleccione `Cuadrante 8 - Apicultura`, el registro debe mostrar campos especificos:

- Revision de colmenas
- Fecha
- Nombre del apicultor
- Numero de colmenas
- Tipo de tareas
- Estado de postura
- Enfermedad y plaga
- Alimentacion
- Estado de la reina
- Colocacion de alza
- Cosecha

La pantalla de detalle del cuadrante 8 tambien deberia usar textos de apicultura en vez de metricas agricolas cuando corresponda.

## Plan De Implementacion Ejecutado

1. Actualizar pruebas de aceptacion para exigir 8 cuadrantes, `Labores`, nuevos campos de suelo y campos de apicultura.
2. Expandir `state.sectors` y `state.mapSections` a 8 cuadrantes.
3. Ajustar `homeScreen`, `sectorsScreen`, `sectorPicker`, `registerScreen` y `activityDetails`.
4. Agregar iconos faltantes para papa, sandia/melon, maiz, physalis y apicultura.
5. Mantener preseleccion de labor desde Inicio hacia Registro.
6. Crear capa inicial de Google Maps con poligonos fijos y activacion opcional.
7. Verificar localmente con `node agrocampo-acceptance.test.js`.
8. Actualizar `CONTEXTO.md` despues de implementar.

## Decision Pendiente Para Mapa Real

Antes de implementar Google Maps embebido real, se necesita decidir:

- Coordenadas reales de la parcela.
- Si los poligonos seran solo visuales o editables.
- Si se acepta usar una API key publica restringida por dominio.
- Si en el futuro se necesitara backend para guardar coordenadas editadas.

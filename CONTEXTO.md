# Contexto Actual

## Autoridades del proyecto

| Área | Fuente oficial |
|---|---|
| Requisitos y alcance Android | `specs/001-agrocampo-android-mvp/spec.md` |
| Arquitectura, datos, contratos y backlog | `specs/001-agrocampo-android-mvp/` |
| UI/UX y Design System | `master.md` |
| Prototipo desplegado | `index.html` (evidencia no normativa) |
| Prototipo visual auditado | `agrocampo-highfi.html` (evidencia no normativa) |

No existe otro módulo funcional. Este contexto describe el prototipo y el estado del repositorio;
no puede añadir requisitos a la especificación canónica.

## Estado del prototipo

La versión publicada es una app estática de alta fidelidad en `index.html`. No usa framework, build
ni backend. El repositorio también contiene un scaffold Flutter inicial; todavía no representa las
capacidades descritas por el backlog canónico.

## Pantallas principales

- `Inicio`: clima, acceso a cuadrantes y labores principales.
- `Sectores`: listado de 8 cuadrantes, mapa de cuadrantes y resumen historial.
- `Mapa de parcela`: mapa con imagen de fondo, parcelas transparentes por color de cultivo y vertices arrastrables. Incluye preparacion opcional para Google Maps JavaScript API con poligonos fijos si se configura una API key en `state.googleMaps`.
- `Registrar`: flujo de 3 pasos: seleccionar cultivo, seleccionar accion y completar campos segun la accion.
- `Suelo`: formulario de medicion manual.
- `Riego`: calculo deterministico con tipo de riego.
- `AgroIA`: chat contextual sin selector de parcela.
- `Perfil`, `Mas`, `Configuracion` e `Historial`: vistas auxiliares.

## Flujos clave

- Desde un cuadrante, las acciones van directo a su pantalla correspondiente.
- Desde Inicio, `Riego` y `Suelo` abren sus pantallas directas; `Fertilizacion` y `Control de Enfermedades y Plagas` abren `Registrar` con la labor preseleccionada.
- `Cambiar cultivo` abre una pantalla para elegir la fruta nueva y guarda el cambio en historial.
- `Ver historial` permanece disponible en el menu de acciones del cuadrante.
- Las parcelas del mapa no muestran numeros; muestran el icono/cultivo correspondiente.
- El cuadrante 8 corresponde a `Apicultura`; su ficha muestra colmenas, estado de la reina, estado sanitario, alimentacion y ultima revision en vez de metricas agricolas.
- `Registrar` incluye campos agronomicos de suelo y campos especificos de apicultura.

## Relación con la implementación Android

El prototipo sigue sin backend. Google Maps web queda preparado sólo como demostración mediante
`state.googleMaps`; la implementación Android, sus proveedores y persistencia se rigen por el plan
y contratos canónicos, no por esta integración estática.

Para pasar a mapa real editable falta definir coordenadas reales de la parcela, configurar una API key restringida al dominio de GitHub Pages y agregar backend o almacenamiento externo si se quiere guardar vertices editados por usuarios. Sin esa persistencia, los cambios de coordenadas solo pueden vivir como datos fijos en `index.html`.

## Deploy

La URL publicada es `https://cold-mocha.github.io/Agricultor-APP/`. GitHub Pages usa el workflow `.github/workflows/pages.yml`, que corre `node agrocampo-acceptance.test.js`, copia `index.html`, `ImagenSuperior.png` y `assets/` a `_site`, y despliega con `actions/deploy-pages`.

## Archivos relevantes

- `index.html`: app completa y entrada de GitHub Pages.
- `agrocampo-acceptance.test.js`: validaciones de comportamiento, textos y estructura.
- `assets/icons/`: iconos SVG de cultivos.
- `ImagenSuperior.png`: imagen base del mapa.
- `specs/001-agrocampo-android-mvp/`: única fuente funcional Android.
- `master.md`: Design System oficial independiente.
- `AGENTS.md`: guía de contribución y separación entre prototipo/producto.

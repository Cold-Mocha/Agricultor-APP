# Contexto Actual

## Estado del proyecto

AgroCampo es una app estatica de alta fidelidad en `index.html`. No usa framework, build ni backend. Todo el HTML, CSS y JavaScript vive en un solo archivo para facilitar el despliegue directo en GitHub Pages.

## Pantallas principales

- `Inicio`: clima, acceso a cuadrantes y labores principales.
- `Sectores`: listado de cuadrantes, mapa de cuadrantes y resumen historial.
- `Mapa de parcela`: mapa con imagen de fondo, parcelas transparentes por color de cultivo y vertices arrastrables.
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

## Deploy

La URL publicada es `https://cold-mocha.github.io/Agricultor-APP/`. GitHub Pages usa el workflow `.github/workflows/pages.yml`, que corre `node agrocampo-acceptance.test.js`, copia `index.html`, `ImagenSuperior.png` y `assets/` a `_site`, y despliega con `actions/deploy-pages`.

## Archivos relevantes

- `index.html`: app completa y entrada de GitHub Pages.
- `agrocampo-acceptance.test.js`: validaciones de comportamiento, textos y estructura.
- `assets/icons/`: iconos SVG de cultivos.
- `ImagenSuperior.png`: imagen base del mapa.
- `AGENTS.md`: guia de contribucion para futuros cambios.

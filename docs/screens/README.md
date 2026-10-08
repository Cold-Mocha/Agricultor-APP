# Pantallas de AgroCampo

Inventario visual de la app Android, pantalla por pantalla. Sirve como punto de partida para revisar
y cambiar la UI; la autoridad visual sigue siendo [`master.md`](../../master.md).

**Captura:** 2026-10-02, después de corregir los issues I1–I8 · Samsung Galaxy S21 Ultra (720×1600
lógicos) · build debug con `AGROCAMPO_ONLINE=false` (modo local) · datos: una parcela "Frutillas"
(Temuco) con un cuadrante de cultivo sin cultivo ni temporada. Se recortaron la barra de estado y la
de navegación de Android. La marca vertical delgada en el borde izquierdo de algunas capturas es el
panel Edge de Samsung, no la app.

Las capturas de Revisión apícola y Fotografías (`12_*`, `13_foto`) son de la versión anterior: tras
I8 sólo se abren desde un sector apícola y el escenario de captura no tiene uno.

Cada ficha indica: **ruta** (`go_router`), **propósito**, **CTA** (call to action principal),
**qué hace** y **qué debería mostrar** cuando hay datos. Las marcas ✅ señalan comportamiento
corregido; el detalle de cada corrección está en [`ISSUES.md`](./ISSUES.md).

## Índice

| Pestaña | Pantallas |
|---|---|
| Inicio | [Inicio](#1-inicio) · [Perfil](#23-perfil) y subpantallas · [Parcelas](#32-parcelas) |
| Sectores | [Cuadrantes](#2-cuadrantes-sectores) · [Detalle de cuadrante](#3-detalle-de-cuadrante) · [Cultivos del sector](#4-cultivos-del-sector-rotación) · [Historial](#5-historial) · [Mapa](#6-mapa-de-cuadrantes) |
| Registrar | [Registrar labor](#7-registrar-labor) · [Riego](#8-riego) · [Riego por goteo](#9-riego-por-goteo-configuración) · [Suelo](#10-medición-de-suelo) · [Producción](#11-producción) · [Revisión apícola](#12-revisión-apícola) · [Fotografías](#13-fotografías) |
| AgroIA | [AgroIA](#14-agroia) |
| Más | [Más](#15-más) · [Temporadas](#16-temporadas) · [Nueva temporada](#17-nueva-temporada) · [Catálogo](#18-catálogo-de-cultivos) · [Recordatorios](#19-recordatorios) · [Sincronización](#20-sincronización) · [Exportar](#21-exportar) · [Configuración](#22-configuración) |

Todas las pantallas comparten la barra inferior de 5 pestañas. No hay banner global: la
sincronización es automática y no se muestra en la UI.

---

## 1. Inicio

<img src="01_inicio.webp" width="240"> <img src="01_inicio_b.webp" width="240">

- **Ruta:** `/inicio`
- **Propósito:** resumen del día en la parcela activa y acceso rápido a las labores frecuentes.
- **CTA:** tarjetas de **Labores** (Riego, Suelo, Fertilización, Control de enfermedades y plagas) y
  **Ver cuadrantes**. Sin parcela: **Crear parcela**.
- **Qué hace:** muestra el clima de la localidad de la parcela, el acceso a los cuadrantes y abre cada
  formulario de labor con el contexto ya fijado. El ícono superior abre el Perfil.
- **Qué debería mostrar:** temperatura, humedad y riesgo de helada actualizados (online) o el último
  dato guardado con su antigüedad; sin parcela, el estado vacío "Crea tu primera parcela".
  ✅ En modo local la tarjeta explica "Disponible al activar el respaldo en la nube." y no ofrece
  actualizar; sólo editar la localidad (I5).

## 2. Cuadrantes (Sectores)

<img src="02_sectores.webp" width="240">

- **Ruta:** `/sectores`
- **Propósito:** ver los cuadrantes (sectores) de la parcela activa y su estado.
- **CTA:** tocar una **tarjeta de cuadrante**; ícono de mapa / **Mapa de cuadrantes**.
- **Qué hace:** selector de contexto (Parcela y Sector), lista de cuadrantes con cultivo, último riego
  y último registro, y una vista previa del mapa.
- **Qué debería mostrar:** cada cuadrante con su cultivo vigente, estado y actividad reciente; el
  indicador "Cambios por respaldar" mientras haya pendientes.

## 3. Detalle de cuadrante

<img src="03_sector_detalle.webp" width="240"> <img src="03_sector_detalle_b.webp" width="240"> <img src="03_sector_detalle_c.webp" width="240">

- **Ruta:** `/sectores/:id`
- **Propósito:** ficha del cuadrante con su cultivo, métricas y acciones.
- **CTA:** **Cultivo y rotación**; acciones **Registrar labor**, **Riego**, **Suelo**, **AgroIA**,
  **Cambiar cultivo**, **Ver historial**.
- **Qué hace:** muestra superficie, humedad del suelo, último riego y última medición, y abre cada flujo
  con el cuadrante como contexto. En cuadrantes de apicultura ofrece la revisión apícola.
- **Qué debería mostrar:** cultivo y temporada vigentes, y los últimos valores registrados en vez de
  "Sin registro".

## 4. Cultivos del sector (rotación)

<img src="04_rotacion.webp" width="240"> <img src="04_rotacion_planificar.webp" width="240">

- **Ruta:** `/sectores/:id/rotacion`
- **Propósito:** cambiar el cultivo del cuadrante sin perder el historial.
- **CTA:** **Cambiar a otro cultivo** e **Intercambiar cultivo con otro sector**, uno bajo el otro;
  sin temporadas, **Administrar temporadas**.
- **Qué hace:** lista las asignaciones de cultivo con fechas efectivas. Cambiar exige una temporada
  activa. El cultivo de una temporada futura se elige al crearla (la app lo pregunta).
- **Qué debería mostrar:** cultivo vigente y planificados con su vigencia; el intercambio entre dos
  sectores cuando existe más de uno.

## 5. Historial

<img src="05_historial_sector.webp" width="240">

- **Ruta:** `/sectores/:id/historial` y `/mas/historial` (misma pantalla).
- **Propósito:** línea temporal agrícola del sector.
- **CTA:** filtros **Todo / Labores / Cultivos / Suelo**.
- **Qué hace:** lista labores, cambios de cultivo y mediciones del sector seleccionado, incluidos los
  registros offline.
- **Qué debería mostrar:** eventos en orden cronológico con su fecha, tipo y estado de respaldo.

## 6. Mapa de cuadrantes

<img src="06_mapa_cuadrantes.webp" width="240"> <img src="06_mapa_nuevo_cuadrante.webp" width="240">

- **Ruta:** `/sectores/parcela/:parcelId/mapa`
- **Propósito:** ubicar y dibujar los cuadrantes sobre el mapa (OpenStreetMap).
- **CTA:** **Nuevo cuadrante**; con uno seleccionado, **Ver cuadrante** y **Editar**; **Usar mi
  ubicación**.
- **Qué hace:** en modo dibujo se agregan puntos tocando el mapa (mínimo tres), se elige la
  **Categoría obligatoria** y se **Confirma**; **Deshacer**, **Quitar último punto** y **Cancelar**.
  La geometría sólo cambia al confirmar.
- **Qué debería mostrar:** los polígonos de todos los cuadrantes; si el mapa no carga, la lista textual
  de cuadrantes sigue disponible.

## 7. Registrar labor

<img src="07_registrar.webp" width="240"> <img src="07_registrar_b.webp" width="240"> <img src="07_registrar_tipos.webp" width="240">

- **Ruta:** `/registrar` y `/registrar/labor/:tipo`
- **Propósito:** registrar cualquier labor del cuaderno de campo en tres pasos.
- **CTA:** **Guardar actividad**; algunos tipos derivan a su flujo especializado.
- **Qué hace:** 1) confirma parcela y sector; 2) tipo y fecha; 3) muestra sólo los campos del tipo
  elegido. Tipos: Riego, Suelo, Fertilización, Control de enfermedades y plagas, Cultivo, Siembra,
  Poda, Cosecha, Apicultura y Otra labor.
- **Qué debería mostrar:** después de guardar, confirmación de guardado local y la labor en el
  historial.

Variantes del paso "3. Detalle":

| Tipo | Campos | CTA | Captura |
|---|---|---|---|
| Fertilización | Método, Producto o fertilizante, Cantidad, Unidad, Detalle del método, Observaciones | Guardar actividad | [07_registrar_b](07_registrar_b.webp) |
| Control de enfermedades y plagas | Producto, Plaga o enfermedad objetivo, Dosis, Unidad, Días de carencia, Observaciones | Guardar actividad | [07_registrar_plagas](07_registrar_plagas.webp) |
| Cultivo | Labor realizada, Estado observado, Variedad, Observaciones | Guardar actividad | [07_registrar_cultivo](07_registrar_cultivo.webp) |
| Siembra | Cantidad de semilla, Unidad, Distancia entre plantas, Observaciones | Guardar actividad | [07_registrar_siembra](07_registrar_siembra.webp) |
| Poda | Método de poda, Plantas intervenidas, Observaciones | Guardar actividad | [07_registrar_poda](07_registrar_poda.webp) |
| Otra labor | Nombre de la labor, Descripción, Observaciones | Guardar actividad | [07_registrar_otra](07_registrar_otra.webp) |
| Cosecha | Aviso: se registra junto con la producción | **Registrar cosecha y producción** → [Producción](#11-producción) | [07_registrar_cosecha](07_registrar_cosecha.webp) |
| Apicultura | Sólo en sectores apícolas (✅ I8): el selector no la ofrece en sectores de cultivo | **Abrir revisión apícola** → [Revisión apícola](#12-revisión-apícola) | — |
| Riego / Suelo | — | Derivan a [Riego](#8-riego) y [Suelo](#10-medición-de-suelo) | — |

## 8. Riego

<img src="08_riego.webp" width="240"> <img src="08_riego_b.webp" width="240">

- **Ruta:** `/registrar/riego`
- **Propósito:** registrar un riego y estimar su volumen.
- **CTA:** **Guardar riego**; secundarios **Calcular de forma determinística** y **Configurar goteo del
  sector**.
- **Qué hace:** con duración y caudal estima el volumen; usa la configuración de goteo del sector. Si
  no hay regla agronómica para el cultivo y suelo, lo avisa y permite el registro básico.
- **Qué debería mostrar:** tipo de riego y suelo legibles, y el volumen estimado con su explicación.
  ✅ Los selectores muestran Goteo / Aspersión / Surco / Gravedad y Arenoso / Franco / Arcilloso /
  No lo sé (I2).

## 9. Riego por goteo (configuración)

<img src="09_config_goteo.webp" width="240"> <img src="09_config_goteo_b.webp" width="240">

- **Ruta:** `/registrar/riego/configuracion`
- **Propósito:** configuración permanente del goteo del sector.
- **CTA:** **Guardar nueva versión**.
- **Qué hace:** guarda cantidad de plantas, goteros, caudal total efectivo, presión y notas como una
  versión nueva; los riegos anteriores conservan la versión que usaron.
- **Qué debería mostrar:** la configuración vigente (hoy "Sin configuración vigente.").

## 10. Medición de suelo

<img src="10_suelo.webp" width="240"> <img src="10_suelo_b.webp" width="240">

- **Ruta:** `/registrar/suelo`
- **Propósito:** registrar una medición de suelo.
- **CTA:** **Guardar medición**.
- **Qué hace:** captura humedad, pH, temperatura, conductividad EC, N, P y K; los campos vacíos quedan
  como "no medidos".
- **Qué debería mostrar:** tras guardar, la medición en el detalle del cuadrante y en el historial.

## 11. Producción

<img src="11_produccion.webp" width="240"> <img src="11_produccion_b.webp" width="240">

- **Ruta:** `/registrar/produccion` (desde Registrar labor → Cosecha)
- **Propósito:** registrar una cosecha trazable por sector y temporada.
- **CTA:** **Guardar cosecha**.
- **Qué hace:** captura cantidad, unidad, destino, jornada y calidad; cultivo y temporada se toman del
  sector, no se escriben.
- **Qué debería mostrar:** el cultivo y la temporada vigentes del sector. Sin cultivo vigente muestra
  "Selecciona un sector con cultivo vigente", como en la captura.

## 12. Revisión apícola

<img src="12_apicultura.webp" width="240"> <img src="12_apicultura_b.webp" width="240">

- **Ruta:** `/sectores/:id/apicultura` (desde Registrar labor → Apicultura o desde un cuadrante
  apícola)
- **Propósito:** registrar una revisión de colmenas.
- **CTA:** **Guardar revisión**; secundario **Adjuntar fotografía**.
- **Qué hace:** tipo de tarea, apicultor responsable (texto, no cuenta), cantidad de colmenas, estado
  de la reina, postura, alimentación, sanidad, plagas, alza instalada y observaciones.
- **Qué debería mostrar:** sólo para cuadrantes de categoría apícola.
  ✅ En un sector de cultivo muestra "Sector incompatible" en vez del formulario (I8).

## 13. Fotografías

<img src="13_foto.webp" width="240">

- **Ruta:** `/registrar/foto` (desde Revisión apícola)
- **Propósito:** adjuntar fotos privadas al registro.
- **CTA:** **Cámara** / **Galería**, luego **Adjuntar fotografía** (deshabilitado hasta elegir una).
- **Qué hace:** guarda la foto en el dispositivo y la sube a Storage al sincronizar.
- **Qué debería mostrar:** la vista previa de la foto elegida y el estado de respaldo.

## 14. AgroIA

<img src="14_agroia.webp" width="240">

- **Ruta:** `/agroia`
- **Propósito:** chatbot agrícola consultivo.
- **CTA:** **Enviar consulta** (deshabilitado sin texto).
- **Qué hace:** envía sólo el texto escrito; no recibe datos de la parcela ni escribe registros.
- **Qué debería mostrar:** la conversación con estado por mensaje y **Reintentar** en los fallidos.
  ✅ En modo local muestra "AgroIA no disponible en modo local" sin compositor; el historial previo
  sigue visible (I5).

## 15. Más

<img src="15_mas.webp" width="240"> <img src="15_mas_b.webp" width="240">

- **Ruta:** `/mas`
- **Propósito:** menú de organización, respaldo y configuración.
- **CTA:** Catálogo de cultivos, Historial agrícola, Recordatorios, Exportar XLSX y Configuración.

## 16. Temporadas

<img src="16_temporadas.webp" width="240">

- **Ruta:** `/mas/temporadas`
- **Propósito:** ciclos productivos de la parcela.
- **CTA:** **+ Nueva temporada**; tocar una temporada para editarla.
- **Qué debería mostrar:** temporadas con su estado (planificada, activa, cerrada) y vigencia; hoy el
  estado vacío "Sin temporadas".

## 17. Nueva temporada

<img src="17_temporada_form.webp" width="240">

- **Ruta:** `/mas/temporadas/nueva` y `/mas/temporadas/:id/editar`
- **Propósito:** crear o editar una temporada.
- **CTA:** **Guardar localmente**.
- **Qué hace:** nombre, estado, fecha de inicio y notas.

## 18. Catálogo de cultivos

<img src="18_catalogo.webp" width="240"> <img src="18_catalogo_nuevo_cultivo.webp" width="240">

- **Ruta:** `/mas/catalogo`
- **Propósito:** especies oficiales y cultivos propios, disponibles sin Internet.
- **CTA:** **+ Crear cultivo personalizado** (diálogo "Nuevo cultivo": Nombre, Notas → **Guardar**);
  buscador.
- **Qué debería mostrar:** cada cultivo con nombre común, científico y tipo.
  ✅ Las categorías se muestran como Berries, Frutal, Hortaliza, Cereal, Tubérculo o Apicultura (I4).

## 19. Recordatorios

<img src="19_recordatorios.webp" width="240">

- **Ruta:** `/mas/recordatorios` (y `/mas/recordatorios/:id`)
- **Propósito:** avisos locales de labores.
- **CTA:** **Programar recordatorio**.
- **Qué hace:** título, descripción y fecha/hora en el contexto activo; la notificación funciona sin
  conexión.
- **Qué debería mostrar:** la lista de recordatorios con su estado y menú en los programados.
  ✅ La fecha se muestra como "vie, 2 oct · 3:16" y los estados en español: Programado, Completado,
  Cancelado; en modo local, "Guardado en este dispositivo" (I3).

## 20. Sincronización (retirada)

La pantalla, sus conflictos y el banner global se retiraron: la sincronización corre sola en segundo
plano y la app no muestra estados "Sincronizado", "Local" ni "pendiente de sincronizar".

## 21. Exportar

<img src="21_exportar.webp" width="240">

- **Ruta:** `/mas/exportar`
- **Propósito:** copia legible (XLSX) de todos los datos del dispositivo.
- **CTA:** **Elegir destino y guardar**.

## 22. Configuración

<img src="22_configuracion.webp" width="240">

- **Ruta:** `/mas/configuracion`
- **Propósito:** explica el alcance (uso personal) y remite las preferencias a Perfil.
- **CTA:** ninguno; es informativa.

## 23. Perfil

<img src="23_perfil.webp" width="240"> <img src="23_perfil_b.webp" width="240"> <img src="23_perfil_c.webp" width="240">

- **Ruta:** `/mas/perfil` (se abre desde la tarjeta "Tu perfil" en Más)
- **Propósito:** identidad y preferencias del agricultor.
- **CTA:** **Editar información personal** (lápiz) y cada fila de ajustes. En modo online incluye
  **Cerrar sesión**; en modo local se oculta.
- **Qué debería mostrar:** nombre visible configurado (hoy "Nombre no configurado").

| # | Subpantalla | Ruta | Contenido / CTA | Captura |
|---|---|---|---|---|
| 24 | Información personal | retirada | El perfil sólo muestra el usuario de acceso, sin correo ni edición | — |
| 25 | Notificaciones | `/mas/perfil/notificaciones` | Interruptor de alertas meteorológicas; recordatorios se gestionan en Más | [25](25_perfil_notificaciones.webp) |
| 26 | Idioma | `/mas/perfil/idioma` | Sólo Español (Chile); informativa | [26](26_perfil_idioma.webp) |
| 27 | Seguridad | `/mas/perfil/seguridad` | Interruptor de desbloqueo biométrico; en modo local habla sólo de este dispositivo (✅ I6) | [27](27_perfil_seguridad.webp) |
| 28 | Tema | `/mas/perfil/tema` | Sólo modo claro; informativa | [28](28_perfil_tema.webp) |
| 29 | Ayuda y soporte | `/mas/perfil/ayuda` | Preguntas frecuentes; en modo local el respaldo se explica con Exportar XLSX (✅ I6) | [29](29_perfil_ayuda.webp) |
| 30 | Contacto | `/mas/perfil/contacto` | "Contacto no configurado" | [30](30_perfil_contacto.webp) |
| 31 | Privacidad | `/mas/perfil/privacidad` | En modo local: "Datos en este dispositivo", sin Supabase ni cuentas (✅ I6) | [31](31_perfil_privacidad.webp) |

<img src="24_perfil_informacion.webp" width="160"> <img src="25_perfil_notificaciones.webp" width="160"> <img src="26_perfil_idioma.webp" width="160"> <img src="27_perfil_seguridad.webp" width="160"> <img src="28_perfil_tema.webp" width="160"> <img src="29_perfil_ayuda.webp" width="160"> <img src="30_perfil_contacto.webp" width="160"> <img src="31_perfil_privacidad.webp" width="160">

## 32. Parcelas

<img src="32_parcelas.webp" width="240"> <img src="32_parcelas_menu.webp" width="240"> <img src="33_parcela_nueva.webp" width="240"> <img src="34_parcela_editar.webp" width="240">

- **Ruta:** `/inicio/parcelas`, `/inicio/parcelas/nueva`, `/inicio/parcelas/:id/editar` (desde Perfil
  → Ubicación)
- **Propósito:** administrar parcelas.
- **CTA:** **+ Nueva parcela**; tocar una parcela para editarla; menú **⋮ → Archivar**. En el
  formulario: Nombre, Localidad, **Usar como parcela activa** → **Guardar sin conexión**.
- **Qué debería mostrar:** todas las parcelas, marcando la activa.
  ✅ Mismo encabezado que el resto, con subtítulo (I7).

## Pantallas no capturadas

| Pantalla | Ruta | Motivo |
|---|---|---|
| Acceso (login) | `/acceso` | Sólo existe en modo online (`AGROCAMPO_ONLINE=true`). |

## Hallazgos

Detectados en la primera captura y resueltos; detalle en [`ISSUES.md`](./ISSUES.md).

| # | Pantalla | Hallazgo | Estado |
|---|---|---|---|
| I1 | Todas | En modo local, el banner global decía "N registros pendientes de sincronización." | ✅ Resuelto |
| I2 | Riego | Los selectores mostraban valores internos en inglés (`drip`, `unknown`). | ✅ Resuelto |
| I3 | Recordatorios, Sincronización | Fechas sin formato y estados internos (`scheduled`, `pending`). | ✅ Resuelto |
| I4 | Catálogo | Códigos de categoría del seed ("berry" junto a "frutal"). | ✅ Resuelto |
| I5 | AgroIA, Sincronización, Inicio (clima) | En modo local invitaban a usar funciones no disponibles. | ✅ Resuelto |
| I6 | Seguridad, Ayuda, Privacidad | En modo local mencionaban "Cerrar sesión", Supabase y "datos por cuenta". | ✅ Resuelto |
| I7 | Parcelas | Encabezado distinto al de `AgroPage`. | ✅ Resuelto |
| I8 | Registrar labor, Revisión apícola | Apicultura ofrecida en sectores de cultivo. | ✅ Resuelto |

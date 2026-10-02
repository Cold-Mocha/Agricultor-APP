# Issues de UI

Hallazgos del [inventario de pantallas](./README.md) y cómo se resuelven. Toda corrección usa
componentes y tokens existentes y cita [`master.md`](../../master.md). Las capturas se regeneran
después de aplicar todas las correcciones.

| Id | Pestaña | Estado |
|---|---|---|
| [I1](#i1-banner-global-en-modo-local) | Global | Pendiente |
| [I2](#i2-riego-muestra-valores-internos) | Registrar | Pendiente |
| [I3](#i3-recordatorios-y-sincronización-muestran-datos-sin-formato) | Más | Pendiente |
| [I4](#i4-catálogo-muestra-códigos-de-categoría) | Más | Pendiente |
| [I5](#i5-funciones-con-red-en-modo-local) | Inicio, AgroIA, Más | Pendiente |
| [I6](#i6-perfil-habla-de-una-cuenta-en-modo-local) | Inicio (Perfil) | Pendiente |
| [I7](#i7-encabezado-distinto-en-parcelas) | Inicio (Parcelas) | Pendiente |
| [I8](#i8-apicultura-ofrecida-en-sectores-de-cultivo) | Registrar | Pendiente |

## I1. Banner global en modo local

- **Capturas:** todas (por ejemplo [`01_inicio`](01_inicio.webp)).
- **Problema:** en modo local el banner dice "N registros pendientes de sincronización.", y esos
  registros nunca se van a sincronizar.
- **Causa:** `frontend/lib/src/app/shell/agro_global_sync_status.dart:27-53` sólo distingue entre
  con y sin conexión.
- **Solución:** si `isLocalModeProvider` es verdadero, mostrar la variante *Informativo* con el
  ícono de almacenamiento local y el texto "Modo local · tus datos se guardan en este dispositivo.",
  sin contador.
- **master.md:** Offline UX → Modo local (sin cuenta); Banners → Informativo.
- **Test:** widget test del banner con `isLocalModeProvider` en `true`.

## I2. Riego muestra valores internos

- **Capturas:** [`08_riego`](08_riego.webp), [`08_riego_b`](08_riego_b.webp).
- **Problema:** los selectores muestran `drip` y `unknown`.
- **Causa:** `irrigation_record_page.dart:89,100` usa `Text(value.name)`.
- **Solución:** formatter de presentación en `modules/irrigation/presentation/formatters/` con
  etiquetas en español:
  - `IrrigationType`: Goteo, Aspersión, Surco, Gravedad.
  - `SoilType`: Arenoso, Franco, Arcilloso, No lo sé.
- **master.md:** Screens → Riego (tipo de riego, tipo de suelo); Voz visual y verbal.
- **Test:** el formulario muestra "Goteo" y "No lo sé", y nunca los nombres del enum.

## I3. Recordatorios y Sincronización muestran datos sin formato

- **Capturas:** [`19_recordatorios`](19_recordatorios.webp), [`20_sincronizacion`](20_sincronizacion.webp).
- **Problema:** la fecha aparece como `2026-10-02 01:00:28.688936`. La lista de recordatorios muestra
  además estados internos (`scheduled`, `completed`, `pending`).
- **Causa:**
  - `reminders_page.dart:60,94` usa `toLocal().toString()`, y `:95-100` muestra `status` y
    `syncState` crudos.
  - `sync_status_page.dart:73` usa `toLocal().toString()` para el último respaldo.
- **Solución:** formatear con `MaterialLocalizations` (`formatMediumDate` + `formatTimeOfDay`), igual
  que `weather_summary_card.dart:412`. Traducir los estados:
  - Programado, Completado, Cancelado.
  - Guardado en este dispositivo, Pendiente de sincronización, Sincronizado, Requiere revisión.
- **master.md:** Screens → Recordatorios (estados); Offline UX → Mensajes canónicos.
- **Test:** la fecha se muestra formateada y los estados aparecen traducidos.

## I4. Catálogo muestra códigos de categoría

- **Capturas:** [`18_catalogo`](18_catalogo.webp).
- **Problema:** aparece "berry" junto a "frutal"; los valores son códigos del seed
  `backend/assets/data/crop_catalog_v1.json`.
- **Causa:** `crop_catalog_page.dart:90-91` interpola `crop.category`.
- **Solución:** formatter en `modules/crop_cycles/presentation/formatters/` con las etiquetas
  Berries, Tubérculo, Frutal, Hortaliza, Cereal y Apicultura. Un código desconocido se muestra tal
  cual.
- **master.md:** Screens → Catálogo y ficha de cultivo.
- **Test:** "Berries" aparece en el catálogo.

## I5. Funciones con red en modo local

- **Capturas:** [`01_inicio`](01_inicio.webp) (clima), [`14_agroia`](14_agroia.webp),
  [`20_sincronizacion`](20_sincronizacion.webp).
- **Problema:** en modo local se invita a actualizar el clima, consultar a AgroIA y "Sincronizar
  ahora", y ninguna de esas funciones existe.
- **Causa:** `weather_summary_card.dart:77-88`, `agro_ai_page.dart:43-47,80-96` y
  `sync_status_page.dart:79-83` no consultan el modo.
- **Solución:** usar `isLocalModeProvider` en cada pantalla:
  - Clima: sin botón de actualizar y con el estado "Disponible al activar el respaldo en la nube.".
    Editar la localidad sigue disponible.
  - AgroIA: estado vacío "AgroIA necesita el modo con respaldo en la nube…", sin compositor. El
    historial existente se sigue mostrando.
  - Sincronización: estado vacío con el mismo texto y sin "Sincronizar ahora".
- **master.md:** Offline UX → Modo local (sin cuenta).
- **Test:** AgroIA y Sincronización en modo local no muestran sus acciones.

## I6. Perfil habla de una cuenta en modo local

- **Capturas:** [`27_perfil_seguridad`](27_perfil_seguridad.webp),
  [`31_perfil_privacidad`](31_perfil_privacidad.webp), [`29_perfil_ayuda`](29_perfil_ayuda.webp).
- **Problema:** en modo local aparecen textos sobre una cuenta que no existe: "Cerrar sesión detiene
  la sincronización", "respaldo en Supabase", "Datos por cuenta" y "se respaldan cuando vuelve la
  conexión".
- **Causa:** `profile_settings_pages.dart:174,213-223,253-258` tiene textos fijos.
- **Solución:** variantes en modo local que hablan de "este dispositivo".
  `ProfileInformationPage` pasa a ser `ConsumerWidget` para leer el modo.
- **master.md:** Offline UX → Modo local (sin cuenta), fila Perfil.
- **Test:** la página de Privacidad en modo local no menciona Supabase ni "cuenta".

## I7. Encabezado distinto en Parcelas

- **Capturas:** [`32_parcelas`](32_parcelas.webp), [`33_parcela_nueva`](33_parcela_nueva.webp),
  [`34_parcela_editar`](34_parcela_editar.webp).
- **Problema:** el encabezado es más bajo y sin subtítulo, a diferencia del resto de las pantallas.
- **Causa:** `parcel_list_page.dart:18` y `parcel_form_page.dart:52` no pasan `subtitle` a
  `AgroPage`, que usa otra altura.
- **Solución:** agregar subtítulos:
  - Lista: "Contexto territorial de tu trabajo".
  - Formulario: "Se guarda en este dispositivo".
- **master.md:** Components → Shell de aplicación y cabecera (título + subtítulo); Screens →
  Parcelas.
- **Test:** cubierto por los tests existentes de parcelas; verificación visual en la recaptura.

## I8. Apicultura ofrecida en sectores de cultivo

- **Capturas:** [`07_registrar_tipos`](07_registrar_tipos.webp), [`12_apicultura`](12_apicultura.webp).
- **Problema:** en un cuadrante de frutillas se ofrece "Apicultura" y se abre la revisión apícola,
  que recién falla al guardar.
- **Causa:**
  - `labor_form_page.dart:102` lista todos los `LaborType`.
  - `apiary_inspection_page.dart:133` valida la categoría sólo en `_save`.
- **Solución:**
  - Filtrar los tipos según `BoundAgriculturalContext.category`, de acuerdo con
    `DomainCompatibilityPolicy`: sector de cultivo sin Apicultura, sector apícola sólo Apicultura.
  - La revisión apícola muestra el estado "sector incompatible" (`AgroEmptyState`) antes del
    formulario cuando el sector no es apícola.
- **master.md:** Screens → Revisión apícola (estado "sector incompatible").
- **Test:** con un sector de cultivo, el selector no ofrece Apicultura; la revisión apícola en un
  sector de cultivo muestra el estado incompatible.

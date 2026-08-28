# Contract: AgroCampo XLSX Export v1

**Source of truth**: One consistent Drift snapshot at export start.

**Availability**: Fully offline.

**Format**: Valid `.xlsx`, one header row per sheet, UTF-8-compatible visible text.

## 1. Workbook rules

- Fixed sheet order: Parcelas, Sectores, Cultivos, Labores, Suelo, Riegos, Producción.
- Headers are Spanish and versioned by this contract.
- IDs are exported as text so spreadsheet software does not alter them.
- Dates use ISO `YYYY-MM-DD`; timestamps use ISO 8601 UTC plus a separate visible local value when
  needed.
- Measurements are converted from scaled storage to declared metric units.
- `Estado sincronización` is one of Pendiente, Enviando, Sincronizado, Conflicto or Error.
- Tombstoned rows are excluded; archived parcels remain included with `Archivada = Sí` because they
  preserve agricultural history.
- Values beginning with `=`, `+`, `-` or `@` from user-entered text are forced to text to prevent
  formula injection.
- No formulas, macros, external links, credentials, FCM tokens, local file paths or provider keys.

## 2. Sheets and columns

### Parcelas

`ID`, `Nombre`, `Descripción`, `Latitud centro`, `Longitud centro`, `Superficie m²`,
`Superficie ha`, `Archivada`, `Creada UTC`, `Actualizada UTC`, `Estado sincronización`.

### Sectores

`ID`, `Parcela ID`, `Número`, `Nombre`, `Tipo`, `Superficie m²`, `Superficie ha`,
`Cultivo vigente ID`, `Creado UTC`, `Actualizado UTC`, `Estado sincronización`.

### Cultivos

`ID`, `Slug`, `Nombre`, `Época de siembra`, `Requerimientos de suelo`, `Necesidades hídricas`,
`Enfermedades comunes`, `Versión catálogo`.

### Labores

`ID`, `Parcela ID`, `Sector ID`, `Cultivo ID`, `Temporada ID`, `Tipo`, `Fecha local`,
`Fecha UTC`, `Observaciones`, `Estado sincronización`.

### Suelo

`Labor ID`, `Humedad %`, `pH`, `Temperatura °C`, `EC mS/cm`, `N mg/kg`, `P mg/kg`,
`K mg/kg`, `Estado sincronización`.

### Riegos

`Labor ID`, `Tipo riego`, `Caudal L/min`, `Duración min`, `Litros estimados`,
`Recomendación ID`, `Estado sincronización`.

### Producción

`Labor ID`, `Parcela ID`, `Sector ID`, `Cultivo ID`, `Temporada ID`, `Fecha`,
`Cantidad kg`, `Calidad`, `Observaciones`, `Estado sincronización`.

## 3. Validation contract

- The workbook opens without repair warnings in current Microsoft Excel and LibreOffice.
- Sheet names and columns exactly match this version.
- Row counts match the source snapshot for every included entity.
- Every foreign ID resolves to an exported parent where that parent is within contract scope.
- Accents and ñ round-trip correctly.
- Pending/conflict rows are included and accurately labeled.
- A fixture with 20 parcels, 200 sectors and 10,000 textual records completes within the accepted
  device resource budget and does not block the UI isolate.
- Write/cancel/storage errors do not leave a partial file presented as a successful export.

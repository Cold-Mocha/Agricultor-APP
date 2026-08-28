# Contract: Deterministic Irrigation Calculation v1

**Status**: Estructura contractual completa; parámetros agronómicos y vectores pendientes de
aprobación en la tarea bloqueante T001.  
**Authority**: FR-038, FR-039, FR-040, FR-041, FR-042 y FR-090 de [spec.md](../spec.md).  
**Boundary**: cálculo local y explicable; no evapotranspiración avanzada, AgroIA ni control físico.

## 1. Release gate

No puede implementarse ni activarse el motor v1 hasta que el propietario del producto y la persona
revisora agronómica aprueben en este contrato:

- clasificación y códigos de tipo de suelo;
- volumen base por planta para cada cultivo con recomendación disponible;
- umbrales/ajustes de humedad y temperatura;
- límite y condiciones del ajuste climático opcional;
- límites globales, reglas de redondeo y advertencias;
- fuente, persona revisora, fecha y versión;
- al menos veinte vectores con resultado esperado.

La consolidación documental no inventa esos valores. Un cultivo sin regla aprobada puede usarse en
sectores y registros, pero la calculadora comunica “sin regla aprobada” y no entrega recomendación.

## 2. Canonical inputs and units

| Input | Canonical unit | Validation |
|---|---|---|
| `plant_count` | integer plants | Greater than zero. |
| `flow_ml_min` | millilitres/minute total | Greater than zero; total effective flow for the sector. |
| `input_duration_seconds` | seconds | Greater than zero when calculating applied volume. |
| `crop_id` | UUID | Active crop/rule owned or visible to the farmer. |
| `soil_type_code` | approved versioned code | Required for recommendation; must exist in the rule set. |
| `soil_humidity_bp` | basis points, 0–10,000 | Required by v1 recommendation. |
| `soil_temperature_milli_c` | 0.001 °C | Required and inside approved gate limits. |
| `weather_adjustment_bp` | basis points | Optional, fresh, normalized and capped; zero when unavailable. |
| `weather_reference_at` | timestamp | Present only when a fresh weather adjustment is used. |

User-facing values are metric conversions of these canonical values. Null means not supplied; it is
never converted silently to zero.

## 3. Approved rule-set shape

Each immutable `crop_irrigation_rule` version contains:

| Parameter | Contract rule |
|---|---|
| `base_ml_per_plant` | Positive and supported by an approved source/reviewer. |
| `soil_adjustment_bp[soil_type_code]` | Bounded adjustment for every approved soil code. |
| `humidity_bands` | Non-overlapping ranges covering 0–10,000 bp exactly once. |
| `temperature_bands` | Ordered, non-overlapping ranges inside approved input limits. |
| `max_weather_adjustment_bp` | Absolute cap; weather cannot dominate local inputs. |
| `min_total_adjustment_bp` / `max_total_adjustment_bp` | Clamp for combined simple adjustments. |
| `source_reference`, `reviewed_by`, `approved_at` | Non-empty approval evidence. |
| `rule_version`, `valid_from`, `retired_at` | Historical reproducibility. |

## 4. Deterministic operations

All operations use integers or exact rational intermediate values; no device locale participates.

1. Applied volume from the farmer's time:
   `applied_volume_ml = round_half_up(flow_ml_min × input_duration_seconds / 60)`.
2. Base recommendation:
   `base_volume_ml = plant_count × base_ml_per_plant`.
3. Raw simple adjustment:
   `raw_adjustment_bp = 10000 + soil_adjustment_bp + humidity_adjustment_bp + temperature_adjustment_bp + weather_adjustment_bp`.
4. Bounded adjustment:
   `bounded_adjustment_bp = clamp(raw_adjustment_bp, min_total_adjustment_bp, max_total_adjustment_bp)`.
5. Recommended volume:
   `recommended_volume_ml = round_half_up(base_volume_ml × bounded_adjustment_bp / 10000)`.
6. Recommended time:
   `recommended_duration_seconds = ceil(recommended_volume_ml × 60 / flow_ml_min)`.

`round_half_up` rounds an exact half away from zero. The duration uses ceiling so the displayed
recommendation does not under-deliver solely because of integer conversion. Every stored result
includes formula version, rule ID/version, inputs and adjustments.

## 5. Weather boundary

- Freshness and provider use follow [external-services.md](./external-services.md).
- Missing, stale, rate-limited or unavailable weather produces adjustment zero plus a stable warning.
- A weather response is never required for local calculation when all mandatory local inputs exist.
- Only normalized variables actually used and their provenance are retained; no raw provider payload.

## 6. Validation and warnings

The calculator returns no usable recommendation when plants/flow are non-positive, a mandatory
local input is absent, the crop has no approved rule, the soil code is unknown or an input exceeds
approved limits. It preserves entered values for correction.

Stable warnings include at least:

- `weather_unavailable` / `weather_stale_not_used`;
- `crop_rule_unavailable`;
- `soil_type_unrecognized`;
- `input_outside_approved_range`;
- `applied_volume_differs_from_recommendation`.

Warnings explain limitations; they never transform an invalid result into a valid one.

## 7. Persistence and replay

An accepted estimate stores rule/algorithm versions, canonical inputs, each selected adjustment,
bounded adjustment, warnings, calculated time, recommended volume, applied-volume comparison and
calculation timestamp. Retiring or replacing a rule never recalculates history.

Saving a performed irrigation requires explicit farmer confirmation. The estimate does not activate
equipment or claim professional certainty.

## 8. Approval record and test vectors

T001 completes this section with:

| Evidence | Required completion |
|---|---|
| Agronomic source/reviewer | Name/reference and review date. |
| Soil classification | Versioned code list and definitions. |
| Crop rule table | Approved parameters for every supported recommendation. |
| Global bounds | Input, adjustment and output limits. |
| Test vectors | At least 20 cases covering boundaries, every soil code, missing weather and rounding. |
| Approval | Product owner and reviewer acceptance with date/version. |

Every vector records inputs, rule version, intermediate adjustments, expected millilitres, expected
seconds and warning codes. Running the same vector twice must produce byte-equivalent numeric output.

## 9. Acceptance

This contract is accepted when T001 has completed the approval record, all vectors reproduce
exactly, FR-038/039/040/041/042/090 and SC-007 pass, and tests prove no dependency on network,
Weather availability or AgroIA.

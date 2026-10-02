# Feature Specification: AgroCampo Sensory Feedback - Módulo 004

**Created**: 2026-10-02

**Status**: Approved for implementation

**Input**: Solicitud del propietario del producto: cargas sin spinners fugaces, transiciones y
microinteracciones, confirmación visual al completar registros clave, efectos de sonido sutiles y un
control para activar o desactivar sonidos y animaciones.

## Purpose and Authority

004 añade feedback sensorial (movimiento y sonido) sobre los flujos vigentes de 001–003. No crea
flujos agrícolas, no cambia contratos de dominio y no modifica datos sincronizados. Amplía
expresamente la fila de `specs/003-agrocampo-functional-refinement/spec.md` que dejaba
"animaciones … sin requisito vigente" fuera de alcance (PF-27): desde 004 las animaciones definidas
aquí y su preferencia tienen requisito. Tema, idioma, ayuda, contacto, privacidad y animaciones
estacionales siguen fuera de alcance.

`master.md` sigue siendo la autoridad visual; 004 se acompaña de su enmienda en "Movimiento y
feedback", "Sonido" y "Perfil".

## Decisions confirmed by the product owner (2026-10-02)

| Tema | Decisión |
|---|---|
| Alcance | Enmendar spec y `master.md` antes de implementar |
| "Registro completado" | Guardar un registro agrícola (labor, riego, suelo, producción, revisión apícola, fotografía, geometría). La app no tiene alta de cuentas y 004 no la crea |
| Carga | Skeleton reservado, nunca spinner centrado para lecturas locales |
| Éxito y dependencias | Checkmark animado dibujado en código (sin Lottie ni confeti); audio con `audioplayers` |

## User Scenarios & Testing

### US1 — Carga estable (P1)

Al abrir Inicio, Sectores, Detalle de cuadrante, Rotación, Historial o Resolver conflicto, la
pantalla reserva el espacio del contenido con un skeleton en vez de un spinner centrado.

1. **Given** datos locales que tardan en leerse, **When** abre la pantalla, **Then** ve bloques
   reservados con la forma aproximada del contenido y TalkBack anuncia "Cargando".
2. **Given** movimiento reducido, **When** se muestra el skeleton, **Then** no pulsa.

### US2 — Movimiento con causa y efecto (P1)

1. **Given** navegación a una pantalla apilada, **When** se abre, **Then** entra con fundido y
   desplazamiento corto (200 ms) y sale más rápido (150 ms).
2. **Given** tarjetas de acción y navegación, **When** las presiona, **Then** se reducen levemente
   (escala 0,97) además del ripple Material.
3. **Given** listas principales (Inicio, Sectores, Historial, Recordatorios), **When** aparecen,
   **Then** entran escalonadas con un retardo acumulado máximo de 160 ms.
4. **Given** un registro agrícola guardado, **When** se confirma, **Then** aparece sobre la pantalla
   un check animado (≤ 300 ms de entrada, ≤ 150 ms de salida) que no bloquea la interacción, junto al
   snackbar textual vigente.

### US3 — Sonido sutil (P2)

1. **Given** sonido activo, **When** guarda un registro agrícola, **Then** suena el efecto
   distintivo "registro guardado".
2. **When** guarda perfil, configuración o exportación, **Then** suena la confirmación suave.
3. **When** un guardado falla o hay campos inválidos, **Then** suena el efecto de error.
4. **When** toca un botón principal (FilledButton), **Then** suena un clic breve. Excepción: los
   botones cuyo resultado ya tiene sonido (registro guardado, guardado o error) no hacen clic, para
   no superponer dos efectos.
5. **Given** música o navegación de otra app, **When** suena un efecto, **Then** no se pausa el
   audio ajeno (sin foco de audio) y se respeta el modo silencio del sistema.
6. **Given** un formulario con validación en línea (Acceso, Temporada), **When** hay campos
   inválidos, **Then** suena el efecto de error junto al mensaje del campo.

### US4 — Control del usuario (P1)

1. **Given** Perfil > Preferencias > Sonidos y animaciones, **When** desactiva sonidos, **Then**
   ningún efecto suena.
2. **When** desactiva animaciones, **Then** la app se comporta como con "reducir movimiento" del
   sistema: sin transiciones no esenciales, stagger, pulsos ni check animado.
3. **Given** reinicio de la app, **Then** ambas preferencias se conservan por cuenta en el dispositivo.

## Requirements

- **FR-004-001**: Las lecturas locales MUST mostrar skeleton reservado; los spinners centrados de
  pantalla quedan prohibidos (`master.md` Movimiento y feedback).
- **FR-004-002**: Toda duración MUST provenir de `AgroMotion`.
- **FR-004-003**: El movimiento MUST anularse con "reducir movimiento" del sistema o con la
  preferencia de la app; la información nunca depende sólo del movimiento.
- **FR-004-004**: El sonido MUST ser complementario: todo evento sonoro tiene equivalente textual
  (snackbar o banner) y nada se comunica sólo por audio.
- **FR-004-005**: Los efectos MUST usar uso Android `assistanceSonification`, sin solicitar foco de
  audio, y fallar en silencio sin afectar el flujo.
- **FR-004-006**: Las preferencias `sound_effects_enabled` y `animations_enabled` MUST guardarse
  localmente por propietario en `app_preferences`, sin sincronizarse. Valor por defecto: activas.
  Sin sesión se usan los valores por defecto.
- **FR-004-007**: Los activos de audio MUST ser OGG Vorbis mono, ≤ 20 KB cada uno, sintetizados por
  el proyecto (`tool/generate_sounds.sh`) para evitar licencias de terceros.
- **FR-004-008**: La lógica reutilizable MUST vivir en `frontend/lib/src/shared/design_system/`
  (`motion/`, `feedback/`, `components/`) sin depender de módulos; la preferencia vive en
  `modules/profile` y la conexión en `app/`.

## Compliance notes (Chile)

- **Ley 21.719 / 19.628**: las preferencias son ajustes técnicos del dispositivo; no se crea
  tratamiento nuevo de datos personales ni se sincronizan.
- **Ley 20.422**: se respeta movimiento reducido y el audio nunca es canal único de información.
- **Ley 17.336**: los sonidos son de autoría propia generados por script; no se incorporan obras de
  terceros.

## Out of Scope

Alta o registro de cuentas, confeti, Lottie, vibración nueva, sonidos por cada tap no principal,
hover (aplicación táctil Android), temas, idiomas y animaciones estacionales.

## Success Criteria

- **SC-004-001**: Ninguna pantalla listada en US1 contiene `CircularProgressIndicator` centrado.
- **SC-004-002**: Pruebas de widget cubren skeleton, preferencia de animaciones (MediaQuery),
  sonido silenciado y disparo de efectos por tipo.
- **SC-004-003**: Format, analyze, tests de frontend/backend y `tool/check_architecture.dart` pasan.

# Tasks: AgroCampo Sensory Feedback - Módulo 004

**Input**: `spec.md`, `plan.md`, `master.md` (Movimiento y feedback, Sonido, Perfil).

## Phase 1 — Base: carga estable y tope de stagger

- [X] T001 Frontend: Añadir tokens `exit`, `staggerStep`, `skeletonPulse`, `successHold` a `AgroMotion` en `frontend/lib/src/app/theme/agro_tokens.dart`
- [X] T002 Frontend: Crear `AgroSkeleton`/`AgroSkeletonList` con pulso desactivable en `frontend/lib/src/shared/design_system/components/agro_skeleton.dart`
- [X] T003 Frontend: Sustituir spinners de Inicio, Sectores, Detalle, Rotación, Historial y Resolver conflicto por skeleton
- [X] T004 Frontend: Limitar el retardo acumulado del stagger a 4 pasos en `agro_motion_effects.dart`

## Phase 2 — Movimiento y microinteracciones

- [X] T005 Frontend: `AgroPageTransitionsBuilder` (200 ms entrada / 150 ms salida) registrado en `AgroTheme`
- [X] T006 Frontend: `AgroPressScale` en `AgroActionTile` y `AgroNavigationCard`
- [X] T007 Frontend: Entrada escalonada en Sectores, Historial y Recordatorios
- [X] T008 Frontend: `AgroSuccessCheck` animado en Overlay, sin bloquear interacción

## Phase 3 — Sonido y control del usuario

- [X] T009 Integración: `tool/generate_sounds.sh` y activos OGG en `frontend/assets/sounds/`
- [X] T010 Frontend: `AgroSoundEffects` (audioplayers, sin foco de audio) y `SilentAgroSoundEffects`
- [X] T011 Backend: `FeedbackPreferences` y `watchFeedbackPreferences`/`setSoundEffectsEnabled`/`setAnimationsEnabled` en `ProfileFacade` con pruebas
- [X] T012 Frontend: `AgroFeedbackScope`, `AgroFeedback` y host en `app/` que aplica `disableAnimations`
- [X] T013 Frontend: Perfil > Sonidos y animaciones con dos interruptores
- [X] T014 Frontend: Usar `AgroFeedback` en guardados agrícolas, de configuración, errores y botones principales

## Phase 4 — Cierre

- [X] T015 Integración: Pruebas de widget de skeleton, preferencias, sonido y transiciones
- [X] T016 Integración: Format, analyze, tests frontend/backend, arquitectura y prototipo; actualizar `docs/status.md`
- [ ] T017 Integración: Verificación manual en Android API 24+ (audio, silencio, foco de audio, reducir movimiento)

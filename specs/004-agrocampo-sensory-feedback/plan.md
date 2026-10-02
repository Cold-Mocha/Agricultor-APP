# Implementation Plan: AgroCampo Sensory Feedback - Módulo 004

**Spec**: [`spec.md`](./spec.md)

## Technical Context

| Ítem | Valor |
|---|---|
| Cliente | Flutter 3.47.0 / Dart 3.13.0, `frontend/` |
| Dependencias nuevas | `audioplayers 6.8.1` (única; aprobada por el propietario el 2026-10-02) |
| Dependencias reutilizadas | `flutter_animate 4.5.2`, `flutter_riverpod`, Drift vía `agrocampo_backend` |
| Persistencia | Tabla existente `app_preferences` (sin migración, sin sincronización) |
| Activos | `frontend/assets/sounds/*.ogg`, generados por `tool/generate_sounds.sh` (ffmpeg + libvorbis) |

## Architecture

```text
frontend/lib/src/
├── shared/design_system/
│   ├── motion/agro_motion_effects.dart        # entrada/stagger con tope, reduced motion
│   ├── motion/agro_page_transitions.dart      # PageTransitionsBuilder con tokens
│   ├── motion/agro_press_scale.dart           # escala al presionar
│   ├── components/agro_skeleton.dart          # skeleton reservado y pulso
│   └── feedback/
│       ├── agro_sound_effects.dart            # AgroSound, AgroSoundEffects, implementación audioplayers y silenciosa
│       ├── agro_feedback_scope.dart           # InheritedWidget: sonido + preferencia
│       ├── agro_feedback.dart                 # API: recordSaved/saved/error/info/tap
│       └── agro_success_check.dart            # check animado en Overlay
├── modules/profile/presentation/
│   ├── controllers/feedback_preferences_controller.dart
│   └── pages/profile_feedback_page.dart       # Perfil > Sonidos y animaciones
└── app/
    ├── agro_campo_app.dart                    # MaterialApp.builder -> AgroFeedbackHost
    └── shell/agro_feedback_host.dart          # lee preferencias, ajusta MediaQuery.disableAnimations

backend/lib/src/modules/profile/
├── contracts/dto/profile_contracts.dart       # FeedbackPreferences
└── application/facades/profile_facade.dart    # watch/set de preferencias
```

- `shared/` no importa módulos (regla de `tool/check_architecture.dart`); recibe preferencias por
  `AgroFeedbackScope`.
- La preferencia de animaciones se aplica una sola vez forzando `MediaQuery.disableAnimations`, de
  modo que todo componente que ya respeta "reducir movimiento" la hereda.
- La implementación de audio se inyecta en `bootstrapAgroCampo()`; `AgroCampoApp` usa
  `SilentAgroSoundEffects` por defecto para que pruebas y entornos sin plugin no reproduzcan audio.

## Motion tokens (`AgroMotion`)

| Token | Valor | Uso |
|---|---|---|
| `quick` | 100 ms | feedback de presión, cambios de icono |
| `exit` | 150 ms | salidas (página, check) |
| `standard` | 200 ms | entrada de página y contenido |
| `emphasized` | 300 ms | dibujo del check |
| `staggerStep` | 40 ms | paso de stagger, máximo 4 pasos |
| `skeletonPulse` | 900 ms | medio ciclo del pulso de skeleton |
| `successHold` | 600 ms | permanencia del check antes de salir |

## Risks

| Riesgo | Mitigación |
|---|---|
| Audio pausa música del usuario | `AndroidAudioFocus.none`, uso `assistanceSonification` |
| Plugin ausente en pruebas | Implementación silenciosa por defecto; errores de audio se capturan |
| Goldens alterados | Skeleton y animaciones terminan en el estado final; goldens se regeneran sólo si cambia el estado final |

import 'package:agrocampo/src/app/layout/agro_page.dart';
import 'package:agrocampo/src/modules/profile/presentation/controllers/feedback_preferences_controller.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Perfil > Sonidos y animaciones (specs/004 US4, master.md "Sonido").
final class ProfileFeedbackPage extends ConsumerWidget {
  const ProfileFeedbackPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences =
        ref.watch(feedbackPreferencesProvider).value ??
        const FeedbackPreferences();
    final controller = ref.watch(feedbackPreferencesControllerProvider);
    // The platform signal, not MediaQuery: the feedback host folds the app
    // preference into MediaQuery.disableAnimations.
    final systemReducesMotion = View.of(context)
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations;
    return AgroPage(
      title: 'Sonidos y animaciones',
      subtitle: 'Respuesta al tocar, guardar o corregir',
      child: ListView(
        children: [
          SwitchListTile(
            key: const ValueKey('feedback-sound-switch'),
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(LucideIcons.volume2),
            title: const Text('Efectos de sonido'),
            subtitle: const Text(
              'Sonidos breves al tocar botones principales, guardar registros y cuando algo no se pudo guardar. Respetan el modo silencio del teléfono.',
            ),
            value: preferences.soundEffectsEnabled,
            onChanged: controller.setSoundEffectsEnabled,
          ),
          SwitchListTile(
            key: const ValueKey('feedback-animations-switch'),
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(LucideIcons.sparkles),
            title: const Text('Animaciones'),
            subtitle: Text(
              systemReducesMotion
                  ? 'El teléfono tiene activado reducir movimiento; las animaciones se mantienen desactivadas.'
                  : 'Transiciones entre pantallas, carga y confirmación animada al guardar.',
            ),
            value: preferences.animationsEnabled && !systemReducesMotion,
            onChanged: systemReducesMotion
                ? null
                : controller.setAnimationsEnabled,
          ),
        ],
      ),
    );
  }
}

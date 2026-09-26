import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/shared/design_system/motion/agro_motion_effects.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum AgroStatus { success, warning, info, error }

final class AgroStatusBanner extends StatelessWidget {
  const AgroStatusBanner({
    required this.message,
    required this.status,
    super.key,
  });

  final String message;
  final AgroStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AgroSemanticColors>()!;
    final (background, foreground, icon) = switch (status) {
      AgroStatus.success => (
        colors.success,
        colors.onSuccess,
        LucideIcons.circleCheck,
      ),
      AgroStatus.warning => (
        colors.warning,
        colors.onWarning,
        LucideIcons.triangleAlert,
      ),
      AgroStatus.info => (colors.info, colors.onInfo, LucideIcons.info),
      AgroStatus.error => (
        colors.error,
        colors.onError,
        LucideIcons.circleAlert,
      ),
    };
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AgroSpacing.md),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AgroRadii.medium),
        ),
        child: Row(
          children: [
            Icon(icon, color: foreground),
            const SizedBox(width: AgroSpacing.sm),
            Expanded(
              child: Text(message, style: TextStyle(color: foreground)),
            ),
          ],
        ),
      ).agroEntrance(context, duration: AgroMotion.quick),
    );
  }
}

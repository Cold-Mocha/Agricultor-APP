import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:flutter/material.dart';

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
        Icons.check_circle_outline,
      ),
      AgroStatus.warning => (
        colors.warning,
        colors.onWarning,
        Icons.warning_amber_rounded,
      ),
      AgroStatus.info => (colors.info, colors.onInfo, Icons.info_outline),
      AgroStatus.error => (colors.error, colors.onError, Icons.error_outline),
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
      ),
    );
  }
}

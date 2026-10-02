import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/shared/design_system/motion/agro_motion_effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Reserved loading placeholder (master.md: "Carga prolongada usa progreso
/// estable o skeleton reservado; no muestra spinners fugaces"). It occupies
/// the approximate shape of the content so nothing jumps when data lands,
/// announces "Cargando" once, and pulses gently unless motion is reduced.
final class AgroSkeletonList extends StatelessWidget {
  const AgroSkeletonList({
    this.itemCount = 3,
    this.itemHeight = AgroSizes.skeletonCard,
    this.showHeader = true,
    super.key,
  });

  final int itemCount;
  final double itemHeight;
  final bool showHeader;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Cargando',
    liveRegion: true,
    child: ExcludeSemantics(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          if (showHeader) ...[
            const FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: 0.5,
              child: AgroSkeletonBlock(height: AgroSizes.skeletonLine),
            ),
            const SizedBox(height: AgroSpacing.md),
          ],
          for (var index = 0; index < itemCount; index++) ...[
            AgroSkeletonBlock(height: itemHeight),
            const SizedBox(height: AgroSpacing.sm),
          ],
        ],
      ),
    ),
  );
}

/// A single reserved block of the skeleton.
final class AgroSkeletonBlock extends StatelessWidget {
  const AgroSkeletonBlock({required this.height, super.key});

  final double height;

  @override
  Widget build(BuildContext context) {
    final block = Container(
      key: const ValueKey('agro-skeleton-block'),
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(AgroRadii.medium),
      ),
    );
    if (agroPrefersReducedMotion(context)) return block;
    return block
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .fade(
          begin: 1,
          end: 0.55,
          duration: AgroMotion.skeletonPulse,
          curve: Curves.easeInOut,
        );
  }
}

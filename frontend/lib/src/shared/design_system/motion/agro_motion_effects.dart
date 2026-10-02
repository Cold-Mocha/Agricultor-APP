import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// master.md "Movimiento y feedback": transitions stay short (150-200 ms for
/// simple changes per [AgroMotion]), never animate dimensions into a jump,
/// and reduced motion drops stagger and every non-essential transition. This
/// checks the platform's reduce-motion signal so every call site gets that
/// behavior for free instead of re-implementing the guard per widget.
bool agroPrefersReducedMotion(BuildContext context) =>
    MediaQuery.maybeOf(context)?.disableAnimations ?? false;

extension AgroMotionEntrance on Widget {
  /// A short fade + settle used for content appearing on screen (banners,
  /// cards, list rows). No-ops under reduced motion, landing the widget
  /// directly in its end state as master.md requires.
  Widget agroEntrance(
    BuildContext context, {
    Duration? duration,
    Duration delay = Duration.zero,
  }) {
    if (agroPrefersReducedMotion(context)) return this;
    final effectDuration = duration ?? AgroMotion.standard;
    return animate(delay: delay)
        .fadeIn(duration: effectDuration, curve: Curves.easeOut)
        .slideY(
          begin: 0.04,
          end: 0,
          duration: effectDuration,
          curve: Curves.easeOut,
        );
  }
}

extension AgroMotionStagger on List<Widget> {
  /// Applies [AgroMotionEntrance.agroEntrance] to each item with a small
  /// incremental delay so a grid/list settles in as one readable motion
  /// instead of popping in at once. The delay stops growing after
  /// [AgroMotion.staggerMaxSteps] so long lists still settle within the
  /// short window master.md allows. Stagger is itself dropped under reduced
  /// motion (master.md: "elimina ... stagger"), so every item just appears.
  List<Widget> agroStaggeredEntrance(BuildContext context) {
    if (agroPrefersReducedMotion(context)) return this;
    return [
      for (final (index, child) in indexed)
        child.agroEntrance(context, delay: agroStaggerDelay(index)),
    ];
  }
}

/// Delay for the [index]-th item of a staggered entrance, capped so the
/// whole group settles within [AgroMotion.staggerMaxSteps] steps.
Duration agroStaggerDelay(int index) =>
    AgroMotion.staggerStep *
    (index < AgroMotion.staggerMaxSteps ? index : AgroMotion.staggerMaxSteps);

extension AgroMotionListItem on Widget {
  /// Entrance for an item built lazily by a list builder. Only the first
  /// screenful is staggered; later rows (built while scrolling) appear
  /// directly so scrolling never waits on motion.
  Widget agroListItemEntrance(BuildContext context, int index) {
    if (index > AgroMotion.staggerMaxSteps) return this;
    return agroEntrance(context, delay: agroStaggerDelay(index));
  }
}

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
  /// instead of popping in at once. Stagger is itself dropped under reduced
  /// motion (master.md: "elimina ... stagger"), so every item just appears.
  List<Widget> agroStaggeredEntrance(
    BuildContext context, {
    Duration step = const Duration(milliseconds: 40),
  }) {
    if (agroPrefersReducedMotion(context)) return this;
    return [
      for (final (index, child) in indexed)
        child.agroEntrance(context, delay: step * index),
    ];
  }
}

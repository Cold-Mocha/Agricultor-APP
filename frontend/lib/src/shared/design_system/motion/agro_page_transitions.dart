import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/shared/design_system/motion/agro_motion_effects.dart';
import 'package:flutter/material.dart';

/// Stacked-page transition from master.md "Movimiento y feedback": the new
/// page fades in while sliding a short distance from the trailing edge
/// ([AgroMotion.standard]) and leaves faster ([AgroMotion.exit]). The page
/// underneath stays still, so nothing changes size or jumps. Under reduced
/// motion (system or the app preference) the page simply appears.
final class AgroPageTransitionsBuilder extends PageTransitionsBuilder {
  const AgroPageTransitionsBuilder();

  static final _offset = Tween<Offset>(
    begin: const Offset(0.06, 0),
    end: Offset.zero,
  );

  @override
  Duration get transitionDuration => AgroMotion.standard;

  @override
  Duration get reverseTransitionDuration => AgroMotion.exit;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (agroPrefersReducedMotion(context)) return child;
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(position: _offset.animate(curved), child: child),
    );
  }
}

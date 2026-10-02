import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/shared/design_system/motion/agro_motion_effects.dart';
import 'package:flutter/material.dart';

/// Press feedback for tappable cards (master.md "Feedback de presión dentro
/// de 100 ms"): the child shrinks to [AgroMotion.pressedScale] while a
/// pointer is down and settles back on release or cancel. It only observes
/// pointers, so the child's own gestures, ripple and semantics stay intact.
/// Disabled children ([enabled] false) and reduced motion get no scale.
final class AgroPressScale extends StatefulWidget {
  const AgroPressScale({required this.child, this.enabled = true, super.key});

  final Widget child;
  final bool enabled;

  @override
  State<AgroPressScale> createState() => _AgroPressScaleState();
}

final class _AgroPressScaleState extends State<AgroPressScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || agroPrefersReducedMotion(context)) {
      return widget.child;
    }
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? AgroMotion.pressedScale : 1,
        duration: AgroMotion.quick,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

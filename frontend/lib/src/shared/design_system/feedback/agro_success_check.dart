import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/shared/design_system/motion/agro_motion_effects.dart';
import 'package:flutter/material.dart';

/// Animated confirmation for a saved agricultural record (master.md
/// "Movimiento y feedback"): a brand circle grows in while the check is
/// drawn ([AgroMotion.emphasized]), holds ([AgroMotion.successHold]) and
/// fades out faster ([AgroMotion.exit]). It floats in the root overlay,
/// ignores pointers and is excluded from semantics because the snackbar
/// that always accompanies it carries the accessible message.
abstract final class AgroSuccessCheck {
  static OverlayEntry? _current;

  /// Shows the check unless motion is reduced (system or app preference),
  /// replacing any check still on screen.
  static void show(BuildContext context) {
    if (agroPrefersReducedMotion(context)) return;
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    _current?.remove();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => AgroSuccessCheckMark(
        onCompleted: () {
          if (identical(_current, entry)) _current = null;
          if (entry.mounted) entry.remove();
        },
      ),
    );
    _current = entry;
    overlay.insert(entry);
  }
}

/// The animated mark itself; exposed for widget tests.
final class AgroSuccessCheckMark extends StatefulWidget {
  const AgroSuccessCheckMark({required this.onCompleted, super.key});

  final VoidCallback onCompleted;

  @override
  State<AgroSuccessCheckMark> createState() => _AgroSuccessCheckMarkState();
}

final class _AgroSuccessCheckMarkState extends State<AgroSuccessCheckMark>
    with SingleTickerProviderStateMixin {
  static final _total =
      AgroMotion.emphasized + AgroMotion.successHold + AgroMotion.exit;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _total,
  );
  late final Animation<double> _enter = CurvedAnimation(
    parent: _controller,
    curve: Interval(0, _fraction(AgroMotion.emphasized), curve: Curves.easeOut),
  );
  late final Animation<double> _exit = CurvedAnimation(
    parent: _controller,
    curve: Interval(
      _fraction(AgroMotion.emphasized + AgroMotion.successHold),
      1,
      curve: Curves.easeIn,
    ),
  );

  static double _fraction(Duration value) =>
      value.inMicroseconds / _total.inMicroseconds;

  @override
  void initState() {
    super.initState();
    _controller.forward().whenComplete(() {
      if (mounted) widget.onCompleted();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return IgnorePointer(
      child: ExcludeSemantics(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Opacity(
              opacity: (_enter.value * (1 - _exit.value)).clamp(0, 1),
              child: Transform.scale(
                scale: 0.6 + 0.4 * _enter.value,
                child: Container(
                  key: const ValueKey('agro-success-check'),
                  width: AgroSizes.successBadge,
                  height: AgroSizes.successBadge,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: CustomPaint(
                    painter: _CheckPainter(
                      progress: _enter.value,
                      color: colors.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _CheckPainter extends CustomPainter {
  const _CheckPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final path = Path()
      ..moveTo(size.width * 0.28, size.height * 0.52)
      ..lineTo(size.width * 0.44, size.height * 0.68)
      ..lineTo(size.width * 0.72, size.height * 0.36);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final metric in path.computeMetrics()) {
      canvas.drawPath(metric.extractPath(0, metric.length * progress), paint);
    }
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

import 'dart:convert';
import 'dart:math' as math;

import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/core/geometry/geo_point.dart';
import 'package:agrocampo/features/sectors/data/sector_summary_repository.dart';
import 'package:flutter/material.dart';

final class QuadrantMapPreview extends StatelessWidget {
  const QuadrantMapPreview({
    required this.sectors,
    required this.onTap,
    super.key,
  });

  final List<SectorSummary> sectors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label:
        'Mapa de cuadrantes. ${sectors.length} ${sectors.length == 1 ? 'cuadrante' : 'cuadrantes'} guardados. Abrir mapa.',
    excludeSemantics: true,
    child: Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: AgroSizes.mapPreview,
              child: CustomPaint(
                painter: _QuadrantPainter(
                  sectors: sectors,
                  background: AgroColors.mapCanvas,
                  fill: AgroColors.mapPolygonSaved,
                  stroke: Theme.of(context).colorScheme.primary,
                  labelColor: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AgroSpacing.md),
              child: Row(
                children: [
                  const Icon(Icons.map_outlined),
                  const SizedBox(width: AgroSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mapa de cuadrantes',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Consulta límites y ajusta la geometría guardada.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_outlined),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

final class _QuadrantPainter extends CustomPainter {
  _QuadrantPainter({
    required this.sectors,
    required this.background,
    required this.fill,
    required this.stroke,
    required this.labelColor,
  });

  final List<SectorSummary> sectors;
  final Color background;
  final Color fill;
  final Color stroke;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    final polygons = <(SectorSummary, List<GeoPoint>)>[];
    for (final sector in sectors) {
      try {
        final points = (jsonDecode(sector.polygonJson) as List<Object?>)
            .cast<Map<String, Object?>>()
            .map(
              (value) => GeoPoint(
                (value['lat'] as num).toDouble(),
                (value['lng'] as num).toDouble(),
              ),
            )
            .toList(growable: false);
        if (points.length >= 3) polygons.add((sector, points));
      } on Object {
        // Invalid geometry is ignored in the preview; the textual list remains.
      }
    }
    if (polygons.isEmpty) {
      final text = TextPainter(
        text: TextSpan(
          text: 'Geometría no disponible',
          style: TextStyle(color: labelColor),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width - AgroSpacing.lg * 2);
      text.paint(
        canvas,
        Offset((size.width - text.width) / 2, (size.height - text.height) / 2),
      );
      return;
    }
    final all = polygons.expand((value) => value.$2);
    final minLat = all.map((value) => value.latitude).reduce(math.min);
    final maxLat = all.map((value) => value.latitude).reduce(math.max);
    final minLng = all.map((value) => value.longitude).reduce(math.min);
    final maxLng = all.map((value) => value.longitude).reduce(math.max);
    final latSpan = math.max(maxLat - minLat, .000001);
    final lngSpan = math.max(maxLng - minLng, .000001);
    const inset = AgroSpacing.md;
    Offset project(GeoPoint point) => Offset(
      inset + (point.longitude - minLng) / lngSpan * (size.width - inset * 2),
      inset + (maxLat - point.latitude) / latSpan * (size.height - inset * 2),
    );
    for (final entry in polygons) {
      final path = Path()
        ..moveTo(project(entry.$2.first).dx, project(entry.$2.first).dy);
      for (final point in entry.$2.skip(1)) {
        final offset = project(point);
        path.lineTo(offset.dx, offset.dy);
      }
      path.close();
      canvas
        ..drawPath(path, Paint()..color = fill)
        ..drawPath(
          path,
          Paint()
            ..color = stroke
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      final center =
          entry.$2.map(project).reduce((left, right) => left + right) /
          entry.$2.length.toDouble();
      final label = TextPainter(
        text: TextSpan(
          text: '${entry.$1.number}',
          style: TextStyle(
            color: labelColor,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(canvas, center - Offset(label.width / 2, label.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _QuadrantPainter oldDelegate) =>
      oldDelegate.sectors != sectors ||
      oldDelegate.background != background ||
      oldDelegate.fill != fill ||
      oldDelegate.stroke != stroke ||
      oldDelegate.labelColor != labelColor;
}

import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_section_header.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// One card per automatic alert, each with its switch and threshold.
final class FieldAlertsSection extends ConsumerWidget {
  const FieldAlertsSection({required this.ownerId, super.key});

  final String ownerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facade = ref.watch(fieldAlertsFacadeProvider);
    return StreamBuilder<FieldAlertSettings>(
      stream: facade.watchSettings(ownerId),
      builder: (context, snapshot) {
        final settings = snapshot.data ?? FieldAlertSettings.defaults;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AgroSectionHeader(
              title: 'Alertas automáticas',
              subtitle: 'Te avisan aunque la app esté cerrada.',
            ),
            const SizedBox(height: AgroSpacing.sm),
            for (final kind in FieldAlertKind.values)
              _FieldAlertCard(
                kind: kind,
                rule: settings.rule(kind),
                onChanged: (rule) async {
                  try {
                    await facade.saveRule(ownerId, kind, rule);
                  } on Object {
                    // The setting is saved first; a failed check retries on
                    // the next resume or background run.
                  }
                },
              ),
          ],
        );
      },
    );
  }
}

final class _FieldAlertCard extends StatelessWidget {
  const _FieldAlertCard({
    required this.kind,
    required this.rule,
    required this.onChanged,
  });

  final FieldAlertKind kind;
  final FieldAlertRule rule;
  final ValueChanged<FieldAlertRule> onChanged;

  @override
  Widget build(BuildContext context) {
    final spec = _AlertSpec.of(kind);
    final value = rule.threshold.round();
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AgroSpacing.sm,
          AgroSpacing.xs,
          AgroSpacing.xs,
          AgroSpacing.xs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(
                spec.icon,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(spec.title),
              subtitle: Text(spec.description(value)),
              value: rule.enabled,
              onChanged: (enabled) =>
                  onChanged(rule.copyWith(enabled: enabled)),
            ),
            if (rule.enabled)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      spec.thresholdLabel,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Bajar ${spec.thresholdLabel.toLowerCase()}',
                    onPressed: value <= spec.min
                        ? null
                        : () => onChanged(
                            rule.copyWith(threshold: (value - 1).toDouble()),
                          ),
                    icon: const Icon(LucideIcons.minus),
                  ),
                  SizedBox(
                    width: 72,
                    child: Text(
                      spec.format(value),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Subir ${spec.thresholdLabel.toLowerCase()}',
                    onPressed: value >= spec.max
                        ? null
                        : () => onChanged(
                            rule.copyWith(threshold: (value + 1).toDouble()),
                          ),
                    icon: const Icon(LucideIcons.plus),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

final class _AlertSpec {
  const _AlertSpec({
    required this.icon,
    required this.title,
    required this.description,
    required this.thresholdLabel,
    required this.format,
    required this.min,
    required this.max,
  });

  factory _AlertSpec.of(FieldAlertKind kind) => switch (kind) {
    FieldAlertKind.seasonEnd => _AlertSpec(
      icon: LucideIcons.calendarClock,
      title: 'Fin de temporada',
      description: (days) =>
          'Avisa $days ${days == 1 ? 'día' : 'días'} antes de que termine '
          'la temporada de un cuadrante.',
      thresholdLabel: 'Días de anticipación',
      format: (days) => '$days d',
      min: 1,
      max: 60,
    ),
    FieldAlertKind.frost => _AlertSpec(
      icon: LucideIcons.snowflake,
      title: 'Helada',
      description: (degrees) =>
          'Avisa si el pronóstico baja a $degrees °C o menos. No es alerta '
          'oficial.',
      thresholdLabel: 'Mínima de helada',
      format: _degrees,
      min: -10,
      max: 5,
    ),
    FieldAlertKind.cold => _AlertSpec(
      icon: LucideIcons.thermometerSnowflake,
      title: 'Temperatura baja',
      description: (degrees) =>
          'Avisa si la mínima pronosticada baja a $degrees °C o menos.',
      thresholdLabel: 'Mínima',
      format: _degrees,
      min: -5,
      max: 20,
    ),
    FieldAlertKind.heat => _AlertSpec(
      icon: LucideIcons.thermometerSun,
      title: 'Temperatura alta',
      description: (degrees) =>
          'Avisa si la máxima pronosticada llega a $degrees °C o más.',
      thresholdLabel: 'Máxima',
      format: _degrees,
      min: 15,
      max: 45,
    ),
  };

  final IconData icon;
  final String title;
  final String Function(int value) description;
  final String thresholdLabel;
  final String Function(int value) format;
  final int min;
  final int max;

  static String _degrees(int value) => '$value °C';
}

import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:flutter/material.dart';

final class AgroMetricCard extends StatelessWidget {
  const AgroMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    this.supportingText,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? supportingText;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$label. $value${supportingText == null ? '' : '. $supportingText'}',
    excludeSemantics: true,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(AgroSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: AgroSizes.iconStandard,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AgroSpacing.xs),
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AgroSpacing.xs),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            if (supportingText case final text?) ...[
              const SizedBox(height: AgroSpacing.xxs),
              Text(
                text,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

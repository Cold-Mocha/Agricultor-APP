import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:flutter/material.dart';

final class AgroActionTile extends StatelessWidget {
  const AgroActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.description,
    super.key,
  });

  final IconData icon;
  final String label;
  final String? description;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: onTap != null,
    enabled: onTap != null,
    label: description == null ? label : '$label. $description',
    excludeSemantics: true,
    child: Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 92),
          child: Padding(
            padding: const EdgeInsets.all(AgroSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: AgroSizes.iconAction,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: AgroSpacing.xs),
                Text(label, style: Theme.of(context).textTheme.titleSmall),
                if (description case final value?) ...[
                  const SizedBox(height: AgroSpacing.xxs),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

final class AgroAdaptiveGrid extends StatelessWidget {
  const AgroAdaptiveGrid({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final textScale = MediaQuery.textScalerOf(context).scale(1);
      final columns = constraints.maxWidth >= 360 && textScale <= 1.35 ? 2 : 1;
      final width = columns == 1
          ? constraints.maxWidth
          : (constraints.maxWidth - AgroSpacing.xs) / 2;
      return Wrap(
        spacing: AgroSpacing.xs,
        runSpacing: AgroSpacing.xs,
        children: [
          for (final child in children) SizedBox(width: width, child: child),
        ],
      );
    },
  );
}

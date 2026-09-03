import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:flutter/material.dart';

final class AgroNavigationCard extends StatelessWidget {
  const AgroNavigationCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Semantics(
    button: onTap != null,
    enabled: onTap != null,
    label: '$title. $subtitle',
    excludeSemantics: true,
    child: Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 80),
          child: Padding(
            padding: const EdgeInsets.all(AgroSpacing.md),
            child: Row(
              children: [
                Container(
                  width: AgroSizes.touchTarget,
                  height: AgroSizes.touchTarget,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AgroRadii.medium),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    size: AgroSizes.iconAction,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: AgroSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AgroSpacing.xxs),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AgroSpacing.xs),
                trailing ??
                    const ExcludeSemantics(
                      child: Icon(Icons.chevron_right_outlined),
                    ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

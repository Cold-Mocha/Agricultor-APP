import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:flutter/material.dart';

final class AgroSettingsGroup extends StatelessWidget {
  const AgroSettingsGroup({
    required this.title,
    required this.children,
    super.key,
  });

  final String title;
  final List<AgroSettingsTile> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AgroSpacing.xxs),
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      ),
      const SizedBox(height: AgroSpacing.xs),
      Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var index = 0; index < children.length; index++) ...[
              children[index],
              if (index != children.length - 1)
                const Divider(height: 1, indent: 64),
            ],
          ],
        ),
      ),
    ],
  );
}

final class AgroSettingsTile extends StatelessWidget {
  const AgroSettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.value,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '$title. $subtitle${value == null ? '' : '. Valor actual: $value'}',
    excludeSemantics: true,
    child: ListTile(
      minVerticalPadding: AgroSpacing.sm,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value case final text?)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 112),
              child: Text(
                text,
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(width: AgroSpacing.xxs),
          const Icon(Icons.chevron_right_outlined),
        ],
      ),
      onTap: onTap,
    ),
  );
}

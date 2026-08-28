import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:flutter/material.dart';

final class AgroPage extends StatelessWidget {
  const AgroPage({
    required this.title,
    required this.child,
    this.subtitle,
    this.actions = const [],
    this.padding = const EdgeInsets.all(AgroSpacing.md),
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget> actions;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: actions,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          if (subtitle case final value?)
            Text(value, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: Padding(padding: padding, child: child),
        ),
      ),
    ),
  );
}

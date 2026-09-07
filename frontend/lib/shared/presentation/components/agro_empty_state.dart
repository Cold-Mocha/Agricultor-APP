import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:flutter/material.dart';

final class AgroEmptyState extends StatelessWidget {
  const AgroEmptyState({
    required this.title,
    required this.message,
    this.action,
    super.key,
  });

  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AgroSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.eco_outlined, size: 48),
          const SizedBox(height: AgroSpacing.md),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AgroSpacing.xs),
          Text(message, textAlign: TextAlign.center),
          if (action case final value?) ...[
            const SizedBox(height: AgroSpacing.lg),
            value,
          ],
        ],
      ),
    ),
  );
}

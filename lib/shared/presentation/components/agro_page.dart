import 'package:agrocampo/app/shell/agro_global_sync_status.dart';
import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class AgroPage extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerId = ref.watch(unlockedOwnerIdProvider);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: subtitle == null
            ? kToolbarHeight
            : textScale > 1.3
            ? 96
            : 76,
        actions: actions,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, maxLines: 2),
            if (subtitle case final value?)
              Text(
                value,
                maxLines: textScale > 1.3 ? 2 : 1,
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        bottom: ownerId == null ? null : AgroGlobalSyncStatus(ownerId: ownerId),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AgroSizes.maxContentWidth,
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

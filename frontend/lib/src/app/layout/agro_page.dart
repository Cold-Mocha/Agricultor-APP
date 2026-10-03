import 'package:agrocampo/src/app/shell/agro_global_sync_status.dart';
import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class AgroPage extends ConsumerWidget {
  const AgroPage({
    required this.title,
    required this.child,
    this.subtitle,
    this.actions = const [],
    this.padding = const EdgeInsets.all(AgroSpacing.md),
    this.showGlobalStatus = true,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget> actions;
  final EdgeInsetsGeometry padding;
  final bool showGlobalStatus;

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
        // Local mode has no cloud backup to report, so the banner stays hidden.
        bottom:
            ownerId == null ||
                !showGlobalStatus ||
                ref.watch(isLocalModeProvider)
            ? null
            : AgroGlobalSyncStatus(ownerId: ownerId),
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

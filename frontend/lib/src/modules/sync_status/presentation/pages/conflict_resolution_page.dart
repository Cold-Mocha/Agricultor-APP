import 'package:agrocampo/src/app/layout/agro_page.dart';
import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/modules/sync_status/presentation/controllers/sync_status_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class ConflictResolutionPage extends ConsumerWidget {
  const ConflictResolutionPage({required this.conflictId, super.key});

  final String conflictId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(syncStatusControllerProvider);
    return AgroPage(
      title: 'Resolver conflicto',
      subtitle: 'Compara ambas versiones antes de elegir. Ninguna se descarta en silencio.',
      child: FutureBuilder<ConflictComparisonUiState?>(
        future: controller.loadConflict(conflictId),
        builder: (context, snapshot) {
          final conflict = snapshot.data;
          if (conflict == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: [
              _VersionCard(
                title: 'Versión de este dispositivo',
                description: conflict.localDescription,
              ),
              _VersionCard(
                title: 'Versión respaldada',
                description: conflict.remoteDescription,
              ),
              FilledButton(
                onPressed: () => controller.keepLocalVersion(conflictId),
                child: const Text('Conservar versión local'),
              ),
              OutlinedButton(
                onPressed: () => controller.useBackedUpVersion(conflictId),
                child: const Text('Usar versión respaldada'),
              ),
            ],
          );
        },
      ),
    );
  }
}

final class _VersionCard extends StatelessWidget {
  const _VersionCard({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AgroSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(title), Text(description)],
      ),
    ),
  );
}

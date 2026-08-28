import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/core/sync/conflicts/conflict_resolver.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class ConflictResolutionPage extends ConsumerWidget {
  const ConflictResolutionPage({required this.conflictId, super.key});

  final String conflictId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(appDatabaseProvider);
    return AgroPage(
      title: 'Resolver conflicto',
      subtitle: 'Compara ambas versiones antes de elegir. Ninguna se descarta en silencio.',
      child: FutureBuilder(
        future: (database.select(
          database.syncConflicts,
        )..where((row) => row.conflictId.equals(conflictId))).getSingleOrNull(),
        builder: (context, snapshot) {
          final conflict = snapshot.data;
          if (conflict == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: [
              _VersionCard(
                title: 'Versión de este dispositivo',
                json: conflict.localJson,
              ),
              _VersionCard(
                title: 'Versión respaldada',
                json: conflict.remoteJson,
              ),
              FilledButton(
                onPressed: () =>
                    ConflictResolver(database)
                        .resolve(conflictId, ConflictChoice.keepLocal),
                child: const Text('Conservar versión local'),
              ),
              OutlinedButton(
                onPressed: () =>
                    ConflictResolver(database)
                        .resolve(conflictId, ConflictChoice.keepRemote),
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
  const _VersionCard({required this.title, required this.json});

  final String title;
  final String json;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AgroSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(title), Text(json)],
      ),
    ),
  );
}

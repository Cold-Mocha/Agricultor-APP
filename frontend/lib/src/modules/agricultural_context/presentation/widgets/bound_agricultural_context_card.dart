import 'package:agrocampo/src/modules/agricultural_context/presentation/controllers/agricultural_context_controller.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class BoundAgriculturalContextCard extends ConsumerWidget {
  const BoundAgriculturalContextCard({
    required this.bound,
    required this.changed,
    required this.onRebind,
    super.key,
  });

  final BoundAgriculturalContext bound;
  final bool changed;
  final VoidCallback onRebind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(contextOptionsControllerProvider);
    return FutureBuilder(
      future: controller.loadBound(bound),
      builder: (context, snapshot) {
        final value = snapshot.data;
        return Card(
          color: changed
              ? Theme.of(context).colorScheme.tertiaryContainer
              : null,
          child: ListTile(
            leading: Icon(changed ? Icons.info_outline : Icons.place_outlined),
            title: Text(
              [
                value?.parcelName,
                value?.sectorName,
              ].whereType<String>().join(' · '),
            ),
            subtitle: Text(
              changed
                  ? 'La selección global cambió; este formulario conserva su contexto.'
                  : 'Contexto fijado para este formulario',
            ),
            trailing: changed
                ? TextButton(
                    onPressed: onRebind,
                    child: const Text('Usar actual'),
                  )
                : null,
          ),
        );
      },
    );
  }
}

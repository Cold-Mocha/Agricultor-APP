import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

final class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ownerId = ref.watch(sessionControllerProvider).ownerId;
    return AgroPage(
      title: 'Perfil',
      subtitle: 'Datos del agricultor propietario',
      child: ListView(
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Nombre visible'),
          ),
          const SizedBox(height: AgroSpacing.lg),
          FilledButton(
            onPressed: ownerId == null
                ? null
                : () async {
                    final value = _name.text.trim();
                    if (value.isEmpty) return;
                    await ref
                        .read(appDatabaseProvider)
                        .into(ref.read(appDatabaseProvider).localProfiles)
                        .insertOnConflictUpdate(
                          LocalProfilesCompanion.insert(
                            id: ownerId,
                            displayName: value,
                            updatedAt: DateTime.now().toUtc(),
                            emailDisplay: const Value.absent(),
                          ),
                        );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Perfil guardado localmente.'),
                      ),
                    );
                  },
            child: const Text('Guardar'),
          ),
          const SizedBox(height: AgroSpacing.sm),
          OutlinedButton(
            onPressed: () =>
                ref.read(sessionControllerProvider.notifier).signOut(),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

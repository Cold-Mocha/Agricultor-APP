import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/features/agro_ai/data/agro_ai_gateway.dart';
import 'package:agrocampo/features/agro_ai/data/agro_ai_repository.dart';
import 'package:agrocampo/features/agro_ai/domain/agro_ai_message.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class AgroAiPage extends ConsumerStatefulWidget {
  const AgroAiPage({super.key});
  @override
  ConsumerState<AgroAiPage> createState() => _AgroAiPageState();
}

final class _AgroAiPageState extends ConsumerState<AgroAiPage> {
  final _question = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _question.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final database = ref.watch(appDatabaseProvider);
    final ownerId = ref.watch(sessionControllerProvider).ownerId;
    return AgroPage(
      title: 'AgroIA',
      subtitle: agroAiDisclaimer,
      child: Column(
        children: [
          Expanded(
            child: ownerId == null
                ? const Center(child: Text('Inicia sesión para consultar.'))
                : StreamBuilder(
                    stream:
                        (database.select(database.aiMessages)
                              ..where((row) => row.ownerId.equals(ownerId))
                              ..orderBy([
                                (row) => OrderingTerm.asc(row.createdAt),
                              ]))
                            .watch(),
                    builder: (context, snapshot) => ListView(
                      children: [
                        for (final message in snapshot.data ?? const [])
                          ListTile(
                            leading: Icon(
                              message.role == 'user'
                                  ? Icons.person_outline
                                  : Icons.eco_outlined,
                            ),
                            title: Text(message.content),
                          ),
                      ],
                    ),
                  ),
          ),
          TextField(
            controller: _question,
            decoration: const InputDecoration(labelText: 'Consulta agrícola'),
          ),
          FilledButton(
            onPressed: ownerId == null || _sending ? null : _send,
            child: Text(_sending ? 'Consultando…' : 'Enviar consulta'),
          ),
        ],
      ),
    );
  }

  Future<void> _send() async {
    setState(() => _sending = true);
    try {
      await AgroAiRepository(
        ref.read(appDatabaseProvider),
        SupabaseAgroAiGateway(Supabase.instance.client),
      ).ask(
        ownerId: ref.read(sessionControllerProvider).ownerId!,
        question: _question.text,
      );
      _question.clear();
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'AgroIA no está disponible. Tus registros offline siguen funcionando.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }
}

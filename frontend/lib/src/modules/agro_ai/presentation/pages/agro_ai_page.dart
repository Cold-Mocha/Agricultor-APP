import 'package:agrocampo/src/app/layout/agro_page.dart';
import 'package:agrocampo/src/modules/agro_ai/presentation/controllers/agro_ai_controller.dart';
import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_empty_state.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final controller = ref.watch(agroAiControllerProvider);
    final ownerId = ref.watch(sessionControllerProvider).ownerId;
    return AgroPage(
      title: 'AgroIA',
      subtitle: agroAiDisclaimer,
      child: Column(
        children: [
          Expanded(
            child: ownerId == null
                ? const Center(child: Text('Inicia sesión para consultar.'))
                : StreamBuilder<List<AgroAiMessageSummary>>(
                    stream: controller.watchMessages(ownerId),
                    builder: (context, snapshot) {
                      final messages = snapshot.data ?? const [];
                      if (messages.isEmpty) {
                        return const AgroEmptyState(
                          title: 'Haz tu primera consulta',
                          message: 'Pregunta por conceptos o prácticas generales. Verifica siempre la respuesta en terreno.',
                        );
                      }
                      return ListView(
                        children: [
                          for (final message in messages)
                            ListTile(
                              leading: Icon(
                                message.role == 'user'
                                    ? Icons.person_outline
                                    : Icons.eco_outlined,
                              ),
                              title: Text(message.content),
                              subtitle:
                                  message.role == 'user' &&
                                      message.state != 'sent'
                                  ? Text(
                                      message.state == 'sending' ? 'Enviando…' : 'Sin conexión o servicio no configurado.',
                                    )
                                  : null,
                              trailing:
                                  message.role == 'user' &&
                                      message.state == 'error'
                                  ? TextButton(
                                      onPressed: () =>
                                          _retry(message.clientMessageId),
                                      child: const Text('Reintentar'),
                                    )
                                  : null,
                            ),
                        ],
                      );
                    },
                  ),
          ),
          TextField(
            controller: _question,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(labelText: 'Consulta agrícola'),
          ),
          Semantics(
            label: 'Enviar consulta a AgroIA',
            button: true,
            child: FilledButton(
              onPressed:
                  ownerId == null || _sending || _question.text.trim().isEmpty
                  ? null
                  : _send,
              child: Text(_sending ? 'Consultando…' : 'Enviar consulta'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _send() async {
    if (_question.text.trim().isEmpty) return;
    setState(() => _sending = true);
    try {
      await ref
          .read(agroAiControllerProvider)
          .ask(
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

  Future<void> _retry(String clientMessageId) async {
    try {
      await ref
          .read(agroAiControllerProvider)
          .retry(
            ownerId: ref.read(sessionControllerProvider).ownerId!,
            clientMessageId: clientMessageId,
          );
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'AgroIA sigue sin conexión; la pregunta quedó guardada.',
          ),
        ),
      );
    }
  }
}

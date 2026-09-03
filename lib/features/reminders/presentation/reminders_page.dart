import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/context/presentation/agricultural_context_controller.dart';
import 'package:agrocampo/features/reminders/data/reminder_repository.dart';
import 'package:agrocampo/features/reminders/domain/reminder.dart';
import 'package:agrocampo/shared/presentation/components/agricultural_context_selector.dart';
import 'package:agrocampo/shared/presentation/components/agro_empty_state.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class RemindersPage extends ConsumerStatefulWidget {
  const RemindersPage({super.key});

  @override
  ConsumerState<RemindersPage> createState() => _RemindersPageState();
}

final class _RemindersPageState extends ConsumerState<RemindersPage> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  DateTime _scheduledAt = DateTime.now().add(const Duration(hours: 1));
  String? _editingId;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ownerId = ref.watch(sessionControllerProvider).ownerId;
    final database = ref.watch(appDatabaseProvider);
    return AgroPage(
      title: 'Recordatorios',
      subtitle: 'Avisos locales disponibles sin conexión',
      child: ListView(
        children: [
          const AgriculturalContextSelector(),
          const SizedBox(height: AgroSpacing.sm),
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Título'),
          ),
          const SizedBox(height: AgroSpacing.sm),
          TextField(
            controller: _description,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Descripción (opcional)',
            ),
          ),
          const SizedBox(height: AgroSpacing.sm),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule),
            title: const Text('Fecha y hora'),
            subtitle: Text(_scheduledAt.toLocal().toString()),
            onTap: _pickDateTime,
          ),
          FilledButton(
            onPressed: ownerId == null ? null : _save,
            child: Text(
              _editingId == null ? 'Programar recordatorio' : 'Guardar cambios',
            ),
          ),
          const Divider(height: AgroSpacing.lg),
          if (ownerId != null)
            StreamBuilder<List<Reminder>>(
              stream:
                  (database.select(database.reminders)
                        ..where(
                          (row) =>
                              row.ownerId.equals(ownerId) &
                              row.deletedAt.isNull(),
                        )
                        ..orderBy([(row) => OrderingTerm.asc(row.scheduledAt)]))
                      .watch(),
              builder: (context, snapshot) {
                final reminders = snapshot.data ?? const <Reminder>[];
                if (reminders.isEmpty) {
                  return const AgroEmptyState(
                    title: 'Aún no hay recordatorios',
                    message: 'Programa una labor y quedará guardada incluso sin conexión.',
                  );
                }
                return Column(
                  children: [
                    for (final reminder in reminders)
                      Card(
                        child: ListTile(
                          leading: Icon(
                            reminder.status == 'scheduled'
                                ? Icons.notifications_none
                                : Icons.notifications_off_outlined,
                          ),
                          title: Text(reminder.title),
                          subtitle: Text(
                            [
                              reminder.scheduledAt.toLocal().toString(),
                              reminder.status,
                              switch (reminder.notificationState) {
                                'permissionDenied' => 'Permiso denegado; recordatorio conservado sin aviso',
                                'error' => 'Aviso del sistema no disponible; dato conservado',
                                _ => reminder.syncState,
                              },
                            ].join(' · '),
                          ),
                          trailing: reminder.status != 'scheduled'
                              ? null
                              : PopupMenuButton<String>(
                                  onSelected: (action) =>
                                      _action(reminder, action),
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Editar'),
                                    ),
                                    PopupMenuItem(
                                      value: 'complete',
                                      child: Text('Completar'),
                                    ),
                                    PopupMenuItem(
                                      value: 'cancel',
                                      child: Text('Cancelar'),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
    );
    if (time == null) return;
    setState(
      () => _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ),
    );
  }

  Future<void> _save() async {
    final ownerId = ref.read(sessionControllerProvider).ownerId!;
    final context = ref.read(agriculturalContextControllerProvider);
    final scheduler = ref.read(localNotificationSchedulerProvider);
    await ReminderRepository(ref.read(appDatabaseProvider), scheduler).save(
      ownerId: ownerId,
      id: _editingId,
      input: ReminderInput(
        title: _title.text,
        description: _description.text,
        scheduledAt: _scheduledAt,
        parcelId: context.parcelId,
        sectorId: context.sectorId,
        sourceTimeZone: DateTime.now().timeZoneName,
      ),
    );
    if (!mounted) return;
    setState(() {
      _editingId = null;
      _title.clear();
      _description.clear();
      _scheduledAt = DateTime.now().add(const Duration(hours: 1));
    });
  }

  Future<void> _action(Reminder reminder, String action) async {
    final ownerId = ref.read(sessionControllerProvider).ownerId!;
    final repository = ReminderRepository(
      ref.read(appDatabaseProvider),
      ref.read(localNotificationSchedulerProvider),
    );
    if (action == 'edit') {
      setState(() {
        _editingId = reminder.id;
        _title.text = reminder.title;
        _description.text = reminder.description ?? '';
        _scheduledAt = reminder.scheduledAt.toLocal();
      });
    } else if (action == 'complete') {
      await repository.complete(ownerId, reminder.id);
    } else {
      await repository.cancel(ownerId, reminder.id);
    }
  }
}

import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/core/notifications/local_notification_scheduler.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/reminders/data/reminder_repository.dart';
import 'package:agrocampo/features/reminders/domain/reminder.dart';
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
  DateTime _scheduledAt = DateTime.now().add(const Duration(hours: 1));

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ownerId = ref.watch(sessionControllerProvider).ownerId;
    final database = ref.watch(appDatabaseProvider);
    return AgroPage(
      title: 'Recordatorios',
      subtitle: 'Avisos locales para labores agrícolas',
      child: ListView(
        children: [
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Título'),
          ),
          const SizedBox(height: AgroSpacing.sm),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Fecha y hora'),
            subtitle: Text(_scheduledAt.toLocal().toString()),
            onTap: () => setState(
              () => _scheduledAt = DateTime.now().add(const Duration(hours: 1)),
            ),
          ),
          FilledButton(
            onPressed: ownerId == null ? null : _save,
            child: const Text('Programar recordatorio'),
          ),
          const Divider(),
          if (ownerId != null)
            StreamBuilder(
              stream:
                  (database.select(database.reminders)
                        ..where((row) => row.ownerId.equals(ownerId))
                        ..orderBy([(row) => OrderingTerm.asc(row.scheduledAt)]))
                      .watch(),
              builder: (context, snapshot) => Column(
                children: [
                  for (final reminder in snapshot.data ?? const [])
                    ListTile(
                      leading: const Icon(Icons.notifications_none),
                      title: Text(reminder.title),
                      subtitle: Text(reminder.scheduledAt.toLocal().toString()),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final ownerId = ref.read(sessionControllerProvider).ownerId!;
    final scheduler = PluginLocalNotificationScheduler();
    await scheduler.initialize();
    await scheduler.requestPermission();
    await ReminderRepository(ref.read(appDatabaseProvider), scheduler).save(
      ownerId: ownerId,
      input: ReminderInput(title: _title.text, scheduledAt: _scheduledAt),
    );
  }
}

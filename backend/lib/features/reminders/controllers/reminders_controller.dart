import 'package:agrocampo_backend/core/config/backend_providers.dart';
import 'package:agrocampo_backend/core/database/app_database.dart';
import 'package:agrocampo_backend/features/reminders/domain/reminder.dart';
import 'package:agrocampo_backend/features/reminders/repositories/reminder_repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final remindersControllerProvider = Provider<RemindersController>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return RemindersController._(
    database,
    ReminderRepository(database, ref.watch(localNotificationSchedulerProvider)),
  );
});

final class ReminderView {
  const ReminderView({
    required this.id,
    required this.title,
    required this.scheduledAt,
    required this.status,
    required this.notificationState,
    required this.syncState,
    this.description,
  });
  final String id;
  final String title;
  final String? description;
  final DateTime scheduledAt;
  final String status;
  final String notificationState;
  final String syncState;
}

final class RemindersController {
  RemindersController._(this._database, this._repository);
  final AppDatabase _database;
  final ReminderRepository _repository;

  Stream<List<ReminderView>> watch(String ownerId) =>
      (_database.select(_database.reminders)
            ..where(
              (row) => row.ownerId.equals(ownerId) & row.deletedAt.isNull(),
            )
            ..orderBy([(row) => OrderingTerm.asc(row.scheduledAt)]))
          .watch()
          .map(
            (rows) => rows
                .map(
                  (row) => ReminderView(
                    id: row.id,
                    title: row.title,
                    description: row.description,
                    scheduledAt: row.scheduledAt,
                    status: row.status,
                    notificationState: row.notificationState,
                    syncState: row.syncState,
                  ),
                )
                .toList(growable: false),
          );
  Future<String> save({
    required String ownerId,
    required ReminderInput input,
    String? id,
  }) => _repository.save(ownerId: ownerId, input: input, id: id);
  Future<void> complete(String ownerId, String id) =>
      _repository.complete(ownerId, id);
  Future<void> cancel(String ownerId, String id) =>
      _repository.cancel(ownerId, id);
}

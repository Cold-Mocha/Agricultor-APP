import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/modules/reminders/contracts/dto/reminder_summary.dart';
import 'package:agrocampo_backend/src/modules/reminders/domain/entities/reminder.dart';
import 'package:agrocampo_backend/src/modules/reminders/infrastructure/persistence/reminder_repository.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final remindersFacadeProvider = Provider<RemindersFacade>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return RemindersFacade._(
    database,
    ReminderRepository(
      database,
      ref.watch(localNotificationSchedulerProvider),
      ref.watch(reminderNotificationPayloadBuilderProvider),
    ),
  );
});

final class RemindersFacade {
  RemindersFacade._(this._database, this._repository);
  final AppDatabase _database;
  final ReminderRepository _repository;

  Stream<List<ReminderSummary>> watch(String ownerId) =>
      (_database.select(_database.reminders)
            ..where(
              (row) => row.ownerId.equals(ownerId) & row.deletedAt.isNull(),
            )
            ..orderBy([(row) => OrderingTerm.asc(row.scheduledAt)]))
          .watch()
          .map(
            (rows) => rows
                .map(
                  (row) => ReminderSummary(
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

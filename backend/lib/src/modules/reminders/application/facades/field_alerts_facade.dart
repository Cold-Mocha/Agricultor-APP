import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/composition/sync_scheduler.dart';
import 'package:agrocampo_backend/src/modules/reminders/domain/entities/field_alerts.dart';
import 'package:agrocampo_backend/src/modules/reminders/infrastructure/alerts/field_alert_service.dart';
import 'package:agrocampo_backend/src/platform/notifications/local_notification_scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fieldAlertsFacadeProvider = Provider<FieldAlertsFacade>(
  (ref) => FieldAlertsFacade._(
    FieldAlertService(ref.watch(appDatabaseProvider)),
    ref.watch(fieldAlertNotifierProvider),
    ref.watch(fieldAlertSchedulerProvider),
    ref.watch(localNotificationSchedulerProvider).requestPermission,
  ),
);

/// Season-end, frost, cold and heat alerts with farmer-defined thresholds.
final class FieldAlertsFacade {
  FieldAlertsFacade._(
    this._service,
    this._notifier,
    this._scheduler,
    this._requestPermission,
  );

  final FieldAlertService _service;
  final FieldAlertNotifier _notifier;
  final FieldAlertScheduler _scheduler;
  final Future<bool> Function() _requestPermission;

  Stream<FieldAlertSettings> watchSettings(String ownerId) =>
      _service.watchSettings(ownerId);

  Future<void> saveRule(
    String ownerId,
    FieldAlertKind kind,
    FieldAlertRule rule,
  ) async {
    final settings = await _service.loadSettings(ownerId);
    await _service.saveSettings(ownerId, settings.withRule(kind, rule));
    // Android 13+ asks once; a denied permission keeps the settings saved.
    if (rule.enabled) await _requestPermission();
    await checkNow(ownerId);
  }

  /// Notifies the alerts due from the data already on the device and keeps
  /// the periodic background check scheduled.
  Future<void> checkNow(String ownerId) async {
    for (final notice in await _service.takeNewNotices(ownerId)) {
      await _notifier.show(
        id: stableNotificationId(notice.key),
        title: notice.title,
        body: notice.body,
      );
    }
    await _scheduler.schedule(ownerId: ownerId);
  }

  Future<void> stop(String ownerId) => _scheduler.cancel(ownerId: ownerId);
}

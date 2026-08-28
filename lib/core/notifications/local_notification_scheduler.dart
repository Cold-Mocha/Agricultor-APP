import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

abstract interface class LocalNotificationScheduler {
  Future<void> initialize();
  Future<bool> requestPermission();
  Future<void> schedule({
    required int id,
    required String title,
    required DateTime scheduledAt,
    String? payload,
  });
  Future<void> cancel(int id);
}

final class PluginLocalNotificationScheduler
    implements LocalNotificationScheduler {
  PluginLocalNotificationScheduler([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  @override
  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
  }

  @override
  Future<bool> requestPermission() async =>
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission() ??
      false;

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required DateTime scheduledAt,
    String? payload,
  }) => _plugin.zonedSchedule(
    id: id,
    title: title,
    body: 'Tienes una labor pendiente en AgroCampo.',
    scheduledDate: tz.TZDateTime.from(scheduledAt, tz.local),
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        'agrocampo_reminders',
        'Recordatorios agrícolas',
        channelDescription: 'Avisos de labores programadas por el agricultor',
        importance: Importance.high,
        priority: Priority.high,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    payload: payload,
  );

  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);
}

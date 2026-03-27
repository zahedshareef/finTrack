import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (kIsWeb) return;
    tz_data.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  static Future<void> schedulePaymentReminder({
    required int id,
    required String name,
    required double amount,
    required DateTime dueDate,
  }) async {
    if (kIsWeb || !_initialized) return;
    final reminderDate = dueDate.subtract(const Duration(days: 1));
    if (reminderDate.isBefore(DateTime.now())) return;

    final tzScheduled = tz.TZDateTime.from(reminderDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'planned_payments',
      'Planned Payments',
      channelDescription: 'Reminders for upcoming planned payments',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.zonedSchedule(
      id,
      'Payment Due Tomorrow',
      '$name — ${amount.toStringAsFixed(2)} due tomorrow',
      tzScheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelNotification(int id) async {
    if (kIsWeb || !_initialized) return;
    await _plugin.cancel(id);
  }

  static Future<void> cancelAll() async {
    if (kIsWeb || !_initialized) return;
    await _plugin.cancelAll();
  }
}

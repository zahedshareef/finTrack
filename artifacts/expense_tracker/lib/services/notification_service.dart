import 'package:flutter/foundation.dart';

class NotificationService {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (kIsWeb) return;
    _initialized = true;
  }

  static Future<void> schedulePaymentReminder({
    required int id,
    required String name,
    required double amount,
    required DateTime dueDate,
  }) async {
    if (kIsWeb || !_initialized) return;
  }

  static Future<void> cancelNotification(int id) async {
    if (kIsWeb || !_initialized) return;
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../states/gantt_task_model.dart';

class GanttNotificationService {
  static const int _dailyNotificationId = 9001;
  static const String _channelId = 'gantt_planner_channel';
  static const String _channelName = 'Mini Planner';
  static const String _channelDescription = 'Notifiche progresso task giornaliere';

  final FlutterLocalNotificationsPlugin _notifications;

  GanttNotificationService(this._notifications);

  Future<void> initialize() async {
    // NotificationService esistente gestisce già l'inizializzazione
  }

  Future<void> scheduleDailyNotification(List<GanttTaskModel> allTasks) async {
    final tasksWithNotifications = allTasks
        .where((t) => t.notificationsEnabled && !t.completed)
        .toList();

    if (tasksWithNotifications.isEmpty) {
      await cancelDailyNotification();
      return;
    }

    final int activeTasks = tasksWithNotifications.length;
    final int urgentTasks = tasksWithNotifications
        .where((t) => t.daysRemaining <= 3 && t.daysRemaining >= 0)
        .length;
    final int overdueTasks = tasksWithNotifications
        .where((t) => t.daysRemaining < 0)
        .length;

    final String title = '📊 Mini Planner';
    final String body = _buildNotificationBody(
      activeTasks,
      urgentTasks,
      overdueTasks,
    );

    await _scheduleDailyAt18(title, body);
  }

  String _buildNotificationBody(int active, int urgent, int overdue) {
    final List<String> parts = [];

    parts.add('$active task ${active == 1 ? 'attivo' : 'attivi'}');

    if (urgent > 0) {
      parts.add('$urgent in scadenza');
    }

    if (overdue > 0) {
      parts.add('$overdue scaduti');
    }

    return parts.join(', ');
  }

  Future<void> _scheduleDailyAt18(String title, String body) async {
    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      18,
      0,
      0,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      _dailyNotificationId,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'gantt_planner',
    );

    if (kDebugMode) {
      print('DEBUG: Notifica Gantt schedulata per ${scheduledDate.toString()}');
    }
  }

  Future<void> cancelDailyNotification() async {
    await _notifications.cancel(_dailyNotificationId);
    if (kDebugMode) {
      print('DEBUG: Notifica Gantt cancellata');
    }
  }

  Future<void> rescheduleNotification(List<GanttTaskModel> allTasks) async {
    await cancelDailyNotification();
    await scheduleDailyNotification(allTasks);
  }
}
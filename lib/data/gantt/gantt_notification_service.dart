import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../states/gantt_task_model.dart';

class GanttNotificationService {
  static const int _dailyNotificationId = 9001;
  static const String _channelId = 'gantt_planner_channel';

  final FlutterLocalNotificationsPlugin _notifications;

  GanttNotificationService(this._notifications);

  Future<void> initialize() async {
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

    final String title = 'notif_gantt_title'.tr();
    final String body = _buildNotificationBody(
      activeTasks,
      urgentTasks,
      overdueTasks,
    );

    await _scheduleDailyAt18(title, body);
  }

  String _buildNotificationBody(int active, int urgent, int overdue) {
    final List<String> parts = [];

    parts.add('notif_gantt_tasks_active'.tr(
      namedArgs: {'count': '$active'},
    ));

    if (urgent > 0) {
      parts.add('notif_gantt_tasks_urgent'.tr(
        namedArgs: {'count': '$urgent'},
      ));
    }

    if (overdue > 0) {
      parts.add('notif_gantt_tasks_overdue'.tr(
        namedArgs: {'count': '$overdue'},
      ));
    }

    return parts.join(', ');
  }

  Future<void> _scheduleDailyAt18(String title, String body) async {
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    final location = tz.getLocation(timeZoneName);
    final now = tz.TZDateTime.now(location);

    var scheduledDate = tz.TZDateTime(
      location,
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

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      'notif_gantt_channel'.tr(),
      channelDescription: 'notif_gantt_channel_desc'.tr(),
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
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
      print('DEBUG: Gantt notification scheduled for ${scheduledDate.toString()}');
    }
  }

  Future<void> cancelDailyNotification() async {
    await _notifications.cancel(_dailyNotificationId);
    if (kDebugMode) {
      print('DEBUG: Gantt notification cancelled');
    }
  }

  Future<void> rescheduleNotification(List<GanttTaskModel> allTasks) async {
    await cancelDailyNotification();
    await scheduleDailyNotification(allTasks);
  }
}
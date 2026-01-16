import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    await _requestPermissions();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<void> _requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // Per Android 12+
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  void _onNotificationTapped(NotificationResponse notificationResponse) {
    log('Notifica tappata: ${notificationResponse.payload}');
  }

  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'reminders_channel',
      'Promemoria',
      channelDescription: 'Canale per i promemoria giornalieri',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      enableLights: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleMultipleDaily({
    required String reminderId,
    required String title,
    required List<String> times,
  }) async {
    int notificationId = reminderId.hashCode;

    for (int i = 0; i < times.length; i++) {
      final timeParts = times[i].split(':');
      if (timeParts.length == 2) {
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);

        await scheduleDaily(
          id: notificationId + i,
          title: 'Promemoria: $title',
          body: 'È ora di: $title',
          hour: hour,
          minute: minute,
        );
      }
    }
  }

  Future<void> cancelReminder(String reminderId) async {
    int baseId = reminderId.hashCode;
    for (int i = 0; i < 24; i++) {
      await flutterLocalNotificationsPlugin.cancel(baseId + i);
    }
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'instant_channel',
      'Notifiche Immediate',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
    );
  }

  Future<void> scheduleCountdownNotification({
    required String countdownId,
    required String title,
    required DateTime targetDate,
    String? description,
  }) async {
    if (targetDate.isBefore(DateTime.now())) {
      return;
    }

    final int notificationId = countdownId.hashCode;
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(targetDate, tz.local);

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'countdown_channel',
      'Countdown',
      channelDescription: 'Notifiche per countdown completati',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      enableLights: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final String body = description?.isNotEmpty == true
        ? description!
        : 'Il tuo countdown è terminato!';

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      title,
      body,
      scheduledDate,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'countdown_$countdownId',
    );

    log('Notifica countdown schedulata: '
        '$title per $scheduledDate (ID: $notificationId)');
  }

  Future<void> cancelCountdownNotification(String countdownId) async {
    final int notificationId = countdownId.hashCode;
    await flutterLocalNotificationsPlugin.cancel(notificationId);
    log('Notifica countdown cancellata (ID: $notificationId)');
  }

  Future<void> showCountdownCompletedNotification({
    required String title,
    String? description,
  }) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'countdown_channel',
      'Countdown',
      channelDescription: 'Notifiche per countdown completati',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final String body = description?.isNotEmpty == true
        ? description!
        : 'Il tuo countdown è terminato!';

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformDetails,
    );
  }
}
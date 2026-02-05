import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';

/// Helper per ottenere le stringhe di notifica tradotte
/// Usare con easy_localization: NotificationStrings.tapToOpen.tr()
class NotificationStrings {
  static const String tapToOpen = 'notif_tap_to_open';
  static const String alarms = 'notif_alarms';
  static const String alarmsDesc = 'notif_alarms_desc';
  static const String reminderTitle = 'notif_reminder_title';
  static const String reminderBody = 'notif_reminder_body';
  static const String reminders = 'notif_reminders';
  static const String remindersDesc = 'notif_reminders_desc';
  static const String countdownCompleted = 'notif_countdown_completed';
  static const String countdown = 'notif_countdown';
  static const String countdownDesc = 'notif_countdown_desc';
  static const String timerCompleted = 'notif_timer_completed';
  static const String timerReady = 'notif_timer_ready';
  static const String timer = 'notif_timer';
  static const String timerDesc = 'notif_timer_desc';
  static const String instant = 'notif_instant';
}

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
    log('Notification tapped: ${notificationResponse.payload}');
  }

  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String channelName = 'Reminders',
    String channelDescription = 'Channel for daily reminders',
  }) async {
    final tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);

    final AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'reminders_channel',
      channelName,
      channelDescription: channelDescription,
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

    final NotificationDetails platformDetails = NotificationDetails(
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
    String? notificationTitle,
    String? notificationBody,
    String channelName = 'Reminders',
    String channelDescription = 'Channel for daily reminders',
  }) async {
    int notificationId = reminderId.hashCode;

    // Usa valori di default se non forniti
    final actualTitle = notificationTitle ?? 'Reminder: $title';
    final actualBody = notificationBody ?? 'It\'s time for: $title';

    for (int i = 0; i < times.length; i++) {
      final timeParts = times[i].split(':');
      if (timeParts.length == 2) {
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);

        await scheduleDaily(
          id: notificationId + i,
          title: actualTitle,
          body: actualBody,
          hour: hour,
          minute: minute,
          channelName: channelName,
          channelDescription: channelDescription,
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
    String channelName = 'Instant Notifications',
  }) async {
    final AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'instant_channel',
      channelName,
      importance: Importance.high,
      priority: Priority.high,
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
    );
  }

  // ============ COUNTDOWN NOTIFICATIONS ============

  /// Schedula una notifica per quando un countdown termina
  Future<void> scheduleCountdownNotification({
    required String countdownId,
    required String title,
    required DateTime targetDate,
    String? description,
    String defaultBody = 'Your countdown is completed!',
    String channelName = 'Countdown',
    String channelDescription = 'Notifications for completed countdowns',
  }) async {
    // Non schedulare se la data è già passata
    if (targetDate.isBefore(DateTime.now())) {
      return;
    }

    final int notificationId = countdownId.hashCode;
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(targetDate, tz.local);

    final AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'countdown_channel',
      channelName,
      channelDescription: channelDescription,
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

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final String body = description?.isNotEmpty == true
        ? description!
        : defaultBody;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      '🎉 $title',
      body,
      scheduledDate,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'countdown_$countdownId',
    );

    log('Countdown notification scheduled: $title for $scheduledDate (ID: $notificationId)');
  }

  /// Cancella la notifica di un countdown specifico
  Future<void> cancelCountdownNotification(String countdownId) async {
    final int notificationId = countdownId.hashCode;
    await flutterLocalNotificationsPlugin.cancel(notificationId);
    log('Countdown notification cancelled (ID: $notificationId)');
  }

  /// Mostra notifica immediata per countdown completato (quando app è aperta)
  Future<void> showCountdownCompletedNotification({
    required String title,
    String? description,
    String defaultBody = 'Your countdown is completed!',
    String channelName = 'Countdown',
    String channelDescription = 'Notifications for completed countdowns',
  }) async {
    final AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'countdown_channel',
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final String body = description?.isNotEmpty == true
        ? description!
        : defaultBody;

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '🎉 $title',
      body,
      platformDetails,
    );
  }

  /// KITCHEN TIMER NOTIFICATIONS

  /// Schedula una notifica per quando un timer da cucina termina
  Future<void> scheduleTimerNotification({
    required String timerId,
    required String timerName,
    required DateTime completionTime,
    String notificationTitle = 'Timer completed!',
    String notificationBodySuffix = 'is ready!',
    String channelName = 'Kitchen Timer',
    String channelDescription = 'Notifications for completed kitchen timers',
  }) async {
    // Non schedulare se la data è già passata
    if (completionTime.isBefore(DateTime.now())) {
      return;
    }

    final int notificationId = timerId.hashCode + 100000;
    final tz.TZDateTime scheduledDate =
    tz.TZDateTime.from(completionTime, tz.local);

    final AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'timer_channel',
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      enableVibration: true,
      enableLights: true,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('alarm'),
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      notificationTitle,
      '$timerName $notificationBodySuffix',
      scheduledDate,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'timer_$timerId',
    );

    log('Timer notification scheduled: $timerName '
        'for $scheduledDate (ID: $notificationId)');
  }

  /// Cancella la notifica di un timer specifico
  Future<void> cancelTimerNotification(String timerId) async {
    final int notificationId = timerId.hashCode + 100000;
    await flutterLocalNotificationsPlugin.cancel(notificationId);
    log('Timer notification cancelled (ID: $notificationId)');
  }

  /// Mostra notifica immediata per timer completato
  Future<void> showTimerCompletedNotification({
    required String timerName,
    String notificationTitle = 'Timer completed!',
    String notificationBodySuffix = 'is ready!',
    String channelName = 'Kitchen Timer',
    String channelDescription = 'Notifications for completed kitchen timers',
  }) async {
    final AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'timer_channel',
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('alarm'),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '⏰ $notificationTitle',
      '$timerName $notificationBodySuffix',
      platformDetails,
    );
  }
}
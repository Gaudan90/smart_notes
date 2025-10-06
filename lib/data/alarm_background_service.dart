import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../states/alarm_model.dart';

class AlarmBackgroundService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    print('Initializing AlarmBackgroundService...');

    // Inizializza timezone
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        print('Notification tapped: ${details.payload}');
        if (details.payload != null) {
          AlarmTriggerManager.triggerAlarm(details.payload!);
        }
      },
    );

    // Crea canale Android - SINTASSI CORRETTA
    const androidChannel = AndroidNotificationChannel(
      'alarm_channel',
      'Allarmi',
      description: 'Sveglie con apertura automatica',
      importance: Importance.max,
      playSound: false,
      enableVibration: true,
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation
    <AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(androidChannel);
    }

    print('AlarmBackgroundService initialized');
  }

  static Future<void> scheduleAlarm(AlarmModel alarm) async {
    print('\nScheduling alarm: ${alarm.title}');
    print('   ID: ${alarm.id}');
    print('   Time: ${alarm.dateTime}');
    print('   Repeating: ${alarm.isRepeating}');

    if (!alarm.isActive) {
      print('Alarm not active, skipping');
      return;
    }

    if (alarm.isRepeating) {
      if (alarm.repeatDaily) {
        await _scheduleDailyAlarm(alarm);
      } else if (alarm.repeatDays.isNotEmpty) {
        await _scheduleWeeklyAlarm(alarm);
      }
    } else {
      await _scheduleOneShotAlarm(alarm);
    }
  }

  static Future<void> _scheduleOneShotAlarm(AlarmModel alarm) async {
    if (alarm.dateTime.isBefore(DateTime.now())) {
      print('Alarm time in the past');
      return;
    }

    final tzTime = tz.TZDateTime.from(alarm.dateTime, tz.local);
    final secondsUntil = alarm.dateTime.difference(DateTime.now()).inSeconds;
    print('Scheduling in $secondsUntil seconds at $tzTime');

    await _notifications.zonedSchedule(
      alarm.id.hashCode,
      alarm.title,
      'Tocca per aprire',
      tzTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel',
          'Allarmi',
          channelDescription: 'Sveglie',
          importance: Importance.max,
          priority: Priority.max,
          playSound: false,
          enableVibration: true,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          autoCancel: false,
          ongoing: true,
        ),
      ),
      payload: alarm.id,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    print('Alarm scheduled successfully');
  }

  static Future<void> _scheduleDailyAlarm(AlarmModel alarm) async {
    final now = DateTime.now();
    DateTime scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      alarm.dateTime.hour,
      alarm.dateTime.minute,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);
    print('Daily alarm at ${alarm.dateTime.hour}:${alarm.dateTime.minute}');

    await _notifications.zonedSchedule(
      alarm.id.hashCode,
      alarm.title,
      'Tocca per aprire',
      tzTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel',
          'Allarmi',
          importance: Importance.max,
          priority: Priority.max,
          playSound: false,
          enableVibration: true,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          autoCancel: false,
          ongoing: true,
        ),
      ),
      payload: alarm.id,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print('Daily alarm scheduled');
  }

  static Future<void> _scheduleWeeklyAlarm(AlarmModel alarm) async {
    for (int day in alarm.repeatDays) {
      await _notifications.cancel(alarm.id.hashCode + day);
    }

    for (int dayOfWeek in alarm.repeatDays) {
      final now = DateTime.now();
      int daysUntil = (dayOfWeek - now.weekday) % 7;

      if (daysUntil == 0) {
        final nowMinutes = now.hour * 60 + now.minute;
        final alarmMinutes = alarm.dateTime.hour * 60 + alarm.dateTime.minute;
        if (nowMinutes >= alarmMinutes) {
          daysUntil = 7;
        }
      }

      final scheduledDate = now.add(Duration(days: daysUntil));
      final scheduledTime = DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        alarm.dateTime.hour,
        alarm.dateTime.minute,
      );

      final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

      await _notifications.zonedSchedule(
        alarm.id.hashCode + dayOfWeek,
        alarm.title,
        'Tocca per aprire',
        tzTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'alarm_channel',
            'Allarmi',
            importance: Importance.max,
            priority: Priority.max,
            playSound: false,
            enableVibration: true,
            fullScreenIntent: true,
            category: AndroidNotificationCategory.alarm,
            autoCancel: false,
            ongoing: true,
          ),
        ),
        payload: alarm.id,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }

    print('Weekly alarm scheduled for ${alarm.repeatDays.length} days');
  }

  static Future<void> cancelAlarm(String alarmId) async {
    print('Cancelling alarm: $alarmId');
    await _notifications.cancel(alarmId.hashCode);
    for (int i = 1; i <= 7; i++) {
      await _notifications.cancel(alarmId.hashCode + i);
    }
    print('Alarm cancelled');
  }
}

class AlarmTriggerManager {
  static Function(String)? onAlarmTriggered;

  static void triggerAlarm(String alarmId) {
    print('Triggering alarm UI: $alarmId');
    onAlarmTriggered?.call(alarmId);
  }
}
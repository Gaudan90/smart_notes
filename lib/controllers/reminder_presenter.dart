import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/notification_service.dart';
import '../states/reminder_model.dart';

class ReminderPresenter {
  static const String _remindersKey = 'reminders_list';
  final List<ReminderModel> _reminders = [];
  final NotificationService _notificationService = NotificationService();

  List<ReminderModel> get reminders => List.unmodifiable(_reminders);

  Future<void> loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? remindersJson = prefs.getString(_remindersKey);

    if (remindersJson != null) {
      final List<dynamic> decodedList = json.decode(remindersJson);
      _reminders.clear();
      _reminders.addAll(
        decodedList.map((item) => ReminderModel.fromJson(item)).toList(),
      );
    }
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = json.encode(
      _reminders.map((reminder) => reminder.toJson()).toList(),
    );
    await prefs.setString(_remindersKey, encodedList);
  }

  List<String> generateScheduledTimes(String startTime, int intervalHours) {
    List<String> times = [];

    final parts = startTime.split(':');
    if (parts.length != 2) return times;

    int startHour = int.tryParse(parts[0]) ?? 0;
    int startMinute = int.tryParse(parts[1]) ?? 0;

    for (int i = 0; i < 24; i += intervalHours) {
      int hour = (startHour + i) % 24;
      String timeString = '${hour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
      times.add(timeString);

      if (i > 0 && hour < intervalHours) break;
    }

    return times;
  }

  /// Aggiunge un promemoria
  /// [notificationTitle] e [notificationBody] sono le stringhe tradotte per le notifiche
  /// Es: notificationTitle = 'notif_reminder_title'.tr(namedArgs: {'title': title})
  Future<void> addReminder({
    required String title,
    required int intervalHours,
    required String startTime,
    String? notificationTitle,
    String? notificationBody,
    String? channelName,
    String? channelDescription,
  }) async {
    if (title.trim().isEmpty || intervalHours <= 0) return;

    final scheduledTimes = generateScheduledTimes(startTime, intervalHours);

    final reminder = ReminderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      intervalHours: intervalHours,
      startTime: startTime,
      scheduledTimes: scheduledTimes,
    );

    _reminders.add(reminder);
    await _saveReminders();

    // Schedula le notifiche
    await _notificationService.scheduleMultipleDaily(
      reminderId: reminder.id,
      title: reminder.title,
      times: reminder.scheduledTimes,
      notificationTitle: notificationTitle,
      notificationBody: notificationBody,
      channelName: channelName ?? 'Reminders',
      channelDescription: channelDescription ?? 'Channel for daily reminders',
    );
  }

  /// Toggle attivazione con gestione notifiche
  /// [notificationTitle] e [notificationBody] sono le stringhe tradotte per le notifiche
  Future<void> toggleReminder(
      String id, {
        String? notificationTitle,
        String? notificationBody,
        String? channelName,
        String? channelDescription,
      }) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      final reminder = _reminders[index];
      final newState = !reminder.isActive;

      _reminders[index] = reminder.copyWith(isActive: newState);
      await _saveReminders();

      if (newState) {
        // Riattiva notifiche
        await _notificationService.scheduleMultipleDaily(
          reminderId: reminder.id,
          title: reminder.title,
          times: reminder.scheduledTimes,
          notificationTitle: notificationTitle,
          notificationBody: notificationBody,
          channelName: channelName ?? 'Reminders',
          channelDescription: channelDescription ?? 'Channel for daily reminders',
        );
      } else {
        // Cancella notifiche
        await _notificationService.cancelReminder(reminder.id);
      }
    }
  }

  Future<void> deleteReminder(String id) async {
    await _notificationService.cancelReminder(id);
    _reminders.removeWhere((r) => r.id == id);
    await _saveReminders();
  }

  Future<void> updateReminder({
    required String id,
    required String title,
    required int intervalHours,
    required String startTime,
  }) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      final scheduledTimes = generateScheduledTimes(startTime, intervalHours);
      _reminders[index] = _reminders[index].copyWith(
        title: title,
        intervalHours: intervalHours,
        startTime: startTime,
        scheduledTimes: scheduledTimes,
      );
      await _saveReminders();
    }
  }

  List<ReminderModel> getActiveRemindersForTime(String currentTime) {
    return _reminders.where((reminder) {
      return reminder.isActive &&
          reminder.scheduledTimes.contains(currentTime);
    }).toList();
  }

  /// Rischedula tutte le notifiche
  /// [getNotificationTitle] e [getNotificationBody] sono funzioni che generano le stringhe tradotte
  Future<void> rescheduleAllNotifications({
    String Function(String title)? getNotificationTitle,
    String Function(String title)? getNotificationBody,
    String? channelName,
    String? channelDescription,
  }) async {
    for (final reminder in _reminders) {
      if (reminder.isActive) {
        await _notificationService.scheduleMultipleDaily(
          reminderId: reminder.id,
          title: reminder.title,
          times: reminder.scheduledTimes,
          notificationTitle: getNotificationTitle?.call(reminder.title),
          notificationBody: getNotificationBody?.call(reminder.title),
          channelName: channelName ?? 'Reminders',
          channelDescription: channelDescription ?? 'Channel for daily reminders',
        );
      }
    }
  }
}
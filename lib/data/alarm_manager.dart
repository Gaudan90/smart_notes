import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../states/alarm_model.dart';

class AlarmManager {
  static const String _alarmsKey = 'alarms_list';
  final List<AlarmModel> _alarms = [];

  List<AlarmModel> get alarms => List.unmodifiable(_alarms);

  Future<void> loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final String? alarmsJson = prefs.getString(_alarmsKey);

    if (alarmsJson != null) {
      final List<dynamic> decodedList = json.decode(alarmsJson);
      _alarms.clear();
      _alarms.addAll(
        decodedList.map((item) => AlarmModel.fromJson(item)).toList(),
      );
      _sortAlarms();
    }
  }

  Future<void> saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = json.encode(
      _alarms.map((alarm) => alarm.toJson()).toList(),
    );
    await prefs.setString(_alarmsKey, encodedList);
  }

  void _sortAlarms() {
    _alarms.sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  DateTime getSmartAlarmTime(DateTime selectedDateTime) {
    final now = DateTime.now();

    if (selectedDateTime.isBefore(now)) {
      return DateTime(
        now.year,
        now.month,
        now.day,
        selectedDateTime.hour,
        selectedDateTime.minute,
      ).add(const Duration(days: 1));
    }

    return selectedDateTime;
  }

  Future<void> addAlarm({
    required String title,
    required DateTime dateTime,
  }) async {
    if (title.trim().isEmpty) return;

    final smartDateTime = getSmartAlarmTime(dateTime);

    final alarm = AlarmModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      dateTime: smartDateTime,
    );

    _alarms.add(alarm);
    _sortAlarms();
    await saveAlarms();
  }

  Future<void> toggleAlarm(String id) async {
    final index = _alarms.indexWhere((a) => a.id == id);
    if (index != -1) {
      final alarm = _alarms[index];
      _alarms[index] = alarm.copyWith(isActive: !alarm.isActive);
      await saveAlarms();
    }
  }

  Future<void> deleteAlarm(String id) async {
    _alarms.removeWhere((a) => a.id == id);
    await saveAlarms();
  }

  AlarmModel? getNextActiveAlarm() {
    final now = DateTime.now();

    for (var alarm in _alarms) {
      if (alarm.isActive && alarm.dateTime.isAfter(now)) {
        return alarm;
      }
    }

    return null;
  }

  List<AlarmModel> getAlarmsToTrigger() {
    final now = DateTime.now();
    final triggered = <AlarmModel>[];

    for (var alarm in _alarms) {
      if (!alarm.isActive) continue;

      if (alarm.dateTime.year == now.year &&
          alarm.dateTime.month == now.month &&
          alarm.dateTime.day == now.day &&
          alarm.dateTime.hour == now.hour &&
          alarm.dateTime.minute == now.minute &&
          now.second < 30) {
        triggered.add(alarm);
      }
    }

    return triggered;
  }
}
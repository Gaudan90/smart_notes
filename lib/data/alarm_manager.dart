import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../states/alarm_model.dart';
import '../data/alarm_background_service.dart';

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

  // Funzione smart per gestire date passate
  DateTime getSmartAlarmTime(DateTime selectedDateTime) {
    final now = DateTime.now();

    // Se l'orario è già passato oggi, proponi domani
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
    bool isRepeating = false,
    List<int> repeatDays = const [],
    bool repeatDaily = false,
  }) async {
    if (title.trim().isEmpty) return;

    final smartDateTime = isRepeating ? dateTime : getSmartAlarmTime(dateTime);

    final alarm = AlarmModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      dateTime: smartDateTime,
      isRepeating: isRepeating,
      repeatDays: repeatDays,
      repeatDaily: repeatDaily,
    );

    _alarms.add(alarm);
    _sortAlarms();
    await saveAlarms();

    // Schedula con AlarmManager
    await AlarmBackgroundService.scheduleAlarm(alarm);
  }

  Future<void> toggleAlarm(String id) async {
    final index = _alarms.indexWhere((a) => a.id == id);
    if (index != -1) {
      final alarm = _alarms[index];
      _alarms[index] = alarm.copyWith(isActive: !alarm.isActive);
      await saveAlarms();

      if (_alarms[index].isActive) {
        // Riattiva
        await AlarmBackgroundService.scheduleAlarm(_alarms[index]);
      } else {
        // Disattiva
        await AlarmBackgroundService.cancelAlarm(id);
      }
    }
  }

  Future<void> deleteAlarm(String id) async {
    await AlarmBackgroundService.cancelAlarm(id);
    _alarms.removeWhere((a) => a.id == id);
    await saveAlarms();
  }

  // Snooze di una sveglia
  Future<void> snoozeAlarm(String id, int minutes) async {
    final alarm = _alarms.firstWhere((a) => a.id == id);

    // Crea una sveglia temporanea per lo snooze
    final snoozeAlarm = AlarmModel(
      id: 'snooze_${DateTime.now().millisecondsSinceEpoch}',
      title: '${alarm.title} (Posticipata)',
      dateTime: DateTime.now().add(Duration(minutes: minutes)),
      isActive: true,
      isRepeating: false,
    );

    _alarms.add(snoozeAlarm);
    await saveAlarms();
    await AlarmBackgroundService.scheduleAlarm(snoozeAlarm);
  }

  // Trova la prossima sveglia attiva
  AlarmModel? getNextActiveAlarm() {
    final now = DateTime.now();
    AlarmModel? nextAlarm;
    DateTime? nextTime;

    for (var alarm in _alarms) {
      if (!alarm.isActive) continue;

      final occurrence = alarm.isRepeating
          ? alarm.getNextOccurrence()
          : (alarm.dateTime.isAfter(now) ? alarm.dateTime : null);

      if (occurrence != null) {
        if (nextTime == null || occurrence.isBefore(nextTime)) {
          nextTime = occurrence;
          nextAlarm = alarm;
        }
      }
    }

    return nextAlarm;
  }

  // Trova un allarme per ID
  AlarmModel? getAlarmById(String id) {
    try {
      return _alarms.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  // Dopo che una sveglia ripetuta è suonata, rischedulala
  Future<void> rescheduleRepeatingAlarm(String id) async {
    final alarm = getAlarmById(id);
    if (alarm != null && alarm.isRepeating) {
      await AlarmBackgroundService.scheduleAlarm(alarm);
    }
  }
}
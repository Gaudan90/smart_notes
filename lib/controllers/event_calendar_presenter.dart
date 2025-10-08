import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../states/event_model.dart';
import '../states/event_occurrence_model.dart';

class EventCalendarPresenter {
  static const String _eventsKey = 'calendar_events_list';
  final List<EventModel> _events = [];

  List<EventModel> get events => List.unmodifiable(_events);

  Future<void> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? eventsJson = prefs.getString(_eventsKey);

    if (eventsJson != null) {
      final List<dynamic> decodedList = json.decode(eventsJson);
      _events.clear();
      _events.addAll(
        decodedList.map((item) => EventModel.fromJson(item)).toList(),
      );
      _events.sort((a, b) => a.startDate.compareTo(b.startDate));
    }
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = json.encode(
      _events.map((event) => event.toJson()).toList(),
    );
    await prefs.setString(_eventsKey, encodedList);
  }

  Future<void> addEvent({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required RecurrenceType recurrenceType,
    int interval = 1,
    List<int> weekDays = const [],
    int? occurrences,
  }) async {
    if (title.trim().isEmpty) return;

    final event = EventModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      description: description.trim(),
      startDate: startDate,
      endDate: endDate,
      recurrenceType: recurrenceType,
      interval: interval,
      weekDays: weekDays,
      occurrences: occurrences,
    );

    _events.add(event);
    _events.sort((a, b) => a.startDate.compareTo(b.startDate));
    await _saveEvents();
  }

  Future<void> deleteEvent(String id) async {
    _events.removeWhere((event) => event.id == id);
    await _saveEvents();
  }

  List<EventOccurrence> generateOccurrences(EventModel event) {
    final List<EventOccurrence> occurrences = [];

    switch (event.recurrenceType) {
      case RecurrenceType.once:
        occurrences.add(EventOccurrence(
          eventId: event.id,
          eventTitle: event.title,
          date: event.startDate,
          occurrenceNumber: 1,
        ));
        break;

      case RecurrenceType.daily:
        occurrences.addAll(_generateDailyOccurrences(event));
        break;

      case RecurrenceType.weekly:
        occurrences.addAll(_generateWeeklyOccurrences(event));
        break;

      case RecurrenceType.monthly:
        occurrences.addAll(_generateMonthlyOccurrences(event));
        break;
    }

    return occurrences;
  }

  List<EventOccurrence> _generateDailyOccurrences(EventModel event) {
    final List<EventOccurrence> occurrences = [];
    DateTime currentDate = event.startDate;
    int occurrenceCount = 1;

    while (currentDate.isBefore(event.endDate) ||
        _isSameDay(currentDate, event.endDate)) {

      if (event.occurrences != null && occurrenceCount > event.occurrences!) {
        break;
      }

      occurrences.add(EventOccurrence(
        eventId: event.id,
        eventTitle: event.title,
        date: currentDate,
        occurrenceNumber: occurrenceCount,
      ));

      currentDate = currentDate.add(Duration(days: event.interval ?? 1));
      occurrenceCount++;
    }

    return occurrences;
  }

  List<EventOccurrence> _generateWeeklyOccurrences(EventModel event) {
    final List<EventOccurrence> occurrences = [];
    DateTime currentDate = event.startDate;
    int occurrenceCount = 1;

    final selectedDays = event.weekDays.isEmpty
        ? [event.startDate.weekday]
        : event.weekDays;

    while (currentDate.isBefore(event.endDate) ||
        _isSameDay(currentDate, event.endDate)) {

      if (event.occurrences != null && occurrenceCount > event.occurrences!) {
        break;
      }

      if (selectedDays.contains(currentDate.weekday)) {
        occurrences.add(EventOccurrence(
          eventId: event.id,
          eventTitle: event.title,
          date: currentDate,
          occurrenceNumber: occurrenceCount,
        ));
        occurrenceCount++;
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    return occurrences;
  }

  List<EventOccurrence> _generateMonthlyOccurrences(EventModel event) {
    final List<EventOccurrence> occurrences = [];
    DateTime currentDate = event.startDate;
    int occurrenceCount = 1;
    final dayOfMonth = event.startDate.day;

    while (currentDate.isBefore(event.endDate) ||
        _isSameDay(currentDate, event.endDate)) {

      if (event.occurrences != null && occurrenceCount > event.occurrences!) {
        break;
      }

      occurrences.add(EventOccurrence(
        eventId: event.id,
        eventTitle: event.title,
        date: currentDate,
        occurrenceNumber: occurrenceCount,
      ));

      int newMonth = currentDate.month + (event.interval ?? 1);
      int newYear = currentDate.year;

      while (newMonth > 12) {
        newMonth -= 12;
        newYear++;
      }

      int newDay = dayOfMonth;
      final daysInNewMonth = _daysInMonth(newYear, newMonth);
      if (newDay > daysInNewMonth) {
        newDay = daysInNewMonth;
      }

      currentDate = DateTime(newYear, newMonth, newDay);
      occurrenceCount++;
    }

    return occurrences;
  }

  List<EventOccurrence> getAllUpcomingOccurrences() {
    final List<EventOccurrence> allOccurrences = [];
    final now = DateTime.now();

    for (var event in _events) {
      final occurrences = generateOccurrences(event);

      final futureOccurrences = occurrences.where((occ) {
        return occ.date.isAfter(now) || _isSameDay(occ.date, now);
      }).toList();

      allOccurrences.addAll(futureOccurrences);
    }

    allOccurrences.sort((a, b) => a.date.compareTo(b.date));

    return allOccurrences;
  }

  Map<int, List<EventOccurrence>> getOccurrencesByMonth(int year, int month) {
    final Map<int, List<EventOccurrence>> occurrencesByDay = {};

    for (var event in _events) {
      final occurrences = generateOccurrences(event);

      for (var occ in occurrences) {
        if (occ.date.year == year && occ.date.month == month) {
          final day = occ.date.day;
          occurrencesByDay[day] = occurrencesByDay[day] ?? [];
          occurrencesByDay[day]!.add(occ);
        }
      }
    }

    return occurrencesByDay;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int _daysInMonth(int year, int month) {
    final firstDayOfNextMonth = (month < 12)
        ? DateTime(year, month + 1, 1)
        : DateTime(year + 1, 1, 1);
    return firstDayOfNextMonth.subtract(const Duration(days: 1)).day;
  }

  int getTotalOccurrencesForEvent(String eventId) {
    final event = _events.firstWhere((e) => e.id == eventId);
    return generateOccurrences(event).length;
  }

  EventOccurrence? getNextOccurrence(String eventId) {
    final event = _events.firstWhere((e) => e.id == eventId);
    final occurrences = generateOccurrences(event);
    final now = DateTime.now();

    for (var occ in occurrences) {
      if (occ.date.isAfter(now)) {
        return occ;
      }
    }

    return null;
  }
}
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../states/habit_model.dart';
import '../states/habit_stats_model.dart';

class HabitTrackerPresenter {
  static const String _habitsKey = 'habits_tracker_list';
  final List<HabitModel> _habits = [];

  List<HabitModel> get habits => List.unmodifiable(_habits);

  static const List<Color> defaultColors = [
    Color(0xFF1976D2),
    Color(0xFF388E3C),
    Color(0xFFE64A19),
    Color(0xFF5E35B1),
    Color(0xFFD81B60),
    Color(0xFF00796B),
    Color(0xFFF57C00),
    Color(0xFFC62828),
  ];


  List<String> getWeekdayHeaders() {
    final List<String> headers = [];

    // DateTime(2024, 1, 1) = Lunedì
    final baseMonday = DateTime(2024, 1, 1);

    for (int i = 0; i < 7; i++) {
      final day = baseMonday.add(Duration(days: i));
      // Usa locale del sistema (NO forzatura!)
      final weekdayName = DateFormat.E().format(day);
      // Prendi solo prima lettera maiuscola
      headers.add(weekdayName[0].toUpperCase());
    }

    return headers;
  }

  int getFirstDayOffset(int year, int month) {
    final firstDayOfMonth = DateTime(year, month, 1);
    return firstDayOfMonth.weekday - 1;
  }

  Future<void> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final String? habitsJson = prefs.getString(_habitsKey);

    if (habitsJson != null) {
      final List<dynamic> decodedList = json.decode(habitsJson);
      _habits.clear();
      _habits.addAll(
        decodedList.map((item) => HabitModel.fromJson(item)).toList(),
      );
    }
  }

  Future<void> _saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = json.encode(
      _habits.map((habit) => habit.toJson()).toList(),
    );
    await prefs.setString(_habitsKey, encodedList);
  }

  Future<void> addHabit({
    required String name,
    required String description,
    required Color color,
  }) async {
    if (name.trim().isEmpty) return;

    final habit = HabitModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      description: description.trim(),
      color: color,
      createdAt: DateTime.now(),
    );

    _habits.add(habit);
    await _saveHabits();
  }

  Future<void> deleteHabit(String id) async {
    _habits.removeWhere((habit) => habit.id == id);
    await _saveHabits();
  }

  Future<void> toggleDay(String habitId, int year, int month, int day) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index != -1) {
      _habits[index].toggleDay(year, month, day);
      await _saveHabits();
    }
  }

  HabitStats calculateMonthStats(HabitModel habit, int year, int month) {
    final totalDaysInMonth = _getDaysInMonth(year, month);
    final List<int> allDaysInMonth = _generateDaysSequence(totalDaysInMonth);

    final List<int> completedDays = habit.getCompletedDaysForMonth(year, month);

    final List<int> missingDays = _findMissingDays(allDaysInMonth, completedDays);

    final currentStreak = _calculateCurrentStreak(completedDays, year, month);
    final longestStreak = _calculateLongestStreak(completedDays);

    final completionPercentage = totalDaysInMonth > 0
        ? (completedDays.length / totalDaysInMonth) * 100
        : 0.0;

    return HabitStats(
      totalDaysInMonth: totalDaysInMonth,
      completedDays: completedDays,
      missingDays: missingDays,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      completionPercentage: completionPercentage,
    );
  }

  List<int> _generateDaysSequence(int totalDays) {
    final List<int> days = [];
    for (int i = 1; i <= totalDays; i++) {
      days.add(i);
    }
    return days;
  }

  List<int> _findMissingDays(List<int> allDays, List<int> completedDays) {
    final List<int> missing = [];

    for (int day in allDays) {
      if (!completedDays.contains(day)) {
        missing.add(day);
      }
    }

    return missing;
  }

  int _calculateCurrentStreak(List<int> completedDays, int year, int month) {
    if (completedDays.isEmpty) return 0;

    final now = DateTime.now();
    final today = now.day;
    final isCurrentMonth = now.year == year && now.month == month;

    if (!isCurrentMonth) {
      return _countConsecutiveFromEnd(completedDays, _getDaysInMonth(year, month));
    }

    int streak = 0;
    final sortedDays = List<int>.from(completedDays)..sort();

    for (int day = today; day >= 1; day--) {
      if (sortedDays.contains(day)) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  int _calculateLongestStreak(List<int> completedDays) {
    if (completedDays.isEmpty) return 0;

    final sortedDays = List<int>.from(completedDays)..sort();
    int longestStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < sortedDays.length; i++) {
      if (sortedDays[i] == sortedDays[i - 1] + 1) {
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else {
        currentStreak = 1;
      }
    }

    return longestStreak;
  }

  int _countConsecutiveFromEnd(List<int> completedDays, int totalDays) {
    if (completedDays.isEmpty) return 0;

    int streak = 0;
    final sortedDays = List<int>.from(completedDays)..sort();

    for (int day = totalDays; day >= 1; day--) {
      if (sortedDays.contains(day)) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  int _getDaysInMonth(int year, int month) {
    final firstDayOfNextMonth = (month < 12)
        ? DateTime(year, month + 1, 1)
        : DateTime(year + 1, 1, 1);
    return firstDayOfNextMonth.subtract(const Duration(days: 1)).day;
  }

  Map<String, dynamic> getGlobalStats() {
    int totalHabits = _habits.length;
    int totalCompletedDays = 0;

    for (var habit in _habits) {
      totalCompletedDays += habit.totalCompletedDays;
    }

    return {
      'totalHabits': totalHabits,
      'totalCompletedDays': totalCompletedDays,
    };
  }

  List<MapEntry<HabitModel, double>> getTopHabitsThisMonth() {
    final now = DateTime.now();
    final Map<HabitModel, double> habitPerformance = {};

    for (var habit in _habits) {
      final stats = calculateMonthStats(habit, now.year, now.month);
      habitPerformance[habit] = stats.completionPercentage;
    }

    final sortedHabits = habitPerformance.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedHabits;
  }

  bool isTodayCompleted(String habitId) {
    final habit = _habits.firstWhere((h) => h.id == habitId);
    final now = DateTime.now();
    return habit.isDayCompleted(now.year, now.month, now.day);
  }
}
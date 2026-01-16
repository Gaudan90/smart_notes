import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/notification_service.dart';
import '../states/countdown_model.dart';

class CountdownPresenter {
  static const String _countdownsKey = 'countdowns';
  final List<CountdownModel> _countdowns = [];
  final Random _random = Random();
  final NotificationService _notificationService = NotificationService();

  List<CountdownModel> get countdowns => List.unmodifiable(_countdowns);

  String _generateUniqueId() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final randomSuffix = _random.nextInt(999999);
    return '${timestamp}_$randomSuffix';
  }

  Future<void> loadCountdowns() async {
    final prefs = await SharedPreferences.getInstance();
    final String? countdownsJson = prefs.getString(_countdownsKey);

    if (countdownsJson != null) {
      final List<dynamic> decodedList = json.decode(countdownsJson);
      _countdowns.clear();
      _countdowns.addAll(
        decodedList.map((item) => CountdownModel.fromJson(item)).toList(),
      );
      _sortCountdowns();
    }
  }

  Future<void> _saveCountdowns() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = json.encode(
      _countdowns.map((countdown) => countdown.toJson()).toList(),
    );
    await prefs.setString(_countdownsKey, encodedList);
  }

  void _sortCountdowns() {
    _countdowns.sort((a, b) {
      if (a.isExpired && !b.isExpired) return 1;
      if (!a.isExpired && b.isExpired) return -1;

      return a.targetDate.compareTo(b.targetDate);
    });
  }

  // Aggiungi un countdown
  Future<void> addCountdown({
    required String title,
    required DateTime targetDate,
    String? description,
    String? emoji,
  }) async {
    if (title.trim().isEmpty) return;

    final countdown = CountdownModel(
      id: _generateUniqueId(),
      title: title.trim(),
      targetDate: targetDate,
      description: description?.trim(),
      emoji: emoji,
      createdAt: DateTime.now(),
    );

    _countdowns.add(countdown);
    _sortCountdowns();
    await _saveCountdowns();

    await _notificationService.scheduleCountdownNotification(
      countdownId: countdown.id,
      title: countdown.title,
      targetDate: countdown.targetDate,
      description: countdown.description,
    );
  }

  Future<void> updateCountdown({
    required String id,
    required String title,
    required DateTime targetDate,
    String? description,
    String? emoji,
  }) async {
    final index = _countdowns.indexWhere((c) => c.id == id);
    if (index == -1) return;

    _countdowns[index] = _countdowns[index].copyWith(
      title: title.trim(),
      targetDate: targetDate,
      description: description?.trim(),
      emoji: emoji,
      notified: false,
    );

    _sortCountdowns();
    await _saveCountdowns();

    await _notificationService.cancelCountdownNotification(id);
    await _notificationService.scheduleCountdownNotification(
      countdownId: id,
      title: title.trim(),
      targetDate: targetDate,
      description: description?.trim(),
    );
  }

  Future<void> deleteCountdown(String id) async {
    await _notificationService.cancelCountdownNotification(id);

    _countdowns.removeWhere((c) => c.id == id);
    await _saveCountdowns();
  }

  Future<void> deleteExpiredCountdowns() async {
    final expired = _countdowns.where((c) => c.isExpired).toList();
    for (final countdown in expired) {
      await _notificationService.cancelCountdownNotification(countdown.id);
    }

    _countdowns.removeWhere((c) => c.isExpired);
    await _saveCountdowns();
  }

  Future<void> clearAll() async {
    for (final countdown in _countdowns) {
      await _notificationService.cancelCountdownNotification(countdown.id);
    }

    _countdowns.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_countdownsKey);
  }

  List<CountdownModel> getJustExpiredCountdowns() {
    return _countdowns.where((c) => c.isExpired && !c.notified).toList();
  }

  Future<void> markAsNotified(String id) async {
    final index = _countdowns.indexWhere((c) => c.id == id);
    if (index == -1) return;

    _countdowns[index] = _countdowns[index].copyWith(notified: true);
    await _saveCountdowns();
  }

  Future<void> showInAppNotification(CountdownModel countdown) async {
    await _notificationService.showCountdownCompletedNotification(
      title: countdown.title,
      description: countdown.description,
    );
    await markAsNotified(countdown.id);
  }

  Future<void> rescheduleAllNotifications() async {
    for (final countdown in _countdowns) {
      if (!countdown.isExpired) {
        await _notificationService.scheduleCountdownNotification(
          countdownId: countdown.id,
          title: countdown.title,
          targetDate: countdown.targetDate,
          description: countdown.description,
        );
      }
    }
  }

  List<CountdownModel> searchCountdowns(String query) {
    if (query.trim().isEmpty) return _countdowns;

    final lowerQuery = query.toLowerCase();
    return _countdowns.where((countdown) {
      return countdown.title.toLowerCase().contains(lowerQuery) ||
          (countdown.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  List<CountdownModel> getActiveCountdowns() {
    return _countdowns.where((c) => !c.isExpired).toList();
  }

  List<CountdownModel> getExpiredCountdowns() {
    return _countdowns.where((c) => c.isExpired).toList();
  }

  CountdownModel? getCountdownById(String id) {
    try {
      return _countdowns.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  int getTotalDaysUntil(DateTime targetDate) {
    final now = DateTime.now();
    final difference = targetDate.difference(now);
    return difference.inDays;
  }

  String formatTimeRemaining(CountdownModel countdown) {
    if (countdown.isExpired) {
      final daysPassed = -countdown.daysRemaining;
      return daysPassed == 0
          ? 'Scaduto oggi!'
          : 'Scaduto $daysPassed ${daysPassed == 1 ? 'giorno' : 'giorni'} fa';
    }

    final days = countdown.daysRemaining;
    final hours = countdown.hoursRemaining;
    final minutes = countdown.minutesRemaining;
    final seconds = countdown.secondsRemaining;

    if (days > 0) {
      return '$days ${days == 1 ? 'giorno' : 'giorni'}, '
          '$hours ${hours == 1 ? 'ora' : 'ore'}';
    } else if (hours > 0) {
      return '$hours ${hours == 1 ? 'ora' : 'ore'}, '
          '$minutes ${minutes == 1 ? 'minuto' : 'minuti'}';
    } else if (minutes > 0) {
      return '$minutes ${minutes == 1 ? 'minuto' : 'minuti'}, '
          '$seconds ${seconds == 1 ? 'secondo' : 'secondi'}';
    } else {
      return '$seconds ${seconds == 1 ? 'secondo' : 'secondi'}';
    }
  }
}
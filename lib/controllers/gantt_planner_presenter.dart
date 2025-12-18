import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/gantt/gantt_notification_service.dart';
import '../data/gantt/task_filter_enum.dart';
import '../states/gantt_task_model.dart';


class GanttPlannerPresenter {
  static const String _storageKey = 'gantt_tasks';

  List<GanttTaskModel> _tasks = [];
  TaskFilter _currentFilter = TaskFilter.all;

  // ← NUOVO: Notification service
  GanttNotificationService? _notificationService;

  List<GanttTaskModel> get tasks {
    List<GanttTaskModel> filtered = _filterTasks(_tasks);
    _sortTasks(filtered);
    return filtered;
  }

  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((t) => t.completed).length;
  int get activeTasks => _tasks.where((t) =>
  !t.completed && t.daysRemaining >= 0).length;
  int get overdueTasks => _tasks.where((t) =>
  !t.completed && t.daysRemaining < 0).length;

  TaskFilter get currentFilter => _currentFilter;

  Future<void> initializeNotifications
      (FlutterLocalNotificationsPlugin notifications) async {
    _notificationService = GanttNotificationService(notifications);
    await _notificationService!.initialize();

    if (_tasks.isNotEmpty) {
      await _notificationService!.scheduleDailyNotification(_tasks);
    }
  }

  Future<void> loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_storageKey);

      if (data != null) {
        final List<dynamic> jsonList = jsonDecode(data);
        _tasks = jsonList
            .map((json) =>
            GanttTaskModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Errore caricamento task: $e');
      }
      _tasks = [];
    }
  }

  Future<void> _saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String data = jsonEncode(_tasks.map((t) => t.toJson()).toList());
      await prefs.setString(_storageKey, data);

      await _rescheduleNotification();
    } catch (e) {
      if (kDebugMode) {
        print('Errore salvataggio task: $e');
      }
    }
  }

  Future<void> addTask({
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    String? assignedTo,
  }) async {
    if (name.trim().isEmpty) return;

    if (endDate.isBefore(startDate)) {
      throw ArgumentError('La data di fine deve essere dopo la data di inizio');
    }

    final task = GanttTaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      startDate: _normalizeDate(startDate),
      endDate: _normalizeDate(endDate),
      assignedTo: assignedTo?.trim(),
      notificationsEnabled: true,
    );

    _tasks.add(task);
    await _saveTasks();
  }

  Future<void> updateTask({
    required String id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    bool? completed,
    String? assignedTo,
  }) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final oldTask = _tasks[index];

    final newStart = startDate ?? oldTask.startDate;
    final newEnd = endDate ?? oldTask.endDate;
    if (newEnd.isBefore(newStart)) {
      throw ArgumentError('La data di fine deve essere dopo la data di inizio');
    }

    _tasks[index] = oldTask.copyWith(
      name: name,
      startDate: startDate != null ? _normalizeDate(startDate) : null,
      endDate: endDate != null ? _normalizeDate(endDate) : null,
      completed: completed,
      assignedTo: assignedTo,
    );

    await _saveTasks();
  }

  Future<void> toggleTaskCompletion(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    _tasks[index] = _tasks[index].copyWith(
      completed: !_tasks[index].completed,
    );

    await _saveTasks();
  }

  Future<void> toggleTaskNotifications(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    _tasks[index] = _tasks[index].copyWith(
      notificationsEnabled: !_tasks[index].notificationsEnabled,
    );

    await _saveTasks();
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _saveTasks();
  }


  void _sortTasks(List<GanttTaskModel> tasks) {
    tasks.sort((a, b) {
      if (a.completed != b.completed) {
        return a.completed ? 1 : -1;
      }

      if (a.completed && b.completed) {
        return b.endDate.compareTo(a.endDate);
      }

      final dateCompare = a.endDate.compareTo(b.endDate);
      if (dateCompare != 0) return dateCompare;

      return a.startDate.compareTo(b.startDate);
    });
  }

  List<GanttTaskModel> _filterTasks(List<GanttTaskModel> tasks) {
    switch (_currentFilter) {
      case TaskFilter.all:
        return tasks;
      case TaskFilter.active:
        return tasks.where((t) =>
        !t.completed && t.daysRemaining >= 0).toList();
      case TaskFilter.overdue:
        return tasks.where((t) => !t.completed && t.daysRemaining < 0).toList();
      case TaskFilter.completed:
        return tasks.where((t) => t.completed).toList();
    }
  }

  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  GanttTaskModel? getTaskById(String id) {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  List<String> get assignedPeople {
    final Set<String> people = {};
    for (final task in _tasks) {
      if (task.assignedTo != null && task.assignedTo!.isNotEmpty) {
        people.add(task.assignedTo!);
      }
    }
    return people.toList()..sort();
  }

  Future<void> _rescheduleNotification() async {
    if (_notificationService != null) {
      await _notificationService!.rescheduleNotification(_tasks);
    }
  }
}
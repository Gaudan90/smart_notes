import 'package:flutter/material.dart';
import '../data/gantt/task_status_enum.dart';

class GanttTaskModel {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool completed;
  final String? assignedTo;
  final bool notificationsEnabled;

  GanttTaskModel({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.completed = false,
    this.assignedTo,
    this.notificationsEnabled = true,
  });

  int get totalDays {
    return endDate.difference(startDate).inDays;
  }

  int get elapsedDays {
    final now = DateTime.now();
    final elapsed = now.difference(startDate).inDays;
    return elapsed < 0 ? 0 : elapsed;
  }

  int get daysRemaining {
    final now = DateTime.now();
    return endDate.difference(now).inDays;
  }

  double get progressPercentage {
    if (completed) return 1.0;
    if (totalDays <= 0) return 1.0;

    final progress = elapsedDays / totalDays;
    return progress.clamp(0.0, 1.0);
  }

  TaskStatus get status {
    if (completed) return TaskStatus.completed;
    if (daysRemaining < 0) return TaskStatus.overdue;
    if (daysRemaining <= 3) return TaskStatus.urgent;
    return TaskStatus.normal;
  }

  Color get statusColor {
    switch (status) {
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.overdue:
        return Colors.red;
      case TaskStatus.urgent:
        return Colors.orange;
      case TaskStatus.normal:
        return Colors.blue;
    }
  }

  /// Countdown text - usare getLocalizedCountdownText() per versione tradotta
  String get countdownText {
    if (completed) return 'Completed';

    if (daysRemaining < 0) {
      final days = daysRemaining.abs();
      return 'OVERDUE by $days ${days == 1 ? 'day' : 'days'}';
    }

    if (daysRemaining == 0) return 'Expires soon!';

    return '$daysRemaining ${daysRemaining == 1 ? 'day' : 'days'} remaining';
  }

  GanttTaskModel copyWith({
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    bool? completed,
    String? assignedTo,
    bool? notificationsEnabled,
  }) {
    return GanttTaskModel(
      id: id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      completed: completed ?? this.completed,
      assignedTo: assignedTo ?? this.assignedTo,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'completed': completed,
      'assignedTo': assignedTo,
      'notificationsEnabled': notificationsEnabled,
    };
  }


  factory GanttTaskModel.fromJson(Map<String, dynamic> json) {
    return GanttTaskModel(
      id: json['id'] as String,
      name: json['name'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      completed: json['completed'] as bool? ?? false,
      assignedTo: json['assignedTo'] as String?,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
    );
  }

  @override
  String toString() {
    return 'GanttTask(name: $name, progress: '
        '${(progressPercentage * 100).toStringAsFixed(0)}%, status: $status)';
  }
}

extension GanttTaskModelLocalization on GanttTaskModel {
  /// Genera il testo countdown tradotto
  /// Richiede le chiavi: countdown_completed, countdown_overdue,
  /// countdown_expires_soon, countdown_remaining, day_singular, days_plural
  String getLocalizedCountdownText({
    required String completedText,
    required String Function(int days, String dayLabel) overdueText,
    required String expiresSoonText,
    required String Function(int days, String dayLabel) remainingText,
    required String daySingular,
    required String daysPlural,
  }) {
    if (completed) return completedText;

    dayLabel(int count) => count == 1 ? daySingular : daysPlural;

    if (daysRemaining < 0) {
      final days = daysRemaining.abs();
      return overdueText(days, dayLabel(days));
    }

    if (daysRemaining == 0) return expiresSoonText;

    return remainingText(daysRemaining, dayLabel(daysRemaining));
  }
}
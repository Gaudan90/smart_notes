import 'package:flutter/material.dart';

class HabitModel {
  final String id;
  final String name;
  final String description;
  final Color color;
  final DateTime createdAt;
  final Map<String, List<int>> completedDays;

  HabitModel({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.createdAt,
    Map<String, List<int>>? completedDays,
  }) : completedDays = completedDays ?? {};

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color.toARGB32(),
      'createdAt': createdAt.toIso8601String(),
      'completedDays': completedDays,
    };
  }

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> completedDaysJson =
    Map<String, dynamic>.from(json['completedDays'] ?? {});

    final Map<String, List<int>> completedDays = {};
    completedDaysJson.forEach((key, value) {
      completedDays[key] = List<int>.from(value);
    });

    return HabitModel(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      color: Color(json['color']),
      createdAt: DateTime.parse(json['createdAt']),
      completedDays: completedDays,
    );
  }

  HabitModel copyWith({
    String? name,
    String? description,
    Color? color,
    Map<String, List<int>>? completedDays,
  }) {
    return HabitModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      createdAt: createdAt,
      completedDays: completedDays ?? Map.from(this.completedDays),
    );
  }

  List<int> getCompletedDaysForMonth(int year, int month) {
    final key = _getMonthKey(year, month);
    return completedDays[key] ?? [];
  }

  void setCompletedDaysForMonth(int year, int month, List<int> days) {
    final key = _getMonthKey(year, month);
    completedDays[key] = List.from(days)..sort();
  }

  void toggleDay(int year, int month, int day) {
    final key = _getMonthKey(year, month);
    final days = completedDays[key] ?? [];

    if (days.contains(day)) {
      days.remove(day);
    } else {
      days.add(day);
      days.sort();
    }

    completedDays[key] = days;
  }

  bool isDayCompleted(int year, int month, int day) {
    final key = _getMonthKey(year, month);
    final days = completedDays[key] ?? [];
    return days.contains(day);
  }

  String _getMonthKey(int year, int month) {
    return '$year-${month.toString().padLeft(2, '0')}';
  }

  int get totalCompletedDays {
    int total = 0;
    for (var days in completedDays.values) {
      total += days.length;
    }
    return total;
  }
}
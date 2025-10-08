class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final RecurrenceType recurrenceType;
  final int? interval;
  final List<int> weekDays;
  final int? occurrences;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.recurrenceType,
    this.interval = 1,
    this.weekDays = const [],
    this.occurrences,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'recurrenceType': recurrenceType.index,
      'interval': interval,
      'weekDays': weekDays,
      'occurrences': occurrences,
    };
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      recurrenceType: RecurrenceType.values[json['recurrenceType']],
      interval: json['interval'] ?? 1,
      weekDays: List<int>.from(json['weekDays'] ?? []),
      occurrences: json['occurrences'],
    );
  }
}

enum RecurrenceType {
  once,
  daily,
  weekly,
  monthly,
}

extension RecurrenceTypeExtension on RecurrenceType {
  String get displayName {
    switch (this) {
      case RecurrenceType.once:
        return 'Una volta';
      case RecurrenceType.daily:
        return 'Giornaliero';
      case RecurrenceType.weekly:
        return 'Settimanale';
      case RecurrenceType.monthly:
        return 'Mensile';
    }
  }
}
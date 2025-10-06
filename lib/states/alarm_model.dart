class AlarmModel {
  final String id;
  final String title;
  final DateTime dateTime;
  final bool isActive;
  final bool isRepeating;
  final List<int> repeatDays; // 1=Lun, 2=Mar, ... 7=Dom
  final bool repeatDaily; // true = tutti i giorni

  AlarmModel({
    required this.id,
    required this.title,
    required this.dateTime,
    this.isActive = true,
    this.isRepeating = false,
    this.repeatDays = const [],
    this.repeatDaily = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'isActive': isActive,
      'isRepeating': isRepeating,
      'repeatDays': repeatDays,
      'repeatDaily': repeatDaily,
    };
  }

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'],
      title: json['title'],
      dateTime: DateTime.parse(json['dateTime']),
      isActive: json['isActive'] ?? true,
      isRepeating: json['isRepeating'] ?? false,
      repeatDays: List<int>.from(json['repeatDays'] ?? []),
      repeatDaily: json['repeatDaily'] ?? false,
    );
  }

  AlarmModel copyWith({
    String? id,
    String? title,
    DateTime? dateTime,
    bool? isActive,
    bool? isRepeating,
    List<int>? repeatDays,
    bool? repeatDaily,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      isActive: isActive ?? this.isActive,
      isRepeating: isRepeating ?? this.isRepeating,
      repeatDays: repeatDays ?? this.repeatDays,
      repeatDaily: repeatDaily ?? this.repeatDaily,
    );
  }

  // Calcola la prossima occorrenza per sveglie ripetute
  DateTime? getNextOccurrence() {
    final now = DateTime.now();

    if (!isRepeating) {
      // Sveglia singola
      return dateTime.isAfter(now) ? dateTime : null;
    }

    if (repeatDaily) {
      // Tutti i giorni alla stessa ora
      DateTime next = DateTime(
        now.year,
        now.month,
        now.day,
        dateTime.hour,
        dateTime.minute,
      );

      if (next.isBefore(now)) {
        next = next.add(const Duration(days: 1));
      }

      return next;
    }

    // Giorni specifici della settimana
    if (repeatDays.isNotEmpty) {
      for (int i = 0; i < 7; i++) {
        final checkDate = now.add(Duration(days: i));
        if (repeatDays.contains(checkDate.weekday)) {
          final next = DateTime(
            checkDate.year,
            checkDate.month,
            checkDate.day,
            dateTime.hour,
            dateTime.minute,
          );

          if (next.isAfter(now)) {
            return next;
          }
        }
      }
    }

    return null;
  }
}
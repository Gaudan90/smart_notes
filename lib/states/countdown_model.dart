class CountdownModel {
  final String id;
  final String title;
  final DateTime targetDate;
  final String? description;
  final String? emoji;
  final DateTime createdAt;

  CountdownModel({
    required this.id,
    required this.title,
    required this.targetDate,
    this.description,
    this.emoji,
    required this.createdAt,
  });

  Duration get timeRemaining {
    final now = DateTime.now();
    return targetDate.difference(now);
  }

  bool get isExpired => timeRemaining.isNegative;

  int get daysRemaining => timeRemaining.inDays;

  int get hoursRemaining => timeRemaining.inHours % 24;

  int get minutesRemaining => timeRemaining.inMinutes % 60;

  int get secondsRemaining => timeRemaining.inSeconds % 60;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetDate': targetDate.toIso8601String(),
      'description': description,
      'emoji': emoji,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CountdownModel.fromJson(Map<String, dynamic> json) {
    return CountdownModel(
      id: json['id'] as String,
      title: json['title'] as String,
      targetDate: DateTime.parse(json['targetDate'] as String),
      description: json['description'] as String?,
      emoji: json['emoji'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  CountdownModel copyWith({
    String? title,
    DateTime? targetDate,
    String? description,
    String? emoji,
  }) {
    return CountdownModel(
      id: id,
      title: title ?? this.title,
      targetDate: targetDate ?? this.targetDate,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt,
    );
  }
}
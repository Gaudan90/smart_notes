class AlarmModel {
  final String id;
  final String title;
  final DateTime dateTime;
  final bool isActive;

  AlarmModel({
    required this.id,
    required this.title,
    required this.dateTime,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'],
      title: json['title'],
      dateTime: DateTime.parse(json['dateTime']),
      isActive: json['isActive'] ?? true,
    );
  }

  AlarmModel copyWith({
    String? id,
    String? title,
    DateTime? dateTime,
    bool? isActive,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      isActive: isActive ?? this.isActive,
    );
  }
}
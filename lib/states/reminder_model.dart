class ReminderModel {
  final String id;
  final String title;
  final int intervalHours;
  final String startTime;
  final bool isActive;
  final List<String> scheduledTimes;

  ReminderModel({
    required this.id,
    required this.title,
    required this.intervalHours,
    required this.startTime,
    this.isActive = true,
    List<String>? scheduledTimes,
  }) : scheduledTimes = scheduledTimes ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'intervalHours': intervalHours,
      'startTime': startTime,
      'isActive': isActive,
      'scheduledTimes': scheduledTimes,
    };
  }

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'],
      title: json['title'],
      intervalHours: json['intervalHours'],
      startTime: json['startTime'],
      isActive: json['isActive'] ?? true,
      scheduledTimes: List<String>.from(json['scheduledTimes'] ?? []),
    );
  }

  ReminderModel copyWith({
    String? id,
    String? title,
    int? intervalHours,
    String? startTime,
    bool? isActive,
    List<String>? scheduledTimes,
}) {
    return ReminderModel(
        id: id ?? this.id,
        title: title ?? this.title,
        intervalHours: intervalHours ?? this.intervalHours,
        startTime: startTime ?? this.startTime,
        isActive: isActive ?? this.isActive,
        scheduledTimes: scheduledTimes ?? this.scheduledTimes,
    );
  }
}
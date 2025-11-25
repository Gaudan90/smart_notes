enum TimerState {
  initial,
  running,
  paused,
  completed
}

class KitchenTimerModel {
  final String id;
  final String name;
  final int durationSeconds;
  final int elapsedSeconds;
  final TimerState state;
  final DateTime? startedAt;
  final DateTime? completedAt;

  KitchenTimerModel({
    required this.id,
    required this.name,
    required this.durationSeconds,
    required this.elapsedSeconds,
    required this.state,
    this.startedAt,
    this.completedAt,
  });

  factory KitchenTimerModel.create({
    required String name,
    required int durationSeconds,
  }) {
    return KitchenTimerModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      durationSeconds: durationSeconds,
      elapsedSeconds: 0,
      state: TimerState.initial,
    );
  }

  int get remainingSeconds => durationSeconds - elapsedSeconds;

  double get progress => elapsedSeconds / durationSeconds;

  bool get isCompleted => elapsedSeconds >= durationSeconds;

  String get formattedRemaining {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'durationSeconds': durationSeconds,
      'elapsedSeconds': elapsedSeconds,
      'state': state.name,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory KitchenTimerModel.fromJson(Map<String, dynamic> json) {
    return KitchenTimerModel(
      id: json['id'],
      name: json['name'],
      durationSeconds: json['durationSeconds'],
      elapsedSeconds: json['elapsedSeconds'],
      state: TimerState.values.firstWhere(
            (e) => e.name == json['state'],
        orElse: () => TimerState.initial,
      ),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  KitchenTimerModel copyWith({
    String? id,
    String? name,
    int? durationSeconds,
    int? elapsedSeconds,
    TimerState? state,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return KitchenTimerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      state: state ?? this.state,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

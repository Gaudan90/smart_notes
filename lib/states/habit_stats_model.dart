class HabitStats {
  final int totalDaysInMonth;
  final List<int> completedDays;
  final List<int> missingDays;
  final int currentStreak;
  final int longestStreak;
  final double completionPercentage;

  HabitStats({
    required this.totalDaysInMonth,
    required this.completedDays,
    required this.missingDays,
    required this.currentStreak,
    required this.longestStreak,
    required this.completionPercentage,
  });

  int get completedCount => completedDays.length;
  int get missingCount => missingDays.length;

  bool get isPerfectMonth => missingDays.isEmpty && totalDaysInMonth > 0;

  String get completionText {
    return '$completedCount/$totalDaysInMonth giorni';
  }

  String get percentageText {
    return '${completionPercentage.toStringAsFixed(0)}%';
  }
}
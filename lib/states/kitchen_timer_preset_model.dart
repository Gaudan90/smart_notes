class TimerPreset {
  final String name;
  final int minutes;
  final String emoji;

  const TimerPreset({
    required this.name,
    required this.minutes,
    required this.emoji,
  });

  static const List<TimerPreset> presets = [
    TimerPreset(name: 'Veloce', minutes: 5, emoji: '⚡'),
    TimerPreset(name: 'Breve', minutes: 10, emoji: '☕'),
    TimerPreset(name: 'Medio', minutes: 15, emoji: '🍳'),
    TimerPreset(name: 'Standard', minutes: 20, emoji: '⏱️'),
    TimerPreset(name: 'Prolungato', minutes: 25, emoji: '⏳'),
    TimerPreset(name: 'Lungo', minutes: 30, emoji: '📚'),
  ];
}
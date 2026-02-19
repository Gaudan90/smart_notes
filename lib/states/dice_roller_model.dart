class DiceRollModel {
  final int numberOfDice;
  final int diceFaces;
  final List<int> results;
  final int total;
  final DateTime rolledAt;

  DiceRollModel({
    required this.numberOfDice,
    required this.diceFaces,
    required this.results,
    required this.total,
    required this.rolledAt,
  });

  /// Label standard (es. "2d20", "1d6")
  String get diceNotation => '${numberOfDice}d$diceFaces';
}
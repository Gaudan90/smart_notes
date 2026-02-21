/// Modello per un singolo tiro di dadi.
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

  Map<String, dynamic> toJson() => {
    'numberOfDice': numberOfDice,
    'diceFaces': diceFaces,
    'results': results,
    'total': total,
    'rolledAt': rolledAt.toIso8601String(),
  };

  factory DiceRollModel.fromJson(Map<String, dynamic> json) {
    final results = (json['results'] as List).cast<int>();
    return DiceRollModel(
      numberOfDice: json['numberOfDice'] as int,
      diceFaces: json['diceFaces'] as int,
      results: results,
      total: json['total'] as int,
      rolledAt: DateTime.parse(json['rolledAt'] as String),
    );
  }
}
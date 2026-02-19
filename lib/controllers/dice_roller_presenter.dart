import 'dart:math';
import '../states/dice_roller_model.dart';

/// Presenter per il lancio dei dadi.
/// Gestisce la logica di generazione risultati e storico.
class DiceRollerPresenter {
  static const List<int> availableDice = [2, 4, 6, 8, 10, 12, 20, 100];
  static const int maxDiceCount = 20;

  final Random _random = Random();
  final List<DiceRollModel> _history = [];

  List<DiceRollModel> get history => List.unmodifiable(_history);

  /// Lancia [count] dadi da [faces] facce.
  /// Ritorna il modello con risultati singoli e totale.
  DiceRollModel roll({required int count, required int faces}) {
    final results = List.generate(count, (_) => _random.nextInt(faces) + 1);
    final total = results.fold(0, (sum, val) => sum + val);

    final model = DiceRollModel(
      numberOfDice: count,
      diceFaces: faces,
      results: results,
      total: total,
      rolledAt: DateTime.now(),
    );

    _history.insert(0, model);

    // Tiene massimo 50 risultati in cronologia
    if (_history.length > 50) {
      _history.removeLast();
    }

    return model;
  }

  void clearHistory() {
    _history.clear();
  }

  /// Valore minimo possibile per la combinazione dadi.
  int minValue(int count) => count;

  /// Valore massimo possibile per la combinazione dadi.
  int maxValue(int count, int faces) => count * faces;
}
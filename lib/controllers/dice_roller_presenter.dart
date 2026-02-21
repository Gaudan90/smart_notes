import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../states/dice_roller_model.dart';

/// Presenter per il lancio dei dadi.
/// Gestisce logica di generazione, cronologia di sessione e persistente.
class DiceRollerPresenter {
  static const List<int> availableDice = [2, 4, 6, 8, 10, 12, 20, 100];
  static const int maxDiceCount = 20;
  static const String _historyKey = 'dice_roll_history';
  static const int _maxPersistentHistory = 100;

  final Random _random = Random();

  /// Cronologia della sessione corrente (si svuota uscendo dalla schermata).
  final List<DiceRollModel> _sessionHistory = [];

  /// Cronologia persistente salvata in SharedPreferences.
  final List<DiceRollModel> _persistentHistory = [];

  List<DiceRollModel> get sessionHistory =>
      List.unmodifiable(_sessionHistory);

  List<DiceRollModel> get persistentHistory =>
      List.unmodifiable(_persistentHistory);

  /// Carica la cronologia persistente da SharedPreferences.
  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? json = prefs.getString(_historyKey);

    if (json != null) {
      final List<dynamic> decoded = jsonDecode(json);
      _persistentHistory.clear();
      _persistentHistory.addAll(
        decoded.map((item) => DiceRollModel.fromJson(item)).toList(),
      );
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      _persistentHistory.map((roll) => roll.toJson()).toList(),
    );
    await prefs.setString(_historyKey, encoded);
  }

  /// Lancia [count] dadi da [faces] facce.
  /// Salva in entrambe le cronologie.
  Future<DiceRollModel> roll({
    required int count,
    required int faces,
  }) async {
    final results = List.generate(count, (_) => _random.nextInt(faces) + 1);
    final total = results.fold(0, (sum, val) => sum + val);

    final model = DiceRollModel(
      numberOfDice: count,
      diceFaces: faces,
      results: results,
      total: total,
      rolledAt: DateTime.now(),
    );

    // Sessione: max 50
    _sessionHistory.insert(0, model);
    if (_sessionHistory.length > 50) {
      _sessionHistory.removeLast();
    }

    // Persistente: max 100
    _persistentHistory.insert(0, model);
    if (_persistentHistory.length > _maxPersistentHistory) {
      _persistentHistory.removeLast();
    }
    await _saveHistory();

    return model;
  }

  void clearSessionHistory() {
    _sessionHistory.clear();
  }

  Future<void> clearPersistentHistory() async {
    _persistentHistory.clear();
    await _saveHistory();
  }

  int minValue(int count) => count;

  int maxValue(int count, int faces) => count * faces;
}
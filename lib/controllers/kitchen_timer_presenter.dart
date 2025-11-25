import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../states/kitchen_timer_model.dart';

class KitchenTimerPresenter {
  static const String _activeTimersKey = 'active_timers';
  static const String _historyKey = 'timer_history';
  static const int _maxHistorySize = 20;

  final List<KitchenTimerModel> _activeTimers = [];
  final List<KitchenTimerModel> _history = [];
  final Map<String, Timer> _timerInstances = {};
  final Map<String, StreamController<KitchenTimerModel>> _timerControllers = {};

  List<KitchenTimerModel> get activeTimers => List.unmodifiable(_activeTimers);
  List<KitchenTimerModel> get history => List.unmodifiable(_history);

  Stream<KitchenTimerModel> timerStream(String timerId) {
    if (!_timerControllers.containsKey(timerId)) {
      _timerControllers[timerId] = StreamController<KitchenTimerModel>.broadcast();
    }
    return _timerControllers[timerId]!.stream;
  }

  Future<KitchenTimerModel> createTimer({
    required String name,
    required int minutes,
  }) async {
    final timer = KitchenTimerModel.create(
      name: name,
      durationSeconds: minutes * 60,
    );

    _activeTimers.add(timer);
    await _saveActiveTimers();

    return timer;
  }

  void startTimer(String timerId) {
    final index = _activeTimers.indexWhere((t) => t.id == timerId);
    if (index == -1) return;

    var timer = _activeTimers[index];

    if (timer.state == TimerState.running) return;

    timer = timer.copyWith(
      state: TimerState.running,
      startedAt: timer.startedAt ?? DateTime.now(),
    );
    _activeTimers[index] = timer;
    _notifyTimerUpdate(timer);

    _timerInstances[timerId] = Timer.periodic(
      const Duration(seconds: 1),
          (periodicTimer) {
        _tickTimer(timerId, periodicTimer);
      },
    );

    _saveActiveTimers();
  }

  // Tick del timer - esercizio: logica di decremento
  void _tickTimer(String timerId, Timer periodicTimer) {
    final index = _activeTimers.indexWhere((t) => t.id == timerId);
    if (index == -1) {
      periodicTimer.cancel();
      return;
    }

    var timer = _activeTimers[index];

    // Incrementa elapsed (esercizio: logica di conteggio)
    final newElapsed = timer.elapsedSeconds + 1;

    // Check se completato
    if (newElapsed >= timer.durationSeconds) {
      timer = timer.copyWith(
        elapsedSeconds: timer.durationSeconds,
        state: TimerState.completed,
        completedAt: DateTime.now(),
      );

      periodicTimer.cancel();
      _timerInstances.remove(timerId);

      _moveToHistory(timer);

      _notifyTimerUpdate(timer);
    } else {
      timer = timer.copyWith(elapsedSeconds: newElapsed);
      _activeTimers[index] = timer;
      _notifyTimerUpdate(timer);
    }

    _saveActiveTimers();
  }

  // Mette in pausa un timer
  void pauseTimer(String timerId) {
    final index = _activeTimers.indexWhere((t) => t.id == timerId);
    if (index == -1) return;

    _timerInstances[timerId]?.cancel();
    _timerInstances.remove(timerId);

    final timer = _activeTimers[index].copyWith(state: TimerState.paused);
    _activeTimers[index] = timer;
    _notifyTimerUpdate(timer);

    _saveActiveTimers();
  }

  // Resetta un timer
  void resetTimer(String timerId) {
    final index = _activeTimers.indexWhere((t) => t.id == timerId);
    if (index == -1) return;

    _timerInstances[timerId]?.cancel();
    _timerInstances.remove(timerId);

    final timer = _activeTimers[index].copyWith(
      elapsedSeconds: 0,
      state: TimerState.initial,
      startedAt: null,
    );
    _activeTimers[index] = timer;
    _notifyTimerUpdate(timer);

    _saveActiveTimers();
  }

  // Elimina un timer
  Future<void> deleteTimer(String timerId) async {
    _timerInstances[timerId]?.cancel();
    _timerInstances.remove(timerId);

    _timerControllers[timerId]?.close();
    _timerControllers.remove(timerId);

    _activeTimers.removeWhere((t) => t.id == timerId);
    await _saveActiveTimers();
  }

  // Sposta timer completato in cronologia
  void _moveToHistory(KitchenTimerModel timer) {
    _activeTimers.removeWhere((t) => t.id == timer.id);

    _history.insert(0, timer);

    if (_history.length > _maxHistorySize) {
      _history.removeRange(_maxHistorySize, _history.length);
    }

    _saveHistory();
    _saveActiveTimers();
  }

  void _notifyTimerUpdate(KitchenTimerModel timer) {
    if (_timerControllers.containsKey(timer.id)) {
      _timerControllers[timer.id]!.add(timer);
    }
  }

  // Carica timer attivi
  Future<void> loadActiveTimers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timersJson = prefs.getString(_activeTimersKey);

      if (timersJson != null) {
        final List<dynamic> timersList = json.decode(timersJson);
        _activeTimers.clear();
        _activeTimers.addAll(
          timersList.map((item) => KitchenTimerModel.fromJson(item)).toList(),
        );

        for (var timer in _activeTimers) {
          if (timer.state == TimerState.running) {
            final elapsed = DateTime.now().difference(timer.startedAt!).inSeconds;
            final newElapsed = timer.elapsedSeconds + elapsed;

            if (newElapsed >= timer.durationSeconds) {
              _moveToHistory(timer.copyWith(
                elapsedSeconds: timer.durationSeconds,
                state: TimerState.completed,
                completedAt: DateTime.now(),
              ));
            } else {
              final index = _activeTimers.indexOf(timer);
              _activeTimers[index] = timer.copyWith(elapsedSeconds: newElapsed);
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Errore caricamento timer attivi: $e');
      }
      _activeTimers.clear();
    }
  }

  // Salva timer attivi
  Future<void> _saveActiveTimers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timersJson = json.encode(
        _activeTimers.map((t) => t.toJson()).toList(),
      );
      await prefs.setString(_activeTimersKey, timersJson);
    } catch (e) {
      if (kDebugMode) {
        print('Errore salvataggio timer attivi: $e');
      }
    }
  }

  // Carica cronologia
  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);

      if (historyJson != null) {
        final List<dynamic> historyList = json.decode(historyJson);
        _history.clear();
        _history.addAll(
          historyList.map((item) => KitchenTimerModel.fromJson(item)).toList(),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Errore caricamento cronologia timer: $e');
      }
      _history.clear();
    }
  }

  // Salva cronologia
  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = json.encode(
        _history.map((t) => t.toJson()).toList(),
      );
      await prefs.setString(_historyKey, historyJson);
    } catch (e) {
      if (kDebugMode) {
        print('Errore salvataggio cronologia timer: $e');
      }
    }
  }

  // Cancella cronologia
  Future<void> clearHistory() async {
    _history.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  void dispose() {
    // Cancella tutti i timer periodici
    for (var timer in _timerInstances.values) {
      timer.cancel();
    }
    _timerInstances.clear();

    for (var controller in _timerControllers.values) {
      controller.close();
    }
    _timerControllers.clear();
  }
}
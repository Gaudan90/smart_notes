import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../states/kitchen_timer_model.dart';
import '../data/notification_service.dart';

class KitchenTimerPresenter {
  static const String _activeTimersKey = 'active_timers';
  static const String _historyKey = 'timer_history';
  static const int _maxHistorySize = 20;

  final List<KitchenTimerModel> _activeTimers = [];
  final List<KitchenTimerModel> _history = [];
  final Map<String, Timer> _timerInstances = {};
  final Map<String, StreamController<KitchenTimerModel>> _timerControllers = {};
  final NotificationService _notificationService = NotificationService();

  void Function(KitchenTimerModel timer)? onTimerCompleted;

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

    final now = DateTime.now();
    timer = timer.copyWith(
      state: TimerState.running,
      startedAt: timer.startedAt ?? now,
    );
    _activeTimers[index] = timer;
    _notifyTimerUpdate(timer);

    // Calcola quando il timer finirà e schedula la notifica
    final remainingSeconds = timer.durationSeconds - timer.elapsedSeconds;
    final completionTime = now.add(Duration(seconds: remainingSeconds));
    _notificationService.scheduleTimerNotification(
      timerId: timer.id,
      timerName: timer.name,
      completionTime: completionTime,
    );

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

      // Cancella la notifica schedulata (il timer è completato in-app)
      _notificationService.cancelTimerNotification(timerId);

      // Chiama il callback per mostrare overlay/suoneria
      onTimerCompleted?.call(timer);

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

    // Cancella la notifica schedulata
    _notificationService.cancelTimerNotification(timerId);

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

    // Cancella la notifica schedulata
    _notificationService.cancelTimerNotification(timerId);

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

    // Cancella la notifica schedulata
    await _notificationService.cancelTimerNotification(timerId);

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
              // Timer completato mentre app era chiusa
              final completedTimer = timer.copyWith(
                elapsedSeconds: timer.durationSeconds,
                state: TimerState.completed,
                completedAt: DateTime.now(),
              );

              // Cancella la notifica (già mostrata dal sistema)
              await _notificationService.cancelTimerNotification(timer.id);

              // Notifica il completamento per mostrare overlay
              onTimerCompleted?.call(completedTimer);

              _moveToHistory(completedTimer);
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
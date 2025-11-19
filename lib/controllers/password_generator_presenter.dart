import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../states/password_model.dart';

class PasswordGeneratorPresenter {
  static const String _historyKey = 'password_history';
  final List<PasswordModel> _history = [];
  final Random _random = Random.secure();

  // FlutterSecureStorage con opzioni di configurazione
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  List<PasswordModel> get history => List.unmodifiable(_history);

  static const String _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const String _numbers = '0123456789';
  static const String _symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

  Future<void> loadHistory() async {
    // Prima tenta di migrare i dati da SharedPreferences se esistono
    await _migrateFromSharedPreferences();

    // Poi carica dal secure storage
    final String? historyJson = await _secureStorage.read(key: _historyKey);

    if (historyJson != null) {
      try {
        final List<dynamic> decodedList = json.decode(historyJson);
        _history.clear();
        _history.addAll(
          decodedList.map((item) => PasswordModel.fromJson(item)).toList(),
        );
        _history.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
      } catch (e) {
        // In caso di errore di parsing, resetta la cronologia
        _history.clear();
        await _secureStorage.delete(key: _historyKey);
      }
    }
  }

  /// Migra i dati da SharedPreferences a FlutterSecureStorage
  /// Viene eseguita solo una volta
  Future<void> _migrateFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? oldData = prefs.getString(_historyKey);

      if (oldData != null) {
        // Controlla se il secure storage è vuoto
        final String? existingData = await _secureStorage.read(key: _historyKey);

        if (existingData == null) {
          // Migra i dati
          await _secureStorage.write(key: _historyKey, value: oldData);
        }

        // Rimuovi i dati vecchi da SharedPreferences
        await prefs.remove(_historyKey);
      }
    } catch (e) {
      // Se la migrazione fallisce, continua comunque
      // I dati nel secure storage (se esistono) sono prioritari
    }
  }

  Future<void> _saveHistory() async {
    final String encodedList = json.encode(
      _history.map((password) => password.toJson()).toList(),
    );
    await _secureStorage.write(key: _historyKey, value: encodedList);
  }

  PasswordModel generatePassword({
    required int length,
    required bool includeUppercase,
    required bool includeLowercase,
    required bool includeNumbers,
    required bool includeSymbols,
    String? name,
  }) {
    String characterPool = '';
    if (includeUppercase) characterPool += _uppercase;
    if (includeLowercase) characterPool += _lowercase;
    if (includeNumbers) characterPool += _numbers;
    if (includeSymbols) characterPool += _symbols;

    if (characterPool.isEmpty) {
      characterPool = _uppercase + _lowercase + _numbers + _symbols;
    }
    String password = '';
    for (int i = 0; i < length; i++) {
      final randomIndex = _random.nextInt(characterPool.length);
      password += characterPool[randomIndex];
    }

    password = _ensureCharacterTypes(
      password,
      includeUppercase: includeUppercase,
      includeLowercase: includeLowercase,
      includeNumbers: includeNumbers,
      includeSymbols: includeSymbols,
    );

    return PasswordModel(
      password: password,
      length: length,
      hasUppercase: includeUppercase,
      hasLowercase: includeLowercase,
      hasNumbers: includeNumbers,
      hasSymbols: includeSymbols,
      generatedAt: DateTime.now(),
      name: name,
    );
  }

  String _ensureCharacterTypes(
      String password, {
        required bool includeUppercase,
        required bool includeLowercase,
        required bool includeNumbers,
        required bool includeSymbols,
      }) {
    final chars = password.split('');

    if (includeUppercase && !_containsUppercase(password)) {
      final index = _random.nextInt(chars.length);
      chars[index] = _uppercase[_random.nextInt(_uppercase.length)];
    }

    if (includeLowercase && !_containsLowercase(password)) {
      final index = _random.nextInt(chars.length);
      chars[index] = _lowercase[_random.nextInt(_lowercase.length)];
    }

    if (includeNumbers && !_containsNumber(password)) {
      final index = _random.nextInt(chars.length);
      chars[index] = _numbers[_random.nextInt(_numbers.length)];
    }

    if (includeSymbols && !_containsSymbol(password)) {
      final index = _random.nextInt(chars.length);
      chars[index] = _symbols[_random.nextInt(_symbols.length)];
    }

    return chars.join();
  }

  bool _containsUppercase(String password) {
    for (int i = 0; i < password.length; i++) {
      if (_uppercase.contains(password[i])) return true;
    }
    return false;
  }

  bool _containsLowercase(String password) {
    for (int i = 0; i < password.length; i++) {
      if (_lowercase.contains(password[i])) return true;
    }
    return false;
  }

  bool _containsNumber(String password) {
    for (int i = 0; i < password.length; i++) {
      if (_numbers.contains(password[i])) return true;
    }
    return false;
  }

  bool _containsSymbol(String password) {
    for (int i = 0; i < password.length; i++) {
      if (_symbols.contains(password[i])) return true;
    }
    return false;
  }

  Future<void> addToHistory(PasswordModel password) async {
    _history.insert(0, password);

    // Mantiene le ultime 50 password
    if (_history.length > 50) {
      _history.removeRange(50, _history.length);
    }

    await _saveHistory();
  }

  Future<void> clearHistory() async {
    _history.clear();
    await _secureStorage.delete(key: _historyKey);
  }

  Future<void> deleteFromHistory(String password) async {
    _history.removeWhere((p) => p.password == password);
    await _saveHistory();
  }
}
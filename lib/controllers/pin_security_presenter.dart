import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../states/pin_security_model.dart';

class PinSecurityPresenter {
  static const String _securityKey = 'pin_security_data';
  static const String _failedAttemptsKey = 'pin_failed_attempts';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Stato di unlock nella sessione corrente
  bool _isUnlocked = false;
  bool get isUnlocked => _isUnlocked;

  // Domande di sicurezza predefinite
  static const List<String> securityQuestions = [
    'Qual è il nome del tuo primo animale domestico?',
    'In che città sei nato/a?',
    'Qual è la tua squadra preferita?',
    'Qual è il cognome da nubile di tua madre?',
    'Qual è il nome della tua scuola elementare?',
    'Qual è il tuo cibo preferito?',
    'Qual è il nome della tua prima strada?',
    'Qual è il tuo libro preferito?',
    'Qual è il nome del tuo migliore amico d\'infanzia?',
    'Qual è la marca della tua prima auto?',
    'In quale anno hai iniziato le scuole superiori?',
  ];

  /// Controlla se il setup è stato completato
  Future<bool> isSetupComplete() async {
    final data = await _loadSecurityData();
    return data?.isSetupComplete ?? false;
  }

  /// Salva il setup iniziale con PIN e domanda di sicurezza
  Future<void> saveInitialSetup({
    required String pin,
    required String securityQuestion,
    required String answer,
  }) async {
    final pinHash = _hashString(pin);
    final answerHash = _hashString(answer.toLowerCase().trim());

    final model = PinSecurityModel(
      pinHash: pinHash,
      securityQuestion: securityQuestion,
      answerHash: answerHash,
      isSetupComplete: true,
    );

    await _secureStorage.write(
      key: _securityKey,
      value: json.encode(model.toJson()),
    );
    await _secureStorage.write(key: _failedAttemptsKey, value: '0');
    _isUnlocked = true;
  }

  /// Verifica il PIN inserito
  Future<bool> verifyPin(String pin) async {
    final data = await _loadSecurityData();
    if (data == null) return false;

    final inputHash = _hashString(pin);
    final isCorrect = inputHash == data.pinHash;

    if (isCorrect) {
      await _resetFailedAttempts();
      _isUnlocked = true;
    } else {
      await _incrementFailedAttempts();
    }

    return isCorrect;
  }

  /// Verifica la risposta alla domanda di sicurezza
  Future<bool> verifySecurityAnswer(String answer) async {
    final data = await _loadSecurityData();
    if (data == null) return false;

    final inputHash = _hashString(answer.toLowerCase().trim());
    return inputHash == data.answerHash;
  }

  /// Genera un nuovo PIN casuale di 8 cifre
  String generateNewPin() {
    final random = Random.secure();
    String newPin = '';
    for (int i = 0; i < 8; i++) {
      newPin += random.nextInt(10).toString();
    }
    return newPin;
  }

  /// Aggiorna il PIN dopo recovery
  Future<void> updatePin(String newPin) async {
    final data = await _loadSecurityData();
    if (data == null) return;

    final newPinHash = _hashString(newPin);
    final updatedModel = PinSecurityModel(
      pinHash: newPinHash,
      securityQuestion: data.securityQuestion,
      answerHash: data.answerHash,
      isSetupComplete: true,
    );

    await _secureStorage.write(
      key: _securityKey,
      value: json.encode(updatedModel.toJson()),
    );
    await _resetFailedAttempts();
    _isUnlocked = true;
  }

  /// Ottiene la domanda di sicurezza salvata
  Future<String?> getSecurityQuestion() async {
    final data = await _loadSecurityData();
    return data?.securityQuestion;
  }

  /// Ottiene il numero di tentativi falliti
  Future<int> getFailedAttempts() async {
    final attemptsStr = await _secureStorage.read(key: _failedAttemptsKey);
    return int.tryParse(attemptsStr ?? '0') ?? 0;
  }

  /// Controlla se deve mostrare la domanda di sicurezza (3 tentativi falliti)
  Future<bool> shouldShowSecurityQuestion() async {
    final attempts = await getFailedAttempts();
    return attempts >= 3;
  }

  /// Effettua il lock (logout dalla sessione)
  void lock() {
    _isUnlocked = false;
  }

  /// Reset completo (per test o reinstallazione)
  Future<void> resetAll() async {
    await _secureStorage.delete(key: _securityKey);
    await _secureStorage.delete(key: _failedAttemptsKey);
    _isUnlocked = false;
  }

  // === METODI PRIVATI ===

  Future<PinSecurityModel?> _loadSecurityData() async {
    final dataStr = await _secureStorage.read(key: _securityKey);
    if (dataStr == null) return null;

    try {
      final dataJson = json.decode(dataStr);
      return PinSecurityModel.fromJson(dataJson);
    } catch (e) {
      return null;
    }
  }

  Future<void> _incrementFailedAttempts() async {
    final current = await getFailedAttempts();
    await _secureStorage.write(
      key: _failedAttemptsKey,
      value: (current + 1).toString(),
    );
  }

  Future<void> _resetFailedAttempts() async {
    await _secureStorage.write(key: _failedAttemptsKey, value: '0');
  }

  String _hashString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
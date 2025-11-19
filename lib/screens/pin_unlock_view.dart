import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_notes/controllers/pin_security_presenter.dart';

class PinUnlockView extends StatefulWidget {
  const PinUnlockView({super.key});

  @override
  State<PinUnlockView> createState() => _PinUnlockViewState();
}

class _PinUnlockViewState extends State<PinUnlockView> {
  final _pinController = TextEditingController();
  final _answerController = TextEditingController();
  final _manager = PinSecurityPresenter();

  bool _isPinVisible = false;
  bool _isLoading = true;
  bool _showRecovery = false;
  String? _securityQuestion;
  int _failedAttempts = 0;

  @override
  void initState() {
    super.initState();
    _checkRecoveryNeeded();
  }

  Future<void> _checkRecoveryNeeded() async {
    final shouldShow = await _manager.shouldShowSecurityQuestion();
    final attempts = await _manager.getFailedAttempts();

    if (shouldShow) {
      final question = await _manager.getSecurityQuestion();
      setState(() {
        _showRecovery = true;
        _securityQuestion = question;
        _failedAttempts = attempts;
        _isLoading = false;
      });
    } else {
      setState(() {
        _failedAttempts = attempts;
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyPin() async {
    if (_pinController.text.length != 8) {
      _showError('Il PIN deve essere di 8 cifre');
      return;
    }

    setState(() => _isLoading = true);

    final isValid = await _manager.verifyPin(_pinController.text);

    if (isValid) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/password_generator');
      }
    } else {
      final attempts = await _manager.getFailedAttempts();
      setState(() {
        _failedAttempts = attempts;
        _isLoading = false;
      });

      if (attempts >= 3) {
        final question = await _manager.getSecurityQuestion();
        setState(() {
          _showRecovery = true;
          _securityQuestion = question;
        });
        _showError('Troppi tentativi falliti. Rispondi alla domanda di sicurezza.');
      } else {
        _showError('PIN errato. Tentativi rimasti: ${3 - attempts}');
        _pinController.clear();
      }
    }
  }

  Future<void> _verifySecurityAnswer() async {
    if (_answerController.text.trim().isEmpty) {
      _showError('Inserisci la risposta alla domanda di sicurezza');
      return;
    }

    setState(() => _isLoading = true);

    final isValid = await _manager.verifySecurityAnswer(_answerController.text);

    if (isValid) {
      // Genera nuovo PIN
      final newPin = _manager.generateNewPin();
      await _manager.updatePin(newPin);

      if (mounted) {
        await _showNewPinDialog(newPin);
        Navigator.of(context).pushReplacementNamed('/password_generator');
      }
    } else {
      setState(() => _isLoading = false);
      _showError('Risposta errata. Riprova.');
      _answerController.clear();
    }
  }

  Future<void> _showNewPinDialog(String newPin) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Nuovo PIN Generato'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'La tua risposta è corretta! È stato generato un nuovo PIN:',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: SelectableText(
                newPin,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'MEMORIZZA questo PIN. Non verrà mostrato nuovamente.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ho memorizzato il PIN'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sblocca Password'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),

            // Icona
            Icon(
              _showRecovery ? Icons.help_outline : Icons.lock,
              size: 80,
              color: _showRecovery ? Colors.orange : Colors.blue,
            ),
            const SizedBox(height: 24),

            if (!_showRecovery) ...[
              // === SCHERMATA PIN ===
              const Text(
                'Inserisci il PIN',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _failedAttempts > 0
                    ? 'Tentativi falliti: $_failedAttempts/3'
                    : 'Inserisci il tuo PIN di 8 cifre',
                style: TextStyle(
                  fontSize: 15,
                  color: _failedAttempts > 0 ? Colors.red : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              TextField(
                controller: _pinController,
                decoration: InputDecoration(
                  labelText: 'PIN',
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.pin, size: 28),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPinVisible ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _isPinVisible = !_isPinVisible),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                maxLength: 8,
                obscureText: !_isPinVisible,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  letterSpacing: 8,
                  fontWeight: FontWeight.bold,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onSubmitted: (_) => _verifyPin(),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _verifyPin,
                icon: const Icon(Icons.lock_open, size: 24),
                label: const Text(
                  'Sblocca',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ] else ...[
              // === SCHERMATA RECOVERY ===
              const Text(
                'Recupero Accesso',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Hai superato il numero di tentativi.\nRispondi alla domanda di sicurezza.',
                style: TextStyle(fontSize: 15, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Domanda di sicurezza
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Domanda di Sicurezza:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _securityQuestion ?? '',
                      style: const TextStyle(fontSize: 16),
                      softWrap: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              TextField(
                controller: _answerController,
                decoration: InputDecoration(
                  labelText: 'Risposta',
                  hintText: 'Inserisci la tua risposta',
                  prefixIcon: const Icon(Icons.edit),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
                onSubmitted: (_) => _verifySecurityAnswer(),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _verifySecurityAnswer,
                icon: const Icon(Icons.check, size: 24),
                label: const Text(
                  'Verifica e Genera Nuovo PIN',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.orange,
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Info box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _showRecovery
                          ? 'Verrà generato un nuovo PIN casuale'
                          : 'Dopo 3 tentativi falliti, dovrai usare la domanda di sicurezza',
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
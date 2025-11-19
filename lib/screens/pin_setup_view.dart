import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_notes/controllers/pin_security_presenter.dart';

class PinSetupView extends StatefulWidget {
  const PinSetupView({super.key});

  @override
  State<PinSetupView> createState() => _PinSetupViewState();
}

class _PinSetupViewState extends State<PinSetupView> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _answerController = TextEditingController();
  final _manager = PinSecurityPresenter();

  String? _selectedQuestion;
  bool _isPinVisible = false;
  bool _isConfirmPinVisible = false;
  bool _agreedToWarning = false;
  bool _isLoading = false;

  String? _pinError;
  String? _confirmPinError;
  String? _questionError;
  String? _answerError;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() async {
    setState(() {
      _pinError = null;
      _confirmPinError = null;
      _questionError = null;
      _answerError = null;
    });

    bool hasError = false;

    // Valida PIN
    if (_pinController.text.length != 8) {
      setState(() => _pinError = 'Il PIN deve essere di 8 cifre');
      hasError = true;
    } else if (!RegExp(r'^[0-9]+$').hasMatch(_pinController.text)) {
      setState(() => _pinError = 'Il PIN deve contenere solo numeri');
      hasError = true;
    }

    // Valida conferma PIN
    if (_confirmPinController.text != _pinController.text) {
      setState(() => _confirmPinError = 'I PIN non coincidono');
      hasError = true;
    }

    // Valida domanda di sicurezza
    if (_selectedQuestion == null) {
      setState(() => _questionError = 'Seleziona una domanda di sicurezza');
      hasError = true;
    }

    // Valida risposta
    if (_answerController.text.trim().isEmpty) {
      setState(() => _answerError = 'Inserisci una risposta');
      hasError = true;
    } else if (_answerController.text.trim().length < 3) {
      setState(() => _answerError = 'La risposta deve avere almeno 3 caratteri');
      hasError = true;
    }

    // Valida accettazione warning
    if (!_agreedToWarning) {
      _showWarningDialog();
      return;
    }

    if (hasError) return;

    setState(() => _isLoading = true);

    try {
      await _manager.saveInitialSetup(
        pin: _pinController.text,
        securityQuestion: _selectedQuestion!,
        answer: _answerController.text,
      );

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/password_generator');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante il salvataggio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showWarningDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('Importante!'),
          ],
        ),
        content: const Text(
          'Devi accettare di aver letto e compreso l\'avviso prima di procedere.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurazione Sicurezza'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icona e titolo
            const Icon(
              Icons.security,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'Prima configurazione',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Imposta un PIN e una domanda di sicurezza per proteggere le tue password',
              style: TextStyle(fontSize: 15, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Campo PIN
            TextField(
              controller: _pinController,
              decoration: InputDecoration(
                labelText: 'PIN (8 cifre)',
                hintText: 'es. 12345678',
                prefixIcon: const Icon(Icons.pin),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPinVisible ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => _isPinVisible = !_isPinVisible),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: _pinError,
              ),
              keyboardType: TextInputType.number,
              maxLength: 8,
              obscureText: !_isPinVisible,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: 16),

            // Campo conferma PIN
            TextField(
              controller: _confirmPinController,
              decoration: InputDecoration(
                labelText: 'Conferma PIN',
                hintText: 'Reinserisci il PIN',
                prefixIcon: const Icon(Icons.pin),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPinVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _isConfirmPinVisible = !_isConfirmPinVisible),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: _confirmPinError,
              ),
              keyboardType: TextInputType.number,
              maxLength: 8,
              obscureText: !_isConfirmPinVisible,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: 24),

            // Dropdown domanda di sicurezza
            DropdownButtonFormField<String>(
              value: _selectedQuestion,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Domanda di Sicurezza',
                prefixIcon: const Icon(Icons.help_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: _questionError,
              ),
              items: PinSecurityPresenter.securityQuestions.map((question) {
                return DropdownMenuItem(
                  value: question,
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      question,
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedQuestion = value;
                  _questionError = null;
                });
              },
            ),
            const SizedBox(height: 16),

            // Campo risposta
            TextField(
              controller: _answerController,
              decoration: InputDecoration(
                labelText: 'Risposta',
                hintText: 'La tua risposta personale',
                prefixIcon: const Icon(Icons.edit),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: _answerError,
              ),
              textCapitalization: TextCapitalization.words,
              maxLength: 50,
            ),
            const SizedBox(height: 24),

            // Warning Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'AVVISO IMPORTANTE',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• Questa schermata apparirà SOLO UNA VOLTA\n'
                        '• Memorizza PIN e risposta con attenzione\n'
                        '• Dopo 3 tentativi falliti, verrà richiesta la domanda di sicurezza\n'
                        '• La perdita di questi dati richiederà la reinstallazione dell\'app\n'
                        '• Tutte le password generate saranno oscurate fino all\'unlock',
                    style: TextStyle(fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: _agreedToWarning,
                    onChanged: (value) {
                      setState(() => _agreedToWarning = value ?? false);
                    },
                    title: const Text(
                      'Ho letto e compreso l\'avviso',
                      style: TextStyle(fontSize: 14),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pulsante Avanti
            ElevatedButton.icon(
              onPressed: _validateAndSubmit,
              icon: const Icon(Icons.arrow_forward, size: 24),
              label: const Text(
                'Avanti',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: _agreedToWarning ? null : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
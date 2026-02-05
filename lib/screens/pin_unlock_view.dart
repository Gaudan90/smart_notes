import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
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
  String? _securityQuestionKey; // Chiave di traduzione
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
      final questionKey = await _manager.getSecurityQuestionKey();
      setState(() {
        _showRecovery = true;
        _securityQuestionKey = questionKey;
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
      _showError('pin_must_8_digits'.tr());
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
        final questionKey = await _manager.getSecurityQuestionKey();
        setState(() {
          _showRecovery = true;
          _securityQuestionKey = questionKey;
        });
        _showError('too_many_attempts'.tr());
      } else {
        _showError('wrong_pin_attempts'.tr(namedArgs: {'count': '${3 - attempts}'}));
        _pinController.clear();
      }
    }
  }

  Future<void> _verifySecurityAnswer() async {
    if (_answerController.text.trim().isEmpty) {
      _showError('enter_security_answer'.tr());
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
      _showError('wrong_answer_retry'.tr());
      _answerController.clear();
    }
  }

  Future<void> _showNewPinDialog(String newPin) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            Text('new_pin_generated'.tr()),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'answer_correct_new_pin'.tr(),
              style: const TextStyle(fontSize: 15),
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
            Text(
              'memorize_pin_warning'.tr(),
              style: const TextStyle(
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
            child: Text('pin_memorized'.tr()),
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
        title: Text('unlock_passwords'.tr()),
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
              Text(
                'enter_pin'.tr(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _failedAttempts > 0
                    ? 'failed_attempts_count'.tr(namedArgs: {'count': '$_failedAttempts'})
                    : 'enter_8_digit_pin'.tr(),
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
                  labelText: 'pin_label'.tr(),
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
                label: Text(
                  'unlock_btn'.tr(),
                  style: const TextStyle(fontSize: 18),
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
              Text(
                'access_recovery'.tr(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'exceeded_attempts_msg'.tr(),
                style: const TextStyle(fontSize: 15, color: Colors.grey),
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
                    Text(
                      'security_question_label'.tr(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _securityQuestionKey?.tr() ?? '',
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
                  labelText: 'answer_label'.tr(),
                  hintText: 'enter_your_answer'.tr(),
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
                label: Text(
                  'verify_generate_pin'.tr(),
                  style: const TextStyle(fontSize: 16),
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
                          ? 'new_pin_will_generate'.tr()
                          : 'after_3_attempts_info'.tr(),
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
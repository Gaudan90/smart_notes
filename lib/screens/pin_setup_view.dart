import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
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

  String? _selectedQuestionKey; // Chiave di traduzione selezionata
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
      setState(() => _pinError = 'pin_must_8_digits'.tr());
      hasError = true;
    } else if (!RegExp(r'^[0-9]+$').hasMatch(_pinController.text)) {
      setState(() => _pinError = 'pin_only_numbers'.tr());
      hasError = true;
    }

    // Valida conferma PIN
    if (_confirmPinController.text != _pinController.text) {
      setState(() => _confirmPinError = 'pins_not_match'.tr());
      hasError = true;
    }

    // Valida domanda di sicurezza
    if (_selectedQuestionKey == null) {
      setState(() => _questionError = 'select_security_question'.tr());
      hasError = true;
    }

    // Valida risposta
    if (_answerController.text.trim().isEmpty) {
      setState(() => _answerError = 'enter_answer'.tr());
      hasError = true;
    } else if (_answerController.text.trim().length < 3) {
      setState(() => _answerError = 'answer_min_3_chars'.tr());
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
        securityQuestionKey: _selectedQuestionKey!,
        answer: _answerController.text,
      );

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/password_generator');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('save_error'.tr(namedArgs: {'error': '$e'})),
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
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            const SizedBox(width: 8),
            Text('important_title'.tr()),
          ],
        ),
        content: Text(
          'must_accept_warning'.tr(),
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ok_btn'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('security_setup'.tr()),
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
            Text(
              'first_setup'.tr(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'setup_description'.tr(),
              style: const TextStyle(fontSize: 15, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Campo PIN
            TextField(
              controller: _pinController,
              decoration: InputDecoration(
                labelText: 'pin_8_digits'.tr(),
                hintText: 'pin_example'.tr(),
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
                labelText: 'confirm_pin'.tr(),
                hintText: 'reenter_pin'.tr(),
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
              value: _selectedQuestionKey,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'security_question'.tr(),
                prefixIcon: const Icon(Icons.help_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: _questionError,
              ),
              items: PinSecurityPresenter.securityQuestionKeys.map((key) {
                return DropdownMenuItem(
                  value: key,
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      key.tr(), // Traduce la chiave
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedQuestionKey = value;
                  _questionError = null;
                });
              },
            ),
            const SizedBox(height: 16),

            // Campo risposta
            TextField(
              controller: _answerController,
              decoration: InputDecoration(
                labelText: 'answer_label'.tr(),
                hintText: 'your_personal_answer'.tr(),
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
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'important_warning'.tr(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'warning_text'.tr(),
                    style: const TextStyle(fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: _agreedToWarning,
                    onChanged: (value) {
                      setState(() => _agreedToWarning = value ?? false);
                    },
                    title: Text(
                      'read_understood_warning'.tr(),
                      style: const TextStyle(fontSize: 14),
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
              label: Text(
                'next_btn'.tr(),
                style: const TextStyle(fontSize: 18),
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
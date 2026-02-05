import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

// Dialog per inserire il PIN e sbloccare la visualizzazione di una password
class PinUnlockDialog extends StatefulWidget {
  final Future<bool> Function(String pin) onVerifyPin;
  final Future<int> Function() onGetFailedAttempts;

  const PinUnlockDialog({
    super.key,
    required this.onVerifyPin,
    required this.onGetFailedAttempts,
  });

  @override
  State<PinUnlockDialog> createState() => _PinUnlockDialogState();
}

class _PinUnlockDialogState extends State<PinUnlockDialog> {
  final _pinController = TextEditingController();
  bool _isPinVisible = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(BuildContext dialogContext) async {
    if (_pinController.text.length != 8) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('pin_must_be_8'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final isValid = await widget.onVerifyPin(_pinController.text);

    if (isValid) {
      if (dialogContext.mounted) {
        Navigator.pop(dialogContext, 'success');
      }
    } else {
      final attempts = await widget.onGetFailedAttempts();

      if (attempts >= 3) {
        // Troppi tentativi, ritorna codice speciale
        if (dialogContext.mounted) {
          Navigator.pop(dialogContext, 'too_many_attempts');
        }
      } else {
        // Mostra errore e tentativi rimasti
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('wrong_pin_attempts'.tr(namedArgs: {'count': '${3 - attempts}'})),
              backgroundColor: Colors.red,
            ),
          );
        }
        _pinController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.lock_open, color: Colors.blue),
          const SizedBox(width: 8),
          Text('unlock_password'.tr()),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('enter_pin_to_view'.tr()),
            const SizedBox(height: 16),
            TextField(
              controller: _pinController,
              decoration: InputDecoration(
                labelText: 'pin_label'.tr(),
                hintText: '••••••••',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPinVisible ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPinVisible = !_isPinVisible;
                    });
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 8,
              obscureText: !_isPinVisible,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onSubmitted: (_) => _handleSubmit(context),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, 'cancel'),
          child: Text('cancel'.tr()),
        ),
        ElevatedButton(
          onPressed: () => _handleSubmit(context),
          child: Text('unlock_btn'.tr()),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
          const SnackBar(
            content: Text('Il PIN deve essere di 8 cifre'),
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
              content: Text('PIN errato. Tentativi rimasti: ${3 - attempts}'),
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
      title: const Row(
        children: [
          Icon(Icons.lock_open, color: Colors.blue),
          SizedBox(width: 8),
          Text('Sblocca Password'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Inserisci il tuo PIN per visualizzare la password'),
            const SizedBox(height: 16),
            TextField(
              controller: _pinController,
              decoration: InputDecoration(
                labelText: 'PIN',
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
          child: const Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: () => _handleSubmit(context),
          child: const Text('Sblocca'),
        ),
      ],
    );
  }
}
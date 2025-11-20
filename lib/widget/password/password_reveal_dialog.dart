import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// mostra una password sbloccata
class PasswordRevealDialog extends StatelessWidget {
  final String password;
  final VoidCallback? onCopy;

  const PasswordRevealDialog({
    super.key,
    required this.password,
    this.onCopy,
  });

  Future<void> _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: password));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Password copiata negli appunti'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }

    if (onCopy != null) {
      onCopy!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.visibility, color: Colors.green),
          SizedBox(width: 8),
          Text('Password Sbloccata'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: SelectableText(
              password,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              _copyToClipboard(context);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copia'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Chiudi'),
        ),
      ],
    );
  }
}
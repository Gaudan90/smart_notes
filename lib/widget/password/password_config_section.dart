import 'package:flutter/material.dart';

class PasswordConfigSection extends StatelessWidget {
  final double length;
  final bool includeUppercase;
  final bool includeLowercase;
  final bool includeNumbers;
  final bool includeSymbols;
  final ValueChanged<double> onLengthChanged;
  final ValueChanged<bool> onUppercaseChanged;
  final ValueChanged<bool> onLowercaseChanged;
  final ValueChanged<bool> onNumbersChanged;
  final ValueChanged<bool> onSymbolsChanged;

  const PasswordConfigSection({
    super.key,
    required this.length,
    required this.includeUppercase,
    required this.includeLowercase,
    required this.includeNumbers,
    required this.includeSymbols,
    required this.onLengthChanged,
    required this.onUppercaseChanged,
    required this.onLowercaseChanged,
    required this.onNumbersChanged,
    required this.onSymbolsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configurazione',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Lunghezza
            Row(
              children: [
                const Icon(Icons.straighten, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Lunghezza: ${length.toInt()} caratteri',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Slider(
              value: length,
              min: 8,
              max: 32,
              divisions: 24,
              label: length.toInt().toString(),
              onChanged: onLengthChanged,
            ),

            const SizedBox(height: 16),

            // Opzioni
            CheckboxListTile(
              title: const Text('Lettere maiuscole (A-Z)'),
              subtitle: const Text('ABCDEFGHIJKLMNOPQRSTUVWXYZ'),
              value: includeUppercase,
              onChanged: (value) => onUppercaseChanged(value ?? true),
            ),

            CheckboxListTile(
              title: const Text('Lettere minuscole (a-z)'),
              subtitle: const Text('abcdefghijklmnopqrstuvwxyz'),
              value: includeLowercase,
              onChanged: (value) => onLowercaseChanged(value ?? true),
            ),

            CheckboxListTile(
              title: const Text('Numeri (0-9)'),
              subtitle: const Text('0123456789'),
              value: includeNumbers,
              onChanged: (value) => onNumbersChanged(value ?? true),
            ),

            CheckboxListTile(
              title: const Text('Simboli speciali'),
              subtitle: const Text('!@#\$%^&*()_+-=[]{}|;:,.<>?'),
              value: includeSymbols,
              onChanged: (value) => onSymbolsChanged(value ?? true),
            ),
          ],
        ),
      ),
    );
  }
}
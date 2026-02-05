import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

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
              'configuration'.tr(),
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
                  'length_characters'.tr(namedArgs: {'count': '${length.toInt()}'}),
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
              title: Text('uppercase_letters'.tr()),
              subtitle: const Text('ABCDEFGHIJKLMNOPQRSTUVWXYZ'),
              value: includeUppercase,
              onChanged: (value) => onUppercaseChanged(value ?? true),
            ),

            CheckboxListTile(
              title: Text('lowercase_letters'.tr()),
              subtitle: const Text('abcdefghijklmnopqrstuvwxyz'),
              value: includeLowercase,
              onChanged: (value) => onLowercaseChanged(value ?? true),
            ),

            CheckboxListTile(
              title: Text('numbers_option'.tr()),
              subtitle: const Text('0123456789'),
              value: includeNumbers,
              onChanged: (value) => onNumbersChanged(value ?? true),
            ),

            CheckboxListTile(
              title: Text('special_symbols'.tr()),
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
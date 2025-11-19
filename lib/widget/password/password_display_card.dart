import 'package:flutter/material.dart';
import '../../states/password_model.dart';

class PasswordDisplayCard extends StatelessWidget {
  final PasswordModel password;
  final VoidCallback onCopy;

  const PasswordDisplayCard({
    super.key,
    required this.password,
    required this.onCopy,
  });

  Color _getStrengthColor(int strength) {
    if (strength >= 80) return Colors.green;
    if (strength >= 60) return Colors.lightGreen;
    if (strength >= 40) return Colors.orange;
    if (strength >= 20) return Colors.deepOrange;
    return Colors.red;
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      visualDensity: VisualDensity.compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    final strengthColor = _getStrengthColor(password.strength);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lock, color: strengthColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Password Generata',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      password.password,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: onCopy,
                    color: Colors.black54,
                    tooltip: 'Copia',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Forza:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            password.strengthLabel,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: strengthColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: password.strength / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                        minHeight: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildInfoChip(
                  Icons.straighten,
                  '${password.length} caratteri',
                ),
                if (password.hasUppercase)
                  _buildInfoChip(Icons.format_size, 'A-Z'),
                if (password.hasLowercase)
                  _buildInfoChip(Icons.text_fields, 'a-z'),
                if (password.hasNumbers)
                  _buildInfoChip(Icons.numbers, '0-9'),
                if (password.hasSymbols)
                  _buildInfoChip(Icons.security, 'Simboli'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
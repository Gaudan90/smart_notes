import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../states/password_model.dart';
import 'password_helpers.dart';

class PasswordDisplayCard extends StatelessWidget {
  final PasswordModel password;
  final VoidCallback onCopy;
  final bool isLocked;

  const PasswordDisplayCard({
    super.key,
    required this.password,
    required this.onCopy,
    this.isLocked = false,
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

  String _getObscuredPassword() {
    return '•' * password.length;
  }

  @override
  Widget build(BuildContext context) {
    final strengthColor = _getStrengthColor(password.strength);
    final hasName = password.name != null && password.name!.isNotEmpty;
    final displayPassword = isLocked ? _getObscuredPassword() : password.password;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isLocked ? Icons.lock : (hasName ? Icons.label : Icons.lock_open),
                  color: strengthColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasName) ...[
                        Text(
                          password.name!,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'generated_password'.tr(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ] else
                        Text(
                          'generated_password'.tr(),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
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
                      displayPassword,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        letterSpacing: isLocked ? 4 : 1,
                      ),
                    ),
                  ),
                  if (!isLocked)
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: onCopy,
                      color: Colors.black54,
                      tooltip: 'copy_btn'.tr(),
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
                          Text(
                            'strength_label'.tr(),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            PasswordHelpers.translateStrengthLabel(password.strength),
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
                  'characters_count'.tr(namedArgs: {'count': '${password.length}'}),
                ),
                if (password.hasUppercase)
                  _buildInfoChip(Icons.format_size, 'A-Z'),
                if (password.hasLowercase)
                  _buildInfoChip(Icons.text_fields, 'a-z'),
                if (password.hasNumbers)
                  _buildInfoChip(Icons.numbers, '0-9'),
                if (password.hasSymbols)
                  _buildInfoChip(Icons.security, 'symbols_label'.tr()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
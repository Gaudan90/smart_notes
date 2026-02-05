import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../states/password_model.dart';
import 'password_helpers.dart';

class PasswordHistoryItem extends StatelessWidget {
  final PasswordModel password;
  final VoidCallback onCopy;
  final VoidCallback onDelete;
  final bool isLocked;
  final VoidCallback? onUnlock;

  const PasswordHistoryItem({
    super.key,
    required this.password,
    required this.onCopy,
    required this.onDelete,
    this.isLocked = false,
    this.onUnlock,
  });

  Color _getStrengthColor(int strength) {
    if (strength >= 80) return Colors.green;
    if (strength >= 60) return Colors.lightGreen;
    if (strength >= 40) return Colors.orange;
    if (strength >= 20) return Colors.deepOrange;
    return Colors.red;
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
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: strengthColor.withValues(alpha: 0.2),
          child: Icon(
            isLocked ? Icons.lock : (hasName ? Icons.label : Icons.lock_open),
            color: strengthColor,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasName) ...[
              Text(
                password.name!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
            ],
            Text(
              displayPassword,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: hasName ? 13 : 14,
                color: hasName ? Colors.grey[600] : null,
                letterSpacing: isLocked ? 4 : 1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${password.length} ${'characters_count'.tr(namedArgs: {'count': '${password.length}'}).split(' ').last} • ${PasswordHelpers.translateStrengthLabel(password.strength)}',
              style: TextStyle(fontSize: 12, color: strengthColor),
            ),
            Text(
              PasswordHelpers.formatDateTime(password.generatedAt),
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLocked && onUnlock != null) ...[
              IconButton(
                icon: const Icon(Icons.visibility, size: 20),
                onPressed: onUnlock,
                tooltip: 'view_btn'.tr(),
                color: Colors.blue,
              ),
            ] else ...[
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                onPressed: onCopy,
                tooltip: 'copy_btn'.tr(),
              ),
            ],
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              color: Colors.red,
              onPressed: onDelete,
              tooltip: 'delete'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
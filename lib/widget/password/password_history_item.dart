import 'package:flutter/material.dart';
import '../../states/password_model.dart';

class PasswordHistoryItem extends StatelessWidget {
  final PasswordModel password;
  final VoidCallback onCopy;
  final VoidCallback onDelete;

  const PasswordHistoryItem({
    super.key,
    required this.password,
    required this.onCopy,
    required this.onDelete,
  });

  Color _getStrengthColor(int strength) {
    if (strength >= 80) return Colors.green;
    if (strength >= 60) return Colors.lightGreen;
    if (strength >= 40) return Colors.orange;
    if (strength >= 20) return Colors.deepOrange;
    return Colors.red;
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Adesso';
    if (difference.inHours < 1) return '${difference.inMinutes}m fa';
    if (difference.inDays < 1) return '${difference.inHours}h fa';
    if (difference.inDays < 7) return '${difference.inDays}g fa';

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    final strengthColor = _getStrengthColor(password.strength);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: strengthColor.withValues(alpha: 0.2),
          child: Icon(Icons.lock, color: strengthColor),
        ),
        title: Text(
          password.password,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${password.length} caratteri • ${password.strengthLabel}',
              style: TextStyle(fontSize: 12, color: strengthColor),
            ),
            Text(
              _formatDateTime(password.generatedAt),
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.copy, size: 20),
              onPressed: onCopy,
              tooltip: 'Copia',
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              color: Colors.red,
              onPressed: onDelete,
              tooltip: 'Elimina',
            ),
          ],
        ),
      ),
    );
  }
}
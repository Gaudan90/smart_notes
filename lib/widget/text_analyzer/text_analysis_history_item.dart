import 'package:flutter/material.dart';
import '../../states/text_analyzer_model.dart';

class TextAnalysisHistoryItem extends StatelessWidget {
  final TextAnalysisModel analysis;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TextAnalysisHistoryItem({
    super.key,
    required this.analysis,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final preview = analysis.text.length > 100
        ? '${analysis.text.substring(0, 100)}...'
        : analysis.text;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      preview,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    color: Colors.red,
                    onPressed: onDelete,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoChip(
                    '${analysis.wordCount} parole',
                    Icons.format_quote,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    '${analysis.characterCount} caratteri',
                    Icons.text_fields,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _formatDateTime(analysis.analyzedAt),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
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
}
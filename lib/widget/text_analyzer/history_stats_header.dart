import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class HistoryStatsHeader extends StatelessWidget {
  final Map<String, dynamic> stats;
  final VoidCallback onClearAll;

  const HistoryStatsHeader({
    super.key,
    required this.stats,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'history_stats_title'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('confirm'.tr()),
                      content: Text('clear_history_confirm_text'.tr()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('cancel'.tr()),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: Text('delete'.tr()),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    onClearAll();
                  }
                },
                icon: const Icon(Icons.delete_sweep),
                label: Text('clear_all_history_pwd'.tr()),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatChip(
                'stat_analyses'.tr(),
                stats['totalAnalyses'].toString(),
                Colors.blue,
              ),
              _buildStatChip(
                'stat_total_words'.tr(),
                stats['totalWords'].toString(),
                Colors.orange,
              ),
              _buildStatChip(
                'stat_avg_words'.tr(),
                stats['averageWords'].toStringAsFixed(0),
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.2),
        child: Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.1),
    );
  }
}
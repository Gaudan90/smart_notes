import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../states/kitchen_timer_model.dart';

class TimerHistoryTab extends StatelessWidget {
  final List<KitchenTimerModel> history;
  final VoidCallback onClearHistory;

  const TimerHistoryTab({
    super.key,
    required this.history,
    required this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        _buildHeader(context),
        _buildHistoryList(),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            'no_completed_timers'.tr(),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'complete_timer_to_see'.tr(),
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'completed_timers_count'.tr(namedArgs: {'count': '${history.length}'}),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton.icon(
            onPressed: () => _showClearConfirmDialog(context),
            icon: const Icon(Icons.delete_sweep),
            label: Text('clear_all_history'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final timer = history[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green.withValues(alpha: 0.2),
                child: const Icon(Icons.check, color: Colors.green),
              ),
              title: Text(
                timer.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${timer.formattedDuration} • ${_formatDateTime(timer.completedAt!)}',
              ),
              trailing: Icon(
                Icons.timer,
                color: Colors.grey.shade400,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showClearConfirmDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('confirm'.tr()),
        content: Text('clear_history_confirm'.tr()),
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
      onClearHistory();
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'time_now'.tr();
    if (difference.inHours < 1) return 'time_minutes_ago'.tr(namedArgs: {'min': '${difference.inMinutes}'});
    if (difference.inDays < 1) return 'time_hours_ago'.tr(namedArgs: {'hours': '${difference.inHours}'});
    if (difference.inDays < 7) return 'time_days_ago'.tr(namedArgs: {'days': '${difference.inDays}'});

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
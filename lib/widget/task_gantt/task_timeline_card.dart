import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../states/gantt_task_model.dart';

class TaskTimelineCard extends StatelessWidget {
  final GanttTaskModel task;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onToggleNotifications;

  const TaskTimelineCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
    required this.onToggleNotifications,
  });

  String _getLocalizedCountdownText() {
    if (task.completed) return 'countdown_completed'.tr();

    final dayLabel = (int count) => count == 1
        ? 'day_singular'.tr()
        : 'days_plural'.tr();

    if (task.daysRemaining < 0) {
      final days = task.daysRemaining.abs();
      return 'countdown_overdue'.tr(namedArgs: {
        'days': '$days',
        'dayLabel': dayLabel(days),
      });
    }

    if (task.daysRemaining == 0) return 'countdown_expires_soon'.tr();

    return 'countdown_remaining'.tr(namedArgs: {
      'days': '${task.daysRemaining}',
      'dayLabel': dayLabel(task.daysRemaining),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: task.statusColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
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
                  Checkbox(
                    value: task.completed,
                    onChanged: (_) => onToggle(),
                    activeColor: Colors.green,
                  ),
                  Expanded(
                    child: Text(
                      task.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.completed ? Colors.grey : null,
                      ),
                    ),
                  ),
                  // Toggle notifiche
                  IconButton(
                    icon: Icon(
                      task.notificationsEnabled
                          ? Icons.notifications_active
                          : Icons.notifications_off,
                      color: task.notificationsEnabled
                          ? Colors.blue
                          : Colors.grey,
                    ),
                    onPressed: onToggleNotifications,
                    tooltip: task.notificationsEnabled
                        ? 'disable_notifications'.tr()
                        : 'enable_notifications'.tr(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: onDelete,
                    tooltip: 'delete_task'.tr(),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _buildProgressBar(),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(task.progressPercentage * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: task.statusColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: task.statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: task.statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _getLocalizedCountdownText(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: task.statusColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Date
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16,
                      color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatDate(task.startDate)} -> '
                        '${_formatDate(task.endDate)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              if (task.assignedTo != null && task.assignedTo!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      task.assignedTo!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    const int totalBlocks = 10;
    final int filledBlocks = (task.progressPercentage * totalBlocks).round();

    return Row(
      children: List.generate(totalBlocks, (index) {
        final isFilled = index < filledBlocks;
        return Expanded(
          child: Container(
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: isFilled ? task.statusColor : Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM').format(date);
  }
}
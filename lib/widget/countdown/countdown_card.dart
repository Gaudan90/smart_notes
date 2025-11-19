import 'package:flutter/material.dart';
import 'dart:async';
import '../../states/countdown_model.dart';
import 'emoji_icons.dart';

class CountdownCard extends StatefulWidget {
  final CountdownModel countdown;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const CountdownCard({
    super.key,
    required this.countdown,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<CountdownCard> createState() => _CountdownCardState();
}

class _CountdownCardState extends State<CountdownCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor() {
    if (widget.countdown.isExpired) return Colors.grey;

    final days = widget.countdown.daysRemaining;
    if (days <= 1) return Colors.red;
    if (days <= 7) return Colors.orange;
    if (days <= 30) return Colors.blue;
    return Colors.green;
  }

  IconData _getStatusIcon() {
    if (widget.countdown.isExpired) return Icons.check_circle;

    final days = widget.countdown.daysRemaining;
    if (days <= 1) return Icons.warning;
    if (days <= 7) return Icons.notification_important;
    return Icons.access_time;
  }

  @override
  Widget build(BuildContext context) {
    final countdown = widget.countdown;
    final statusColor = _getStatusColor();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: countdown.isExpired ? 1 : 2,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (countdown.emoji != null) ...[
                    Builder(
                      builder: (context) {
                        final icon = EmojiIcons.getIconFromCodePoint(countdown.emoji);
                        if (icon == null) return const SizedBox.shrink();

                        return Icon(
                          icon,
                          size: 32,
                          color: countdown.isExpired
                              ? Colors.grey
                              : Theme.of(context).colorScheme.primary,
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                  ],

                  Expanded(
                    child: Text(
                      countdown.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: countdown.isExpired
                            ? TextDecoration.lineThrough
                            : null,
                        color: countdown.isExpired
                            ? Colors.grey
                            : null,
                      ),
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    color: Colors.red,
                    onPressed: widget.onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                ],
              ),

              if (countdown.description != null &&
                  countdown.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  countdown.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Data target
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(countdown.targetDate),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: countdown.isExpired
                    ? _buildExpiredView(statusColor)
                    : _buildActiveCountdownView(statusColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpiredView(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle, color: color, size: 32),
        const SizedBox(width: 12),
        Text(
          'COMPLETATO!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveCountdownView(Color color) {
    final countdown = widget.countdown;
    final days = countdown.daysRemaining;
    final hours = countdown.hoursRemaining;
    final minutes = countdown.minutesRemaining;
    final seconds = countdown.secondsRemaining;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTimeUnit(days.toString(), 'Giorni', color),
            _buildTimeUnit(hours.toString().padLeft(2, '0'), 'Ore', color),
            _buildTimeUnit(minutes.toString().padLeft(2, '0'), 'Minuti', color),
            _buildTimeUnit(seconds.toString().padLeft(2, '0'), 'Secondi', color),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getStatusIcon(), size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              _getStatusMessage(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeUnit(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getStatusMessage() {
    final days = widget.countdown.daysRemaining;

    if (days == 0) {
      return 'Manca pochissimo!';
    } else if (days == 1) {
      return 'Manca solo 1 giorno! Sii pronto!';
    } else if (days <= 7) {
      return 'Tra $days giorni, ci siamo quasi!';
    } else if (days <= 30) {
      return 'Tra ${(days / 7).ceil()} settimane circa';
    } else {
      return 'Tra ${(days / 30).ceil()} mesi circa';
    }
  }
}
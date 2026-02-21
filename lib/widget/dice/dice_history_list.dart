import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../states/dice_roller_model.dart';

/// Lista scrollabile della cronologia lanci.
/// [showHeader] controlla la visibilità del titolo "History".
class DiceHistoryList extends StatelessWidget {
  final List<DiceRollModel> history;
  final bool showHeader;

  const DiceHistoryList({
    super.key,
    required this.history,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'dice_history'.tr(),
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: history.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final roll = history[index];
              final isFirst = index == 0;
              return ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: isFirst
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
                  child: Text(
                    roll.diceNotation,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isFirst
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                    ),
                  ),
                ),
                title: Text(
                  '${roll.results.join(' + ')} = ${roll.total}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isFirst ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: Text(
                  '${roll.rolledAt.hour.toString().padLeft(2, '0')}:'
                      '${roll.rolledAt.minute.toString().padLeft(2, '0')}:'
                      '${roll.rolledAt.second.toString().padLeft(2, '0')}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
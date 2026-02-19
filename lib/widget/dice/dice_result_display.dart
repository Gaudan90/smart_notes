import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../states/dice_roller_model.dart';

/// Mostra i risultati dei dadi: singoli riquadri + totale.
class DiceResultDisplay extends StatelessWidget {
  final DiceRollModel? lastRoll;
  final List<int> animatingNumbers;
  final int diceFaces;
  final int diceCount;
  final bool isRolling;
  final Animation<double> resultFadeIn;
  final Animation<double> resultScale;

  const DiceResultDisplay({
    super.key,
    required this.lastRoll,
    required this.animatingNumbers,
    required this.diceFaces,
    required this.diceCount,
    required this.isRolling,
    required this.resultFadeIn,
    required this.resultScale,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (lastRoll == null && !isRolling) {
      return _buildPlaceholder(theme, colorScheme);
    }

    final results = animatingNumbers;
    final showTotal = lastRoll != null && !isRolling;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (results.length <= 6)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: results.map((value) {
              return _DieChip(
                value: value,
                diceFaces: diceFaces,
                diceCount: diceCount,
                isRolling: isRolling,
              );
            }).toList(),
          )
        else
          _CompactResults(
            results: results,
            diceFaces: diceFaces,
            isRolling: isRolling,
          ),

        if (showTotal && lastRoll!.numberOfDice > 1) ...[
          const SizedBox(height: 20),
          FadeTransition(
            opacity: resultFadeIn,
            child: ScaleTransition(
              scale: resultScale,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${'dice_total'.tr()} ',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      '${lastRoll!.total}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],

        if (showTotal && lastRoll!.numberOfDice == 1) ...[
          const SizedBox(height: 12),
          FadeTransition(
            opacity: resultFadeIn,
            child: Text(
              lastRoll!.diceNotation,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPlaceholder(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.casino_outlined,
          size: 100,
          color: colorScheme.primary.withValues(alpha: 0.3),
        ),
        const SizedBox(height: 16),
        Text(
          'dice_tap_to_roll'.tr(),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class _DieChip extends StatelessWidget {
  final int value;
  final int diceFaces;
  final int diceCount;
  final bool isRolling;

  const _DieChip({
    required this.value,
    required this.diceFaces,
    required this.diceCount,
    required this.isRolling,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isNat20 = diceFaces == 20 && value == 20 && !isRolling;
    final isNat1 = diceFaces == 20 && value == 1 && !isRolling;

    Color bgColor;
    Color textColor;

    if (isNat20) {
      bgColor = Colors.amber;
      textColor = Colors.black;
    } else if (isNat1) {
      bgColor = Colors.red.shade700;
      textColor = Colors.white;
    } else {
      bgColor = colorScheme.surfaceContainerHighest;
      textColor = colorScheme.onSurface;
    }

    final double size = diceCount <= 3 ? 80 : 64;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(diceFaces == 100 ? 50 : 12),
        border: Border.all(
          color: isNat20
              ? Colors.amber.shade700
              : colorScheme.outline.withValues(alpha: 0.3),
          width: isNat20 || isNat1 ? 3 : 1.5,
        ),
        boxShadow: [
          if (isNat20)
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.4),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: diceCount <= 3 ? 28 : 22,
            ),
          ),
          if (isNat20)
            Text(
              'NAT 20!',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                color: Colors.amber.shade900,
                letterSpacing: 1,
              ),
            ),
          if (isNat1)
            const Text(
              'CRIT FAIL',
              style: TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.w900,
                color: Colors.white70,
                letterSpacing: 0.5,
              ),
            ),
        ],
      ),
    );
  }
}

/// Layout compatto per >6 dadi.
class _CompactResults extends StatelessWidget {
  final List<int> results;
  final int diceFaces;
  final bool isRolling;

  const _CompactResults({
    required this.results,
    required this.diceFaces,
    required this.isRolling,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: results.map((value) {
          final isMax = value == diceFaces && !isRolling;
          final isMin = value == 1 && !isRolling;
          return Container(
            constraints: const BoxConstraints(minWidth: 40),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: isMax
                  ? Colors.amber.withValues(alpha: 0.2)
                  : isMin
                  ? Colors.red.withValues(alpha: 0.15)
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isMax
                    ? Colors.amber.shade700
                    : isMin
                    ? Colors.red
                    : colorScheme.outline.withValues(alpha: 0.2),
                width: isMax || isMin ? 2 : 1,
              ),
            ),
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isMax
                    ? Colors.amber.shade800
                    : isMin
                    ? Colors.red
                    : colorScheme.onSurface,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
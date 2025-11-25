import 'package:flutter/material.dart';
import '../../states/kitchen_timer_preset_model.dart';

class TimerPresetsGrid extends StatelessWidget {
  final Function(TimerPreset) onPresetSelected;

  const TimerPresetsGrid({
    super.key,
    required this.onPresetSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: TimerPreset.presets.length,
      itemBuilder: (context, index) {
        final preset = TimerPreset.presets[index];
        return _PresetButton(
          preset: preset,
          onTap: () => onPresetSelected(preset),
        );
      },
    );
  }
}

class _PresetButton extends StatelessWidget {
  final TimerPreset preset;
  final VoidCallback onTap;

  const _PresetButton({
    required this.preset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.secondaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                preset.emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 4),
              Text(
                preset.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${preset.minutes} min',
                style: TextStyle(
                  fontSize: 11,
                    color: Colors.white60,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
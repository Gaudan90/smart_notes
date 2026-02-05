import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../states/kitchen_timer_preset_model.dart';

class TimerPresetsGrid extends StatelessWidget {
  final Function(TimerPreset) onPresetSelected;

  const TimerPresetsGrid({
    super.key,
    required this.onPresetSelected,
  });

  // Mappa per tradurre i nomi dei preset
  static const Map<String, String> _presetTranslationKeys = {
    'Veloce': 'preset_quick',
    'Breve': 'preset_short',
    'Medio': 'preset_medium',
    'Standard': 'preset_standard',
    'Prolungato': 'preset_extended',
    'Lungo': 'preset_long',
  };

  String _translatePresetName(String name) {
    final key = _presetTranslationKeys[name];
    return key != null ? key.tr() : name;
  }

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
          translatedName: _translatePresetName(preset.name),
          onTap: () => onPresetSelected(preset),
        );
      },
    );
  }
}

class _PresetButton extends StatelessWidget {
  final TimerPreset preset;
  final String translatedName;
  final VoidCallback onTap;

  const _PresetButton({
    required this.preset,
    required this.translatedName,
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
                translatedName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${preset.minutes} min',
                style: const TextStyle(
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
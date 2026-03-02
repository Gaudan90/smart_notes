import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../theme/color_blind_mode.dart';
import '../../theme/theme_provider.dart';

/// Card con le opzioni di accessibilità per daltonismo.
class ColorBlindModeCard extends StatelessWidget {
  final ThemeProvider themeProvider;

  const ColorBlindModeCard({super.key, required this.themeProvider});

  String _label(ColorBlindMode mode) {
    switch (mode) {
      case ColorBlindMode.none:
        return 'cb_none'.tr();
      case ColorBlindMode.protanopia:
        return 'cb_protanopia'.tr();
      case ColorBlindMode.deuteranopia:
        return 'cb_deuteranopia'.tr();
      case ColorBlindMode.tritanopia:
        return 'cb_tritanopia'.tr();
    }
  }

  String _description(ColorBlindMode mode) {
    switch (mode) {
      case ColorBlindMode.none:
        return 'cb_none_desc'.tr();
      case ColorBlindMode.protanopia:
        return 'cb_protanopia_desc'.tr();
      case ColorBlindMode.deuteranopia:
        return 'cb_deuteranopia_desc'.tr();
      case ColorBlindMode.tritanopia:
        return 'cb_tritanopia_desc'.tr();
    }
  }

  IconData _icon(ColorBlindMode mode) {
    switch (mode) {
      case ColorBlindMode.none:
        return Icons.visibility;
      case ColorBlindMode.protanopia:
        return Icons.remove_red_eye;
      case ColorBlindMode.deuteranopia:
        return Icons.remove_red_eye_outlined;
      case ColorBlindMode.tritanopia:
        return Icons.visibility_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.accessibility_new,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'cb_accessibility'.tr(),
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'cb_description'.tr(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            ...ColorBlindMode.values.map((mode) {
              final isSelected = themeProvider.colorBlindMode == mode;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outline.withValues(alpha: 0.2),
                      width: isSelected ? 2 : 1,
                    ),
                    color: isSelected
                        ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                        : null,
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    leading: Icon(
                      _icon(mode),
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    title: Text(
                      _label(mode),
                      style: TextStyle(
                        fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      _description(mode),
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: isSelected
                        ? Icon(
                      Icons.check_circle,
                      color: colorScheme.primary,
                    )
                        : null,
                    onTap: () {
                      themeProvider.setColorBlindMode(mode);
                    },
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
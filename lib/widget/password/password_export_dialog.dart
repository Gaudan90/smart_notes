import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Modello per la scelta export: formato + azione.
class ExportChoice {
  final String format; // 'pdf' | 'txt'
  final String action; // 'share' | 'save'

  const ExportChoice({required this.format, required this.action});
}

/// Dialog per scegliere formato (PDF/TXT) e azione (condividi/salva).
class ExportChoiceDialog extends StatefulWidget {
  const ExportChoiceDialog({super.key});

  @override
  State<ExportChoiceDialog> createState() => _ExportChoiceDialogState();
}

class _ExportChoiceDialogState extends State<ExportChoiceDialog> {
  String _selectedFormat = 'pdf';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text('password_export_title'.tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'password_export_choose_format'.tr(),
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _FormatOption(
                  label: 'PDF',
                  icon: Icons.picture_as_pdf,
                  isSelected: _selectedFormat == 'pdf',
                  onTap: () => setState(() => _selectedFormat = 'pdf'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FormatOption(
                  label: 'TXT',
                  icon: Icons.description_outlined,
                  isSelected: _selectedFormat == 'txt',
                  onTap: () => setState(() => _selectedFormat = 'txt'),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
        OutlinedButton.icon(
          onPressed: () => Navigator.pop(
            context,
            ExportChoice(format: _selectedFormat, action: 'share'),
          ),
          icon: const Icon(Icons.share, size: 18),
          label: Text('share_btn'.tr()),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(
            context,
            ExportChoice(format: _selectedFormat, action: 'save'),
          ),
          icon: const Icon(Icons.save_alt, size: 18),
          label: Text('password_export_save'.tr()),
        ),
      ],
    );
  }
}

/// Card selezionabile per il formato (PDF o TXT).
class _FormatOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FormatOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
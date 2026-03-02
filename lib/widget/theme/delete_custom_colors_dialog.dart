import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class DeleteCustomColorsDialog extends StatefulWidget {
  final Map<String, Color> customColors;

  const DeleteCustomColorsDialog({
    super.key,
    required this.customColors,
  });

  @override
  State<DeleteCustomColorsDialog> createState() =>
      _DeleteCustomColorsDialogState();
}

class _DeleteCustomColorsDialogState extends State<DeleteCustomColorsDialog> {
  final Set<String> _selected = {};

  void _toggleSelection(String name) {
    setState(() {
      if (_selected.contains(name)) {
        _selected.remove(name);
      } else {
        _selected.add(name);
      }
    });
  }

  void _handleDelete() {
    if (_selected.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('confirm_deletion'.tr()),
        content: Text(
          'delete_custom_colors_confirm'.tr(
            namedArgs: {'count': '${_selected.length}'},
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('cancel'.tr()),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(ctx); // Chiude conferma
              Navigator.pop(context, _selected.toList()); // Ritorna selezione
            },
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final entries = widget.customColors.entries.toList();

    return AlertDialog(
      title: Text('delete_custom_colors_title'.tr()),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'delete_custom_colors_hint'.tr(),
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            ...entries.map((entry) {
              final isChecked = _selected.contains(entry.key);
              return InkWell(
                onTap: () => _toggleSelection(entry.key),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Checkbox(
                        value: isChecked,
                        onChanged: (_) => _toggleSelection(entry.key),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: entry.value,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            fontWeight:
                            isChecked ? FontWeight.bold : FontWeight.normal,
                            decoration: isChecked
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
        FilledButton.icon(
          onPressed: _selected.isEmpty ? null : _handleDelete,
          icon: const Icon(Icons.delete_outline, size: 18),
          label: Text(
            _selected.isEmpty
                ? 'delete'.tr()
                : '${'delete'.tr()} (${_selected.length})',
          ),
          style: FilledButton.styleFrom(
            backgroundColor: _selected.isEmpty ? null : Colors.red,
          ),
        ),
      ],
    );
  }
}
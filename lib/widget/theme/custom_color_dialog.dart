import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../theme/color_picker_painter.dart';

/// Risultato del dialog: nome e colore scelti dall'utente.
class CustomColorResult {
  final String name;
  final Color color;

  const CustomColorResult({required this.name, required this.color});
}

/// Dialog con color picker HSL e campo nome per aggiungere un colore custom.
class CustomColorDialog extends StatefulWidget {
  const CustomColorDialog({super.key});

  @override
  State<CustomColorDialog> createState() => _CustomColorDialogState();
}

class _CustomColorDialogState extends State<CustomColorDialog> {
  final _nameController = TextEditingController();
  Color _selectedColor = Colors.blue;
  double _touchX = 0.5;
  double _touchY = 0.5;

  static const double _pickerWidth = 250.0;
  static const double _pickerHeight = 150.0;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _updateColor(Offset localPosition) {
    setState(() {
      _touchX = (localPosition.dx / _pickerWidth).clamp(0.0, 1.0);
      _touchY = (localPosition.dy / _pickerHeight).clamp(0.0, 1.0);

      final hue = _touchX * 360;
      const saturation = 1.0;
      final lightness = 0.3 + (1 - _touchY) * 0.5;

      _selectedColor = HSLColor.fromAHSL(
        1.0, hue, saturation, lightness,
      ).toColor();
    });
  }

  void _handleAdd() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('color_name_required'.tr()),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    Navigator.pop(
      context,
      CustomColorResult(
        name: _nameController.text.trim(),
        color: _selectedColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('add_custom_color_title'.tr()),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'color_name_label'.tr(),
                hintText: 'color_name_hint'.tr(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: _pickerWidth,
              height: _pickerHeight,
              child: GestureDetector(
                onPanStart: (d) => _updateColor(d.localPosition),
                onPanUpdate: (d) => _updateColor(d.localPosition),
                onTapDown: (d) => _updateColor(d.localPosition),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      CustomPaint(
                        painter: ColorPickerPainter(),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      Positioned(
                        left: (_touchX * _pickerWidth) - 20,
                        top: (_touchY * _pickerHeight) - 20,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _selectedColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
        ElevatedButton(
          onPressed: _handleAdd,
          child: Text('add'.tr()),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';

class ColorPickerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    for (double i = 0; i < size.width; i++) {
      final hue = (i / size.width) * 360;

      final rect = Rect.fromLTWH(i, 0, 1, size.height);
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          HSLColor.fromAHSL(1.0, hue, 1.0, 0.8).toColor(),
          HSLColor.fromAHSL(1.0, hue, 1.0, 0.3).toColor(),
        ],
      );

      canvas.drawRect(
        rect,
        Paint()..shader = gradient.createShader(rect),
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
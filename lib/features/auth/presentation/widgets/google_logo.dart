import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Logo Google dessiné, pour le bouton « Continuer avec Google ».
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 18});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  static const _blue = Color(0xFF4285F4);
  static const _green = Color(0xFF34A853);
  static const _yellow = Color(0xFFFBBC05);
  static const _red = Color(0xFFEA4335);

  static double _rad(double degrees) => degrees * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final stroke = side * 0.22;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      side - stroke,
      side - stroke,
    );

    Paint arc(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    // Les quatre arcs, dans le sens horaire depuis la droite. L'ouverture en
    // haut à droite laisse passer la barre du « G ».
    canvas.drawArc(rect, _rad(-14), _rad(62), false, arc(_blue));
    canvas.drawArc(rect, _rad(50), _rad(80), false, arc(_green));
    canvas.drawArc(rect, _rad(128), _rad(84), false, arc(_yellow));
    canvas.drawArc(rect, _rad(210), _rad(106), false, arc(_red));

    // Barre horizontale du « G ».
    canvas.drawRect(
      Rect.fromLTRB(
        side * 0.5,
        side * 0.5 - stroke / 2,
        side - stroke * 0.5,
        side * 0.5 + stroke / 2,
      ),
      Paint()..color = _blue,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

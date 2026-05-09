import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A subtle 8-pointed Islamic star tessellation, drawn at low opacity for
/// background ornament on hero surfaces.
class GeometricPattern extends StatelessWidget {
  final Color color;
  final double opacity;
  final double cell;

  const GeometricPattern({
    super.key,
    this.color = Colors.white,
    this.opacity = 0.06,
    this.cell = 56,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _StarPainter(color: color.withOpacity(opacity), cell: cell),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  final Color color;
  final double cell;
  _StarPainter({required this.color, required this.cell});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final radius = cell * 0.36;
    for (double y = 0; y < size.height + cell; y += cell) {
      for (double x = 0; x < size.width + cell; x += cell) {
        _drawStar(canvas, Offset(x, y), radius, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    const points = 8;
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points) - math.pi / 2;
      final dist = (i.isEven) ? r : r * 0.5;
      final p = Offset(center.dx + math.cos(angle) * dist, center.dy + math.sin(angle) * dist);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StarPainter old) =>
      old.color != color || old.cell != cell;
}

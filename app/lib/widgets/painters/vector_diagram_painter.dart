// ─────────────────────────────────────────────────────────────────────────────
// vector_diagram_painter.dart
// CustomPainter for Mode 2 — two arm vectors, resultant, parallelogram
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math';
import 'package:flutter/material.dart';
import '../app_theme.dart';

class VectorDiagramPainter extends CustomPainter {
  final double a1;      // arm 1 angle in degrees
  final double a2;      // arm 2 angle in degrees
  final double rmag;    // resultant magnitude
  final double rang;    // resultant angle in degrees
  final RadianCanvasTheme canvasTheme;

  VectorDiagramPainter({
    required this.a1,
    required this.a2,
    required this.rmag,
    required this.rang,
    required this.canvasTheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width  / 2;
    final cy = size.height / 2;
    // Resultant can reach magnitude 2, so unit length = radius / 2.2
    final unit = min(cx, cy) * 0.78 / 2.2;

    final rad1 = a1 * pi / 180.0;
    final rad2 = a2 * pi / 180.0;
    final radR = rang * pi / 180.0;

    // Vector endpoints (screen coords — y inverted)
    final v1 = Offset(cx + unit * cos(rad1), cy - unit * sin(rad1));
    final v2 = Offset(cx + unit * cos(rad2), cy - unit * sin(rad2));
    final vR = Offset(
      cx + unit * rmag * cos(radR),
      cy - unit * rmag * sin(radR),
    );

    // ── Paints ────────────────────────────────────────────────────────────────

    final gridPaint = Paint()
      ..color = canvasTheme.gridLine
      ..strokeWidth = 1.0;

    final axisPaint = Paint()
      ..color = canvasTheme.canvasBorder.withOpacity(0.6)
      ..strokeWidth = 1.0;

    final arm1Paint = Paint()
      ..color = canvasTheme.arm1Color
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final arm2Paint = Paint()
      ..color = canvasTheme.arm2Color
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final resultantPaint = Paint()
      ..color = canvasTheme.resultantColor
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    final parallelogramPaint = Paint()
      ..color = canvasTheme.resultantColor.withOpacity(0.35)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = canvasTheme.resultantColor.withOpacity(0.06)
      ..style = PaintingStyle.fill;

    // ── Grid circle + axes ────────────────────────────────────────────────────
    canvas.drawCircle(
      Offset(cx, cy), unit,
      Paint()
        ..color = canvasTheme.gridLine
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke,
    );
    canvas.drawLine(
        Offset(cx - unit * 2.2, cy), Offset(cx + unit * 2.2, cy), axisPaint);
    canvas.drawLine(
        Offset(cx, cy - unit * 2.2), Offset(cx, cy + unit * 2.2), axisPaint);

    // grid ticks every 0.5 units on both axes
    for (double t = -2.0; t <= 2.0; t += 0.5) {
      if (t == 0) continue;
      canvas.drawLine(
        Offset(cx + unit * t, cy - 4), Offset(cx + unit * t, cy + 4), gridPaint);
      canvas.drawLine(
        Offset(cx - 4, cy - unit * t), Offset(cx + 4, cy - unit * t), gridPaint);
    }

    // ── Parallelogram fill + outline ─────────────────────────────────────────
    final path = Path()
      ..moveTo(cx, cy)
      ..lineTo(v1.dx, v1.dy)
      ..lineTo(vR.dx, vR.dy)
      ..lineTo(v2.dx, v2.dy)
      ..close();
    canvas.drawPath(path, fillPaint);

    _drawDashed(canvas, v1, vR, parallelogramPaint);
    _drawDashed(canvas, v2, vR, parallelogramPaint);

    // ── Component projections for resultant ──────────────────────────────────
    final projPaint = Paint()
      ..color = canvasTheme.resultantColor.withOpacity(0.4)
      ..strokeWidth = 1.0;
    _drawDashed(canvas, vR, Offset(vR.dx, cy), projPaint);
    _drawDashed(canvas, vR, Offset(cx, vR.dy), projPaint);

    // ── Vectors (draw resultant beneath arms) ────────────────────────────────
    _drawArrow(canvas, Offset(cx, cy), vR, resultantPaint, 12);
    _drawArrow(canvas, Offset(cx, cy), v1, arm1Paint, 10);
    _drawArrow(canvas, Offset(cx, cy), v2, arm2Paint, 10);

    // ── Origin dot ───────────────────────────────────────────────────────────
    canvas.drawCircle(
      Offset(cx, cy), 5,
      Paint()..color = canvasTheme.canvasBorder,
    );

    // ── Labels ────────────────────────────────────────────────────────────────
    _drawLabel(canvas, 'v1', _labelPos(Offset(cx, cy), v1, 16),
        canvasTheme.arm1Color);
    _drawLabel(canvas, 'v2', _labelPos(Offset(cx, cy), v2, 16),
        canvasTheme.arm2Color);
    _drawLabel(canvas, 'R', _labelPos(Offset(cx, cy), vR, 18),
        canvasTheme.resultantColor);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Offset _labelPos(Offset origin, Offset tip, double offset) {
    final dx = tip.dx - origin.dx;
    final dy = tip.dy - origin.dy;
    final len = sqrt(dx * dx + dy * dy);
    if (len == 0) return tip;
    return Offset(
      tip.dx + (dx / len) * offset,
      tip.dy + (dy / len) * offset,
    );
  }

  void _drawArrow(
      Canvas canvas, Offset from, Offset to, Paint paint, double headSize) {
    canvas.drawLine(from, to, paint);

    final angle = atan2(to.dy - from.dy, to.dx - from.dx);
    const headAngle = 0.45;

    final p1 = Offset(
      to.dx - headSize * cos(angle - headAngle),
      to.dy - headSize * sin(angle - headAngle),
    );
    final p2 = Offset(
      to.dx - headSize * cos(angle + headAngle),
      to.dy - headSize * sin(angle + headAngle),
    );

    final headPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
    final headPath = Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();
    canvas.drawPath(headPath, headPaint);
  }

  void _drawDashed(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashLength = 6.0;
    const gapLength  = 4.0;
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final dist = sqrt(dx * dx + dy * dy);
    if (dist == 0) return;
    final ux = dx / dist;
    final uy = dy / dist;
    double drawn = 0;
    bool drawing = true;
    double x = p1.dx, y = p1.dy;

    while (drawn < dist) {
      final segLen = drawing
          ? min(dashLength, dist - drawn)
          : min(gapLength,  dist - drawn);
      if (drawing) {
        canvas.drawLine(
          Offset(x, y), Offset(x + ux * segLen, y + uy * segLen), paint);
      }
      x += ux * segLen;
      y += uy * segLen;
      drawn += segLen;
      drawing = !drawing;
    }
  }

  void _drawLabel(Canvas canvas, String text, Offset position, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color:      color,
          fontSize:   13,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(position.dx - tp.width / 2, position.dy - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(VectorDiagramPainter old) =>
      old.a1 != a1 || old.a2 != a2 || old.rmag != rmag || old.rang != rang;
}

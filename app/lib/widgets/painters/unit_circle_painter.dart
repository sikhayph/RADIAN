// ─────────────────────────────────────────────────────────────────────────────
// unit_circle_painter.dart
// CustomPainter for Mode 1 — unit circle, swept arc, arm, cos/sin projections
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math';
import 'package:flutter/material.dart';
import '../app_theme.dart';

class UnitCirclePainter extends CustomPainter {
  final double degrees;
  final double cosVal;
  final double sinVal;
  final RadianCanvasTheme canvasTheme;

  UnitCirclePainter({
    required this.degrees,
    required this.cosVal,
    required this.sinVal,
    required this.canvasTheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width  / 2;
    final cy = size.height / 2;
    final r  = min(cx, cy) * 0.78;

    final radians = degrees * pi / 180.0;

    // ── Paints ────────────────────────────────────────────────────────────────

    final gridPaint = Paint()
      ..color = canvasTheme.gridLine
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final circlePaint = Paint()
      ..color = canvasTheme.canvasBorder
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final axisPaint = Paint()
      ..color = canvasTheme.canvasBorder.withOpacity(0.6)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final arcPaint = Paint()
      ..color = canvasTheme.arm1Color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final arcBorderPaint = Paint()
      ..color = canvasTheme.arm1Color.withOpacity(0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final armPaint = Paint()
      ..color = canvasTheme.arm1Color
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final projPaint = Paint()
      ..color = canvasTheme.arm1Color.withOpacity(0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = canvasTheme.arm1Color
      ..style = PaintingStyle.fill;

    // ── Grid lines at 30° intervals ───────────────────────────────────────────
    for (int i = 0; i < 12; i++) {
      final angle = i * 30.0 * pi / 180.0;
      canvas.drawLine(
        Offset(cx + r * cos(angle), cy - r * sin(angle)),
        Offset(cx - r * cos(angle), cy + r * sin(angle)),
        gridPaint,
      );
    }

    // ── Axes ──────────────────────────────────────────────────────────────────
    canvas.drawLine(Offset(cx - r - 20, cy), Offset(cx + r + 20, cy), axisPaint);
    canvas.drawLine(Offset(cx, cy - r - 20), Offset(cx, cy + r + 20), axisPaint);

    // ── Unit circle ───────────────────────────────────────────────────────────
    canvas.drawCircle(Offset(cx, cy), r, circlePaint);

    // ── Tick marks at 30°, 45°, 60° ──────────────────────────────────────────
    final tickAngles = [30, 45, 60, 90, 120, 135, 150, 180,
                        210, 225, 240, 270, 300, 315, 330, 360];
    final tickPaint = Paint()
      ..color = canvasTheme.canvasBorder.withOpacity(0.5)
      ..strokeWidth = 1.0;
    for (final deg in tickAngles) {
      final a = deg * pi / 180.0;
      canvas.drawLine(
        Offset(cx + (r - 6) * cos(a), cy - (r - 6) * sin(a)),
        Offset(cx + (r + 4) * cos(a), cy - (r + 4) * sin(a)),
        tickPaint,
      );
    }

    // ── Swept arc ─────────────────────────────────────────────────────────────
    final arcRect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    canvas.drawArc(arcRect, 0, -radians, true, arcPaint);
    canvas.drawArc(arcRect, 0, -radians, false, arcBorderPaint);

    // ── Arm tip coordinates ───────────────────────────────────────────────────
    final tipX = cx + r * cos(radians);
    final tipY = cy - r * sin(radians);

    // ── Dotted projection lines ───────────────────────────────────────────────
    _drawDashed(canvas, Offset(tipX, tipY), Offset(tipX, cy), projPaint);
    _drawDashed(canvas, Offset(tipX, tipY), Offset(cx, tipY), projPaint);

    // ── Projection endpoint dots ──────────────────────────────────────────────
    canvas.drawCircle(Offset(tipX, cy), 4, dotPaint);
    canvas.drawCircle(Offset(cx, tipY), 4, dotPaint);

    // ── Arm ───────────────────────────────────────────────────────────────────
    canvas.drawLine(Offset(cx, cy), Offset(tipX, tipY), armPaint);

    // ── Origin dot ───────────────────────────────────────────────────────────
    canvas.drawCircle(Offset(cx, cy), 5, dotPaint);

    // ── Tip dot with glow ────────────────────────────────────────────────────
    canvas.drawCircle(
      Offset(tipX, tipY), 10,
      Paint()..color = canvasTheme.arm1Color.withOpacity(0.2),
    );
    canvas.drawCircle(Offset(tipX, tipY), 6, dotPaint);

    // ── Cardinal labels ───────────────────────────────────────────────────────
    _drawLabel(canvas, '0', Offset(cx + r + 14, cy), canvasTheme);
    _drawLabel(canvas, 'π/2', Offset(cx, cy - r - 14), canvasTheme);
    _drawLabel(canvas, 'π', Offset(cx - r - 14, cy), canvasTheme);
    _drawLabel(canvas, '3π/2', Offset(cx, cy + r + 14), canvasTheme);

    // ── Coordinate label at tip ───────────────────────────────────────────────
    final coordText =
        '(${cosVal.toStringAsFixed(2)}, ${sinVal.toStringAsFixed(2)})';
    _drawLabel(
      canvas,
      coordText,
      Offset(tipX + 10, tipY - 14),
      canvasTheme,
      fontSize: 11,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _drawDashed(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashLength = 6.0;
    const gapLength  = 4.0;
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final dist = sqrt(dx * dx + dy * dy);
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
          Offset(x, y),
          Offset(x + ux * segLen, y + uy * segLen),
          paint,
        );
      }
      x += ux * segLen;
      y += uy * segLen;
      drawn += segLen;
      drawing = !drawing;
    }
  }

  void _drawLabel(
    Canvas canvas,
    String text,
    Offset position,
    RadianCanvasTheme theme, {
    double fontSize = 12,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color:      theme.canvasBorder,
          fontSize:   fontSize,
          fontFamily: 'Inter',
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
  bool shouldRepaint(UnitCirclePainter old) =>
      old.degrees != degrees ||
      old.cosVal  != cosVal  ||
      old.sinVal  != sinVal;
}
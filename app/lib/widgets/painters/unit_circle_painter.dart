// ─────────────────────────────────────────────────────────────────────────────
// unit_circle_painter.dart
<<<<<<< HEAD
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
=======
// CustomPainter for Mode 1 — Degree / Radian Conversion
// Valiger — RADIAN Companion App
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app_theme.dart';

/// Draws the full Mode 1 unit circle canvas:
///  • Outer circle with axis lines and tick marks
///  • Shaded swept arc from 0° to [angleDeg]
///  • Arm line from origin to point on circle
///  • cos/sin dotted projection lines
///  • Point dot at (cos θ, sin θ)
///  • Degree and radian labels
class UnitCirclePainter extends CustomPainter {
  final double angleDeg;   // 0–359.9
  final double cosVal;     // cos(angleDeg)
  final double sinVal;     // sin(angleDeg)
  final RadianCanvasTheme canvasTheme;
  final Color   textColor;

  const UnitCirclePainter({
    required this.angleDeg,
    required this.cosVal,
    required this.sinVal,
    required this.canvasTheme,
    required this.textColor,
  });

  // ── Geometry helpers ────────────────────────────────────────────────────────

  // Flutter's canvas: +y is DOWN. Unit circle convention: +y is UP.
  // We flip the y-axis by negating y coordinates before drawing.

  double get _angleRad => angleDeg * math.pi / 180.0;

  Offset _unitToCanvas(double ux, double uy, Offset center, double r) {
    return center + Offset(ux * r, -uy * r); // flip y
  }

  // ── Paint factory helpers ───────────────────────────────────────────────────

  Paint _circlePaint(Color color, {double width = 1.5, bool fill = false}) =>
      Paint()
        ..color = color
        ..strokeWidth = width
        ..style = fill ? PaintingStyle.fill : PaintingStyle.stroke
        ..isAntiAlias = true;

  // ── Drawing ─────────────────────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) * 0.80;

    _drawGrid(canvas, center, radius);
    _drawAxes(canvas, center, radius);
    _drawCircle(canvas, center, radius);
    _drawTicks(canvas, center, radius);
    _drawArc(canvas, center, radius);
    _drawProjections(canvas, center, radius);
    _drawArm(canvas, center, radius);
    _drawTip(canvas, center, radius);
    _drawLabels(canvas, center, radius, size);
  }

  void _drawGrid(Canvas canvas, Offset center, double radius) {
    final gridPaint = Paint()
      ..color = canvasTheme.gridLine
      ..strokeWidth = 0.8;

    // Horizontal and vertical mid-lines (light)
    canvas.drawLine(
      center + Offset(-radius * 1.15, 0),
      center + Offset( radius * 1.15, 0),
      gridPaint,
    );
    canvas.drawLine(
      center + Offset(0, -radius * 1.15),
      center + Offset(0,  radius * 1.15),
      gridPaint,
    );
  }

  void _drawAxes(Canvas canvas, Offset center, double radius) {
    final axisPaint = _circlePaint(
      canvasTheme.canvasBorder.withOpacity(0.5),
      width: 1.0,
    );

    // Draw quadrant labels
    final quadrantStyle = TextStyle(
      fontFamily: 'Inter',
      fontSize: 10,
      color: canvasTheme.canvasBorder.withOpacity(0.4),
    );
    final labels = [
      ('I',   Offset( radius * 0.55,  -radius * 0.55)),
      ('II',  Offset(-radius * 0.60,  -radius * 0.55)),
      ('III', Offset(-radius * 0.65,   radius * 0.55)),
      ('IV',  Offset( radius * 0.55,   radius * 0.55)),
    ];
    for (final (text, offset) in labels) {
      _drawText(canvas, text, center + offset, quadrantStyle, TextAlign.center);
    }
    _ = axisPaint; // suppress unused warning
  }

  void _drawCircle(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(
      center,
      radius,
      _circlePaint(canvasTheme.canvasBorder, width: 1.5),
    );
  }

  void _drawTicks(Canvas canvas, Offset center, double radius) {
    final majorPaint = _circlePaint(canvasTheme.canvasBorder.withOpacity(0.7), width: 1.2);
    final minorPaint = _circlePaint(canvasTheme.canvasBorder.withOpacity(0.3), width: 0.8);

    for (int deg = 0; deg < 360; deg += 5) {
      final rad = deg * math.pi / 180.0;
      final isMajor = deg % 30 == 0;
      final outerR  = radius;
      final innerR  = isMajor ? radius * 0.92 : radius * 0.96;

      final cos = math.cos(rad), sin = math.sin(rad);
      canvas.drawLine(
        center + Offset(cos * innerR, -sin * innerR),
        center + Offset(cos * outerR, -sin * outerR),
        isMajor ? majorPaint : minorPaint,
      );

      // Labels at 0°, 90°, 180°, 270°
      if (deg % 90 == 0) {
        final labelR = radius * 1.12;
        final labels = {0: '0°', 90: '90°', 180: '180°', 270: '270°'};
        if (labels.containsKey(deg)) {
          final pos = center + Offset(cos * labelR, -sin * labelR);
          _drawText(
            canvas,
            labels[deg]!,
            pos,
            TextStyle(
              fontFamily: 'Inter',
              fontSize: 9,
              color: textColor.withOpacity(0.5),
            ),
            TextAlign.center,
          );
        }
      }
    }
  }

  void _drawArc(Canvas canvas, Offset center, double radius) {
    if (angleDeg == 0) return;
    final arcPaint = Paint()
      ..color = canvasTheme.arm1Color.withOpacity(0.18)
      ..style  = PaintingStyle.fill;

    final sweepAngle = -_angleRad; // negative because y-flip
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.98),
      0,            // start at 3 o'clock (0° in Flutter = right)
      sweepAngle,
      true,
      arcPaint,
    );

    // Arc outline
    final arcStroke = Paint()
      ..color = canvasTheme.arm1Color.withOpacity(0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.98),
      0,
      sweepAngle,
      false,
      arcStroke,
    );
  }

  void _drawProjections(Canvas canvas, Offset center, double radius) {
    final tipX = cosVal * radius;
    final tipY = -sinVal * radius;
    final tip  = center + Offset(tipX, tipY);

    final dashPaint = Paint()
      ..color = canvasTheme.positiveColor.withOpacity(0.4)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Vertical projection: tip → x-axis
    _drawDashedLine(
      canvas,
      tip,
      center + Offset(tipX, 0),
      dashPaint,
    );

    // Horizontal projection: tip → y-axis
    _drawDashedLine(
      canvas,
      tip,
      center + Offset(0, tipY),
      dashPaint,
    );
  }

  void _drawArm(Canvas canvas, Offset center, double radius) {
    final tip = _unitToCanvas(cosVal, sinVal, center, radius);
    canvas.drawLine(
      center,
      tip,
      _circlePaint(canvasTheme.arm1Color, width: 2.5),
    );
  }

  void _drawTip(Canvas canvas, Offset center, double radius) {
    final tip = _unitToCanvas(cosVal, sinVal, center, radius);
    // Outer glow
    canvas.drawCircle(
      tip,
      7,
      Paint()
        ..color = canvasTheme.arm1Color.withOpacity(0.25)
        ..style  = PaintingStyle.fill,
    );
    // Solid dot
    canvas.drawCircle(
      tip,
      4,
      Paint()
        ..color = canvasTheme.arm1Color
        ..style  = PaintingStyle.fill,
    );
  }

  void _drawLabels(Canvas canvas, Offset center, double radius, Size size) {
    final tip  = _unitToCanvas(cosVal, sinVal, center, radius);
    final tipX = cosVal * radius;
    final tipY = -sinVal * radius;

    // cos label on x-axis
    _drawText(
      canvas,
      'cos θ = ${cosVal.toStringAsFixed(3)}',
      center + Offset(tipX / 2, 14),
      TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 9.5,
        color: canvasTheme.positiveColor.withOpacity(0.75),
      ),
      TextAlign.center,
    );

    // sin label on y-axis
    _drawText(
      canvas,
      'sin θ = ${sinVal.toStringAsFixed(3)}',
      center + Offset(-40, tipY / 2),
      TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 9.5,
        color: canvasTheme.positiveColor.withOpacity(0.75),
      ),
      TextAlign.right,
    );

    // Angle label near tip
    final labelOffset = tip + Offset(
      cosVal >= 0 ? 10 : -50,
      sinVal >= 0 ? -16 : 6,
    );
    _drawText(
      canvas,
      '(${cosVal.toStringAsFixed(2)}, ${sinVal.toStringAsFixed(2)})',
      labelOffset,
      TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 9,
        color: canvasTheme.arm1Color,
        fontWeight: FontWeight.w600,
      ),
      TextAlign.left,
    );
  }

  // ── Text helper ─────────────────────────────────────────────────────────────

  void _drawText(
    Canvas canvas,
    String text,
    Offset position,
    TextStyle style,
    TextAlign align,
  ) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout();

    double dx = position.dx;
    if (align == TextAlign.center) dx -= tp.width / 2;
    if (align == TextAlign.right)  dx -= tp.width;

    tp.paint(canvas, Offset(dx, position.dy - tp.height / 2));
  }

  // ── Dashed line helper ──────────────────────────────────────────────────────

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint,
      {double dash = 4, double gap = 4}) {
    final total = (p2 - p1).distance;
    if (total == 0) return;
    final dir = (p2 - p1) / total;
    double d = 0;
    bool drawing = true;
    while (d < total) {
      final segLen = math.min(drawing ? dash : gap, total - d);
      if (drawing) {
        canvas.drawLine(p1 + dir * d, p1 + dir * (d + segLen), paint);
      }
      d += segLen;
>>>>>>> 79c833885cfeeaa988166c63b63a1177a67278d9
      drawing = !drawing;
    }
  }

<<<<<<< HEAD
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
=======
  @override
  bool shouldRepaint(UnitCirclePainter old) =>
      old.angleDeg != angleDeg ||
      old.canvasTheme != canvasTheme;
}
>>>>>>> 79c833885cfeeaa988166c63b63a1177a67278d9

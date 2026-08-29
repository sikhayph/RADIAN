// ─────────────────────────────────────────────────────────────────────────────
// vector_addition_painter.dart
// CustomPainter for Mode 2 — Vector Addition
// Valiger — RADIAN Companion App
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app_theme.dart';

/// Draws the Mode 2 vector addition canvas:
///  • Arm 1 and Arm 2 as unit vectors from the origin
///  • Resultant vector (Arm 1 + Arm 2) from the origin
///  • Dashed component projection lines for each arm
///  • Faint parallelogram outline completing the tail-to-tip construction
class VectorAdditionPainter extends CustomPainter {
  final double a1Deg; // Arm 1 angle, degrees
  final double a2Deg; // Arm 2 angle, degrees
  final RadianCanvasTheme canvasTheme;
  final Color textColor;

  const VectorAdditionPainter({
    required this.a1Deg,
    required this.a2Deg,
    required this.canvasTheme,
    required this.textColor,
  });

  // ── Geometry helpers ────────────────────────────────────────────────────────
  // Flutter's canvas: +y is DOWN. Unit circle convention: +y is UP.
  // We flip the y-axis by negating y coordinates before drawing.

  double get _a1Rad => a1Deg * math.pi / 180.0;
  double get _a2Rad => a2Deg * math.pi / 180.0;

  Offset get _v1 => Offset(math.cos(_a1Rad), math.sin(_a1Rad));
  Offset get _v2 => Offset(math.cos(_a2Rad), math.sin(_a2Rad));
  Offset get _resultant => _v1 + _v2;

  Offset _toCanvas(Offset unit, Offset center, double scale) =>
      center + Offset(unit.dx * scale, -unit.dy * scale); // flip y

  Paint _linePaint(Color color, {double width = 1.5}) => Paint()
    ..color = color
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true;

  // ── Drawing ─────────────────────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Resultant can reach 2x a unit vector (parallel arms) — scale so it
    // always fits inside the canvas with margin.
    final scale = (size.shortestSide / 2) * 0.80 / 2.0;

    final p1 = _toCanvas(_v1, center, scale);
    final p2 = _toCanvas(_v2, center, scale);
    final pr = _toCanvas(_resultant, center, scale);

    _drawGrid(canvas, center, scale);
    _drawAxes(canvas, center, scale);
    _drawParallelogram(canvas, p1, p2, pr);
    _drawProjection(canvas, center, p1, canvasTheme.arm1Color);
    _drawProjection(canvas, center, p2, canvasTheme.arm2Color);
    _drawVector(canvas, center, p1, canvasTheme.arm1Color);
    _drawVector(canvas, center, p2, canvasTheme.arm2Color);
    _drawVector(canvas, center, pr, canvasTheme.resultantColor);
    _drawOrigin(canvas, center);
    _drawLabels(canvas, p1, p2, pr);
  }

  void _drawGrid(Canvas canvas, Offset center, double scale) {
    final gridPaint = Paint()
      ..color = canvasTheme.gridLine
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    // Reference rings at |v| = 1 and |v| = 2 (max possible resultant).
    canvas.drawCircle(center, scale, gridPaint);
    canvas.drawCircle(center, scale * 2, gridPaint);
  }

  void _drawAxes(Canvas canvas, Offset center, double scale) {
    final axisPaint = _linePaint(canvasTheme.canvasBorder.withOpacity(0.4), width: 1.0);
    canvas.drawLine(center + Offset(-scale * 2.2, 0), center + Offset(scale * 2.2, 0), axisPaint);
    canvas.drawLine(center + Offset(0, -scale * 2.2), center + Offset(0, scale * 2.2), axisPaint);
  }

  void _drawOrigin(Canvas canvas, Offset center) {
    canvas.drawCircle(center, 3, Paint()..color = textColor.withOpacity(0.6));
  }

  void _drawProjection(Canvas canvas, Offset center, Offset tip, Color color) {
    final dashPaint = Paint()
      ..color = color.withOpacity(0.35)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    _drawDashedLine(canvas, tip, Offset(tip.dx, center.dy), dashPaint);
    _drawDashedLine(canvas, tip, Offset(center.dx, tip.dy), dashPaint);
  }

  void _drawParallelogram(Canvas canvas, Offset p1, Offset p2, Offset pr) {
    final dashPaint = Paint()
      ..color = canvasTheme.resultantColor.withOpacity(0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    // Translated copies of each arm, completing the tail-to-tip construction.
    _drawDashedLine(canvas, p1, pr, dashPaint);
    _drawDashedLine(canvas, p2, pr, dashPaint);
  }

  void _drawVector(Canvas canvas, Offset from, Offset to, Color color) {
    canvas.drawLine(from, to, _linePaint(color, width: 4.0));
    _drawArrowhead(canvas, from, to, color);
  }

  void _drawArrowhead(Canvas canvas, Offset from, Offset to, Color color) {
    final dir = to - from;
    if (dir.distance < 1e-6) return;
    final unit = dir / dir.distance;
    final normal = Offset(-unit.dy, unit.dx);
    const headLen = 10.0, headWidth = 6.0;
    final base = to - unit * headLen;
    final path = Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(base.dx + normal.dx * headWidth, base.dy + normal.dy * headWidth)
      ..lineTo(base.dx - normal.dx * headWidth, base.dy - normal.dy * headWidth)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  void _drawLabels(Canvas canvas, Offset p1, Offset p2, Offset pr) {
    _drawText(
      canvas,
      'Arm 1',
      p1 + const Offset(0, -16),
      TextStyle(
        fontFamily: 'Inter',
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: canvasTheme.arm1Color,
      ),
      TextAlign.center,
    );
    _drawText(
      canvas,
      'Arm 2',
      p2 + const Offset(0, -16),
      TextStyle(
        fontFamily: 'Inter',
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: canvasTheme.arm2Color,
      ),
      TextAlign.center,
    );
    _drawText(
      canvas,
      'R',
      pr + const Offset(0, -16),
      TextStyle(
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: canvasTheme.resultantColor,
      ),
      TextAlign.center,
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
    if (align == TextAlign.right) dx -= tp.width;

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
      drawing = !drawing;
    }
  }

  @override
  bool shouldRepaint(VectorAdditionPainter old) =>
      old.a1Deg != a1Deg || old.a2Deg != a2Deg || old.canvasTheme != canvasTheme;
}

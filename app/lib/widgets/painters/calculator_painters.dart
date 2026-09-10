// ─────────────────────────────────────────────────────────────────────────────
// calculator_painters.dart
// CustomPainters for the Calculator mode's Vector Addition, Rotation Matrix,
// and Polygon Angles tabs. Geometry mirrors the website's inline SVG figures
// (components/calculator/*Panel.tsx + svgHelpers.ts), adapted to Flutter's
// Canvas (+y already down, same as the website's screen-space helpers).
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../calculator/math.dart' as calc;

// ── Shared arrow-drawing helper ─────────────────────────────────────────────

void _drawArrow(
  Canvas canvas,
  Offset from,
  Offset to,
  Color color,
  String label,
  Color textColor, {
  double opacity = 1.0,
  double strokeWidth = 3,
  bool bold = false,
}) {
  final linePaint = Paint()
    ..color = color.withOpacity(opacity)
    ..strokeWidth = strokeWidth
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(from, to, linePaint);

  final dx = to.dx - from.dx;
  final dy = to.dy - from.dy;
  final len = math.sqrt(dx * dx + dy * dy);
  if (len > 0.001) {
    final ux = dx / len, uy = dy / len;
    final nx = -uy, ny = ux;
    const size = 9.0;
    final baseX = to.dx - ux * size;
    final baseY = to.dy - uy * size;
    const w = size * 0.6;
    final path = Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(baseX + nx * w, baseY + ny * w)
      ..lineTo(baseX - nx * w, baseY - ny * w)
      ..close();
    canvas.drawPath(path, Paint()..color = color.withOpacity(opacity));
  }

  final tp = TextPainter(
    text: TextSpan(
      text: label,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        color: color.withOpacity(opacity),
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(canvas, Offset(to.dx - tp.width / 2, to.dy - 22));
}

void _drawAxes(Canvas canvas, Offset center, double half, Color color) {
  final paint = Paint()
    ..color = color
    ..strokeWidth = 1;
  canvas.drawLine(center - Offset(half, 0), center + Offset(half, 0), paint);
  canvas.drawLine(center - Offset(0, half), center + Offset(0, half), paint);
}

// ── Vector Addition ─────────────────────────────────────────────────────────

class CalcVectorPainter extends CustomPainter {
  final calc.Vec2 v1;
  final calc.Vec2 v2;
  final calc.VectorSum sum;
  final RadianCanvasTheme canvasTheme;

  const CalcVectorPainter({
    required this.v1,
    required this.v2,
    required this.sum,
    required this.canvasTheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final half = size.shortestSide / 2 * 0.9;
    final maxDim = size.shortestSide / 2 * 0.75;

    final maxMag = [1e-3, calc.vecMagnitude(v1), calc.vecMagnitude(v2), sum.magnitude]
        .reduce(math.max);
    final scale = maxDim / maxMag;

    Offset toScreen(calc.Vec2 v) => center + Offset(v.x * scale, -v.y * scale);
    final p1 = toScreen(v1);
    final p2 = toScreen(v2);
    final pr = toScreen(sum.resultant);

    _drawAxes(canvas, center, half, canvasTheme.canvasBorder);

    // Parallelogram construction (dashed).
    final dashPaint = Paint()
      ..color = canvasTheme.resultantColor.withOpacity(0.5)
      ..strokeWidth = 1;
    _drawDashed(canvas, p1, pr, dashPaint);
    _drawDashed(canvas, pr, p2, dashPaint);

    _drawArrow(canvas, center, p1, canvasTheme.arm1Color, 'A₁', canvasTheme.arm1Color, bold: true);
    _drawArrow(canvas, center, p2, canvasTheme.arm2Color, 'A₂', canvasTheme.arm2Color, bold: true);
    _drawArrow(canvas, center, pr, canvasTheme.resultantColor, 'R', canvasTheme.resultantColor, bold: true);

    canvas.drawCircle(center, 3, Paint()..color = canvasTheme.canvasBorder);
  }

  @override
  bool shouldRepaint(CalcVectorPainter old) =>
      old.v1.x != v1.x || old.v1.y != v1.y || old.v2.x != v2.x || old.v2.y != v2.y;
}

// ── Rotation Matrix ──────────────────────────────────────────────────────────

class CalcRotationPainter extends CustomPainter {
  final calc.Vec2 vIn;
  final calc.Vec2 vOut;
  final RadianCanvasTheme canvasTheme;
  final Color mutedColor;

  const CalcRotationPainter({
    required this.vIn,
    required this.vOut,
    required this.canvasTheme,
    required this.mutedColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final half = size.shortestSide / 2 * 0.9;
    final maxDim = size.shortestSide / 2 * 0.75;

    final maxMag = [1e-3, calc.vecMagnitude(vIn), calc.vecMagnitude(vOut)].reduce(math.max);
    final scale = maxDim / maxMag;

    Offset toScreen(calc.Vec2 v) => center + Offset(v.x * scale, -v.y * scale);
    final pIn = toScreen(vIn);
    final pOut = toScreen(vOut);

    _drawAxes(canvas, center, half, canvasTheme.canvasBorder);

    _drawArrow(canvas, center, pIn, mutedColor, 'v', mutedColor, opacity: 0.55, strokeWidth: 2.5);
    _drawArrow(canvas, center, pOut, canvasTheme.arm2Color, 'v′', canvasTheme.arm2Color, bold: true);

    canvas.drawCircle(center, 3, Paint()..color = canvasTheme.canvasBorder);
  }

  @override
  bool shouldRepaint(CalcRotationPainter old) =>
      old.vIn.x != vIn.x || old.vIn.y != vIn.y || old.vOut.x != vOut.x || old.vOut.y != vOut.y;
}

// ── Polygon Angles ───────────────────────────────────────────────────────────

class CalcPolygonPainter extends CustomPainter {
  final int sides;
  final RadianCanvasTheme canvasTheme;

  const CalcPolygonPainter({required this.sides, required this.canvasTheme});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2 * 0.75;

    final verts = calc
        .polygonVertices(sides.toDouble(), r, cx: center.dx, cy: center.dy)
        .map((v) => Offset(v.x, v.y))
        .toList();

    final path = Path()..addPolygon(verts, true);
    canvas.drawPath(
      path,
      Paint()..color = canvasTheme.resultantColor.withOpacity(0.08),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = canvasTheme.resultantColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );

    // Highlighted interior-angle wedge at vertex 0.
    final n = verts.length;
    final v0 = verts[0];
    final prev = verts[(n - 1) % n];
    final next = verts[1 % n];
    Offset armTo(Offset p, double t) => v0 + (p - v0) * t;
    final wedgePath = Path()
      ..moveTo(armTo(prev, 0.35).dx, armTo(prev, 0.35).dy)
      ..lineTo(v0.dx, v0.dy)
      ..lineTo(armTo(next, 0.35).dx, armTo(next, 0.35).dy);
    canvas.drawPath(
      wedgePath,
      Paint()
        ..color = canvasTheme.positiveColor
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );

    for (final v in verts) {
      canvas.drawCircle(v, 2.5, Paint()..color = canvasTheme.resultantColor);
    }
    canvas.drawCircle(v0, 4, Paint()..color = canvasTheme.positiveColor);
  }

  @override
  bool shouldRepaint(CalcPolygonPainter old) => old.sides != sides;
}

// ── Dashed line helper ───────────────────────────────────────────────────────

void _drawDashed(Canvas canvas, Offset p1, Offset p2, Paint paint,
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

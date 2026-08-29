// ─────────────────────────────────────────────────────────────────────────────
// polygon_painter.dart
// CustomPainter for Mode 4 — regular N-gon, highlighted vertex, angle arcs
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math';
import 'package:flutter/material.dart';
import '../app_theme.dart';

class PolygonPainter extends CustomPainter {
  final int    n;          // polygon sides (3–12)
  final double armAngle;   // arm angle in degrees (snapped by firmware)
  final RadianCanvasTheme canvasTheme;

  PolygonPainter({
    required this.n,
    required this.armAngle,
    required this.canvasTheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width  / 2;
    final cy = size.height / 2;
    final r  = min(cx, cy) * 0.72;

    final step = 2 * pi / n;

    // Vertices — vertex 0 at angle 0 (east), counter-clockwise
    final vertices = List<Offset>.generate(n, (i) {
      final a = i * step;
      return Offset(cx + r * cos(a), cy - r * sin(a));
    });

    // Which vertex is the arm snapped to
    final snappedIndex =
        ((armAngle / 360.0) * n).round() % n;
    final current = vertices[snappedIndex];

    // ── Paints ────────────────────────────────────────────────────────────────

    final circlePaint = Paint()
      ..color = canvasTheme.gridLine
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final polyPaint = Paint()
      ..color = canvasTheme.arm1Color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final polyFillPaint = Paint()
      ..color = canvasTheme.arm1Color.withOpacity(0.06)
      ..style = PaintingStyle.fill;

    final radiusPaint = Paint()
      ..color = canvasTheme.arm2Color.withOpacity(0.4)
      ..strokeWidth = 1.0;

    final centralPaint = Paint()
      ..color = canvasTheme.resultantColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final centralFillPaint = Paint()
      ..color = canvasTheme.resultantColor.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    final vertexPaint = Paint()
      ..color = canvasTheme.arm1Color
      ..style = PaintingStyle.fill;

    // ── Circumscribed circle ─────────────────────────────────────────────────
    canvas.drawCircle(Offset(cx, cy), r, circlePaint);

    // ── Polygon fill + outline ───────────────────────────────────────────────
    final polyPath = Path()..moveTo(vertices[0].dx, vertices[0].dy);
    for (int i = 1; i < n; i++) {
      polyPath.lineTo(vertices[i].dx, vertices[i].dy);
    }
    polyPath.close();
    canvas.drawPath(polyPath, polyFillPaint);
    canvas.drawPath(polyPath, polyPaint);

    // ── Radii (faint) ────────────────────────────────────────────────────────
    for (final v in vertices) {
      canvas.drawLine(Offset(cx, cy), v, radiusPaint);
    }

    // ── Central angle wedge (center → current vertex → next vertex) ──────────
    final a0 = snappedIndex * step;
    final centralRect =
        Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.36);
    // Screen-space sweep: counter-clockwise in math = negative in canvas
    canvas.drawArc(centralRect, -a0, -step, true, centralFillPaint);
    canvas.drawArc(centralRect, -a0, -step, false, centralPaint);

    // ── Interior angle arcs at each vertex ───────────────────────────────────
    final interiorPaint = Paint()
      ..color = canvasTheme.arm2Color.withOpacity(0.6)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < n; i++) {
      final v    = vertices[i];
      final prev = vertices[(i - 1 + n) % n];
      final next = vertices[(i + 1) % n];

      final aPrev = atan2(prev.dy - v.dy, prev.dx - v.dx);
      final aNext = atan2(next.dy - v.dy, next.dx - v.dx);

      var sweep = aNext - aPrev;
      // normalize to interior side
      while (sweep <= -pi) sweep += 2 * pi;
      while (sweep >   pi) sweep -= 2 * pi;

      final arcRect = Rect.fromCircle(center: v, radius: 14);
      canvas.drawArc(arcRect, aPrev, sweep, false, interiorPaint);
    }

    // ── Vertex dots ──────────────────────────────────────────────────────────
    for (int i = 0; i < n; i++) {
      final isCurrent = i == snappedIndex;
      if (isCurrent) {
        canvas.drawCircle(vertices[i], 12,
            Paint()..color = canvasTheme.arm1Color.withOpacity(0.2));
        canvas.drawCircle(vertices[i], 7, vertexPaint);
      } else {
        canvas.drawCircle(vertices[i], 4,
            Paint()..color = canvasTheme.arm1Color.withOpacity(0.6));
      }
    }

    // ── Center dot ───────────────────────────────────────────────────────────
    canvas.drawCircle(
        Offset(cx, cy), 5, Paint()..color = canvasTheme.canvasBorder);

    // ── Labels ────────────────────────────────────────────────────────────────
    // Central angle label at wedge midpoint
    final midAngle = a0 + step / 2;
    final labelPos = Offset(
      cx + r * 0.5 * cos(midAngle),
      cy - r * 0.5 * sin(midAngle),
    );
    _drawLabel(canvas, '${(360 / n).toStringAsFixed(0)}°', labelPos,
        canvasTheme.resultantColor);

    // Polygon name below center
    _drawLabel(canvas, _polygonName(n), Offset(cx, cy + r + 24),
        canvasTheme.canvasBorder, fontSize: 13);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _polygonName(int n) {
    switch (n) {
      case 3:  return 'Equilateral Triangle';
      case 4:  return 'Square';
      case 5:  return 'Regular Pentagon';
      case 6:  return 'Regular Hexagon';
      case 7:  return 'Regular Heptagon';
      case 8:  return 'Regular Octagon';
      case 9:  return 'Regular Nonagon';
      case 10: return 'Regular Decagon';
      case 11: return 'Regular Hendecagon';
      case 12: return 'Regular Dodecagon';
      default: return 'Regular $n-gon';
    }
  }

  void _drawLabel(Canvas canvas, String text, Offset position, Color color,
      {double fontSize = 12}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color:      color,
          fontSize:   fontSize,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas,
        Offset(position.dx - tp.width / 2, position.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(PolygonPainter old) =>
      old.n != n || old.armAngle != armAngle;
}

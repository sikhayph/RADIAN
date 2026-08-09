// ─────────────────────────────────────────────────────────────────────────────
// rotation_matrix_painter.dart
// CustomPainter for Mode 3 — rotation matrix, original + transformed vector
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math';
import 'package:flutter/material.dart';
import '../../app_theme.dart';

class RotationMatrixPainter extends CustomPainter {
  final double theta;   // rotation angle in degrees (arm 1)
  final double a2;      // original vector angle in degrees (arm 2)
  final double vxp;     // transformed x component
  final double vyp;     // transformed y component
  final RadianCanvasTheme canvasTheme;

  RotationMatrixPainter({
    required this.theta,
    required this.a2,
    required this.vxp,
    required this.vyp,
    required this.canvasTheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx   = size.width  / 2;
    final cy   = size.height / 2;
    final unit = min(cx, cy) * 0.78;

    final rad2 = a2 * pi / 180.0;

    // Original vector (arm 2)
    final vOrig = Offset(cx + unit * cos(rad2), cy - unit * sin(rad2));
    // Transformed vector — from firmware-computed components
    final vTrans = Offset(cx + unit * vxp, cy - unit * vyp);

    // ── Paints ────────────────────────────────────────────────────────────────

    final circlePaint = Paint()
      ..color = canvasTheme.gridLine
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final axisPaint = Paint()
      ..color = canvasTheme.canvasBorder.withOpacity(0.6)
      ..strokeWidth = 1.0;

    final origPaint = Paint()
      ..color = canvasTheme.arm2Color.withOpacity(0.45)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final transPaint = Paint()
      ..color = canvasTheme.arm1Color
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    final arcPaint = Paint()
      ..color = canvasTheme.resultantColor.withOpacity(0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final arcFillPaint = Paint()
      ..color = canvasTheme.resultantColor.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    // ── Reference circle + axes ───────────────────────────────────────────────
    canvas.drawCircle(Offset(cx, cy), unit, circlePaint);
    canvas.drawLine(
        Offset(cx - unit - 16, cy), Offset(cx + unit + 16, cy), axisPaint);
    canvas.drawLine(
        Offset(cx, cy - unit - 16), Offset(cx, cy + unit + 16), axisPaint);

    // ── Rotation arc from original to transformed ────────────────────────────
    // Angles in screen space (drawArc measures clockwise from +x axis)
    final startAngle = -rad2;
    final sweep      = -(theta * pi / 180.0);
    final arcRadius  = unit * 0.45;
    final arcRect    = Rect.fromCircle(
        center: Offset(cx, cy), radius: arcRadius);

    canvas.drawArc(arcRect, startAngle, sweep, true, arcFillPaint);
    canvas.drawArc(arcRect, startAngle, sweep, false, arcPaint);

    // Arc arrowhead at the end of the sweep
    final endAngle = startAngle + sweep;
    final arcEnd = Offset(
      cx + arcRadius * cos(endAngle),
      cy + arcRadius * sin(endAngle),
    );
    // Tangent direction at end of arc (perpendicular to radius, sweep direction)
    final tangent = endAngle + (sweep < 0 ? -pi / 2 : pi / 2);
    _drawArrowHead(canvas, arcEnd, tangent,
        Paint()..color = canvasTheme.resultantColor, 8);

    // ── Ghost trail (three fading positions between orig and trans) ──────────
    for (int i = 1; i <= 3; i++) {
      final f = i / 4.0;
      final ghostAngle = rad2 + (theta * pi / 180.0) * f;
      final ghost = Offset(
        cx + unit * cos(ghostAngle),
        cy - unit * sin(ghostAngle),
      );
      canvas.drawLine(
        Offset(cx, cy), ghost,
        Paint()
          ..color = canvasTheme.arm1Color.withOpacity(0.08 + 0.06 * i)
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round,
      );
    }

    // ── Vectors ───────────────────────────────────────────────────────────────
    // Original (muted, behind)
    _drawArrow(canvas, Offset(cx, cy), vOrig, origPaint, 9);
    // Transformed (bright, in front)
    _drawArrow(canvas, Offset(cx, cy), vTrans, transPaint, 11);

    // ── Origin ────────────────────────────────────────────────────────────────
    canvas.drawCircle(
        Offset(cx, cy), 5, Paint()..color = canvasTheme.canvasBorder);

    // ── Tip glow on transformed ───────────────────────────────────────────────
    canvas.drawCircle(vTrans, 9,
        Paint()..color = canvasTheme.arm1Color.withOpacity(0.2));
    canvas.drawCircle(vTrans, 5,
        Paint()..color = canvasTheme.arm1Color);

    // ── Labels ────────────────────────────────────────────────────────────────
    _drawLabel(canvas, 'v', _labelPos(Offset(cx, cy), vOrig, 16),
        canvasTheme.arm2Color);
    _drawLabel(canvas, "v'", _labelPos(Offset(cx, cy), vTrans, 18),
        canvasTheme.arm1Color);

    // θ label at arc midpoint
    final midAngle = startAngle + sweep / 2;
    final thetaPos = Offset(
      cx + (arcRadius + 16) * cos(midAngle),
      cy + (arcRadius + 16) * sin(midAngle),
    );
    _drawLabel(canvas, 'θ', thetaPos, canvasTheme.resultantColor);
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
    _drawArrowHead(canvas, to, angle,
        Paint()..color = paint.color..style = PaintingStyle.fill, headSize);
  }

  void _drawArrowHead(
      Canvas canvas, Offset tip, double angle, Paint paint, double size) {
    const headAngle = 0.45;
    final p1 = Offset(
      tip.dx - size * cos(angle - headAngle),
      tip.dy - size * sin(angle - headAngle),
    );
    final p2 = Offset(
      tip.dx - size * cos(angle + headAngle),
      tip.dy - size * sin(angle + headAngle),
    );
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();
    canvas.drawPath(path, paint..style = PaintingStyle.fill);
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
    tp.paint(canvas,
        Offset(position.dx - tp.width / 2, position.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(RotationMatrixPainter old) =>
      old.theta != theta || old.a2 != a2 ||
      old.vxp != vxp || old.vyp != vyp;
}

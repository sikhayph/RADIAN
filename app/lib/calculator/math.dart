// ─────────────────────────────────────────────────────────────────────────────
// lib/calculator/math.dart
// Pure math for the Calculator mode's four tabs. Direct port of the website's
// website/lib/calculator/math.ts — every function takes numbers and returns
// numbers/objects, no side effects, so it stays a 1:1 mirror of the TS source.
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;

const double tau = math.pi * 2;

// ── Angle conversion ─────────────────────────────────────────────────────────

double degToRad(double deg) => (deg * math.pi) / 180;

double radToDeg(double rad) => (rad * 180) / math.pi;

/// Wrap an angle in degrees to [0, 360).
double normalizeDeg(double deg) => ((deg % 360) + 360) % 360;

const String _greekPi = 'π';

/// Express [deg] degrees as an exact multiple of π radians when it lands on a
/// "nice" denominator (2..12), otherwise fall back to a decimal.
/// 90 → "π/2", 180 → "π", 270 → "3π/2", 45 → "π/4", 123 → "0.6833π".
String toPiFraction(double deg) {
  final ratio = deg / 180; // multiples of π
  if (ratio == 0) return '0';

  final sign = ratio < 0 ? '-' : '';
  final abs = ratio.abs();

  for (int denom = 1; denom <= 12; denom++) {
    final num = abs * denom;
    if ((num - num.round()).abs() < 1e-9) {
      final n = num.round();
      final numPart = n == 1 ? _greekPi : '$n$_greekPi';
      return denom == 1 ? '$sign$numPart' : '$sign$numPart/$denom';
    }
  }
  return '${ratio.toStringAsFixed(4)}$_greekPi';
}

// ── Vectors ──────────────────────────────────────────────────────────────────

class Vec2 {
  final double x;
  final double y;
  const Vec2(this.x, this.y);
}

Vec2 fromPolar(double magnitude, double angleDeg) {
  final r = degToRad(angleDeg);
  return Vec2(magnitude * math.cos(r), magnitude * math.sin(r));
}

double vecMagnitude(Vec2 v) => math.sqrt(v.x * v.x + v.y * v.y);

/// Angle of a vector in degrees, [0, 360). Returns 0 for the zero vector.
double vecAngleDeg(Vec2 v) {
  if (v.x == 0 && v.y == 0) return 0;
  return normalizeDeg(radToDeg(math.atan2(v.y, v.x)));
}

class VectorSum {
  final Vec2 resultant;
  final double magnitude;
  final double angleDeg;
  const VectorSum({required this.resultant, required this.magnitude, required this.angleDeg});
}

VectorSum addVectors(Vec2 a, Vec2 b) {
  final resultant = Vec2(a.x + b.x, a.y + b.y);
  return VectorSum(
    resultant: resultant,
    magnitude: vecMagnitude(resultant),
    angleDeg: vecAngleDeg(resultant),
  );
}

// ── Rotation ─────────────────────────────────────────────────────────────────

/// The 2×2 rotation matrix, row-major: [[a, b], [c, d]].
class Mat2 {
  final double a, b, c, d;
  const Mat2(this.a, this.b, this.c, this.d);
}

class RotationResult {
  final Vec2 out;
  final Mat2 matrix;
  const RotationResult({required this.out, required this.matrix});
}

RotationResult rotateVec(Vec2 v, double angleDeg) {
  final t = degToRad(angleDeg);
  final cos = math.cos(t);
  final sin = math.sin(t);
  return RotationResult(
    out: Vec2(v.x * cos - v.y * sin, v.x * sin + v.y * cos),
    matrix: Mat2(cos, -sin, sin, cos),
  );
}

// ── Polygons ─────────────────────────────────────────────────────────────────

class PolygonAngles {
  final int sides;
  /// One interior angle of a regular n-gon, degrees.
  final double interior;
  /// One exterior angle, degrees.
  final double exterior;
  /// Sum of all interior angles, degrees.
  final double interiorSum;
  /// Central angle subtended by one side, degrees.
  final double central;
  const PolygonAngles({
    required this.sides,
    required this.interior,
    required this.exterior,
    required this.interiorSum,
    required this.central,
  });
}

PolygonAngles polygonAngles(double sides) {
  final n = math.max(3, sides.round());
  return PolygonAngles(
    sides: n,
    interior: ((n - 2) * 180) / n,
    exterior: 360 / n,
    interiorSum: ((n - 2) * 180).toDouble(),
    central: 360 / n,
  );
}

/// Vertices of a regular n-gon inscribed in a circle of radius [r] centered at
/// (cx, cy), first vertex at the top. Uses screen coordinates (+y down).
List<Vec2> polygonVertices(double sides, double r, {double cx = 0, double cy = 0}) {
  final n = math.max(3, sides.round());
  final verts = <Vec2>[];
  for (int i = 0; i < n; i++) {
    final a = -math.pi / 2 + (i * tau) / n;
    verts.add(Vec2(cx + r * math.cos(a), cy + r * math.sin(a)));
  }
  return verts;
}

// ── Formatting ───────────────────────────────────────────────────────────────

/// Trim a float to at most [dp] decimals, dropping trailing zeros.
String fmt(double n, [int dp = 3]) {
  if (!n.isFinite) return '—';
  final factor = math.pow(10, dp);
  final rounded = (n * factor).round() / factor;
  // Match JS `String(Number(n.toFixed(dp)))` — trims trailing zeros/decimal point.
  var s = rounded.toStringAsFixed(dp);
  if (s.contains('.')) {
    s = s.replaceFirst(RegExp(r'0+$'), '');
    s = s.replaceFirst(RegExp(r'\.$'), '');
  }
  if (s == '-0') s = '0';
  return s;
}

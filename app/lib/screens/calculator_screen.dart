// ─────────────────────────────────────────────────────────────────────────────
// calculator_screen.dart  –  Mode 5: Calculator
// Native port of website/app/calculator (CalculatorClient.tsx + the four
// components/calculator/*Panel.tsx) — same four tabs, same math
// (lib/calculator/math.dart is a 1:1 port of website/lib/calculator/math.ts),
// styled with the obsidian theme tokens. Fully local state — no BLE, no
// providers, works offline.
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../calculator/math.dart' as calc;
import '../widgets/painters/calculator_painters.dart';
import '../widgets/painters/unit_circle_painter.dart';
import 'calculator_controls.dart';
import 'screen_widgets.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  int _active = 0;

  static const _tabs = [
    (n: 1, label: 'Degree / Radian'),
    (n: 2, label: 'Vector Addition'),
    (n: 3, label: 'Rotation Matrix'),
    (n: 4, label: 'Polygon Angles'),
  ];

  Color _accentFor(int index, ThemeData theme, RadianCanvasTheme canvas) {
    switch (index) {
      case 0: return theme.colorScheme.primary;
      case 1: return canvas.arm1Color;
      case 2: return canvas.arm2Color;
      default: return canvas.resultantColor;
    }
  }

  Widget _activePanel() {
    switch (_active) {
      case 0: return const _DegreeRadianTab();
      case 1: return const _VectorTab();
      case 2: return const _RotationTab();
      default: return const _PolygonTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ui = theme.extension<RadianUiTheme>()!;
    final canvas = theme.extension<RadianCanvasTheme>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ModeTitle(modeLabel: 'MODE 05', title: 'OFFLINE CALCULATOR'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Tab bar ────────────────────────────────────────────
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(_tabs.length, (i) {
                        final tab = _tabs[i];
                        final accent = _accentFor(i, theme, canvas);
                        final selected = _active == i;
                        return InkWell(
                          onTap: () => setState(() => _active = i),
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected ? theme.colorScheme.primary : ui.border,
                              ),
                              color: selected
                                  ? theme.colorScheme.primary.withOpacity(0.12)
                                  : Colors.transparent,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: accent.withOpacity(0.15),
                                  ),
                                  child: Text('${tab.n}',
                                      style: TextStyle(
                                        color: accent,
                                        fontFamily: 'JetBrainsMono',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      )),
                                ),
                                const SizedBox(width: 8),
                                Text(tab.label,
                                    style: theme.textTheme.bodyMedium!.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: selected ? ui.textPrimary : ui.textSecondary,
                                    )),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 20),

                    // ── Active panel ───────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: ui.surface.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ui.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _accentFor(_active, theme, canvas).withOpacity(0.15),
                                ),
                                child: Text('${_active + 1}',
                                    style: TextStyle(
                                      color: _accentFor(_active, theme, canvas),
                                      fontFamily: 'JetBrainsMono',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    )),
                              ),
                              const SizedBox(width: 12),
                              Text(_tabs[_active].label,
                                  style: theme.textTheme.titleMedium),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _activePanel(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Tab 1: Degree / Radian ───────────────────────────────────────────────────

enum _Dir { deg2rad, rad2deg }

class _DegreeRadianTab extends StatefulWidget {
  const _DegreeRadianTab();

  @override
  State<_DegreeRadianTab> createState() => _DegreeRadianTabState();
}

class _DegreeRadianTabState extends State<_DegreeRadianTab> {
  _Dir _dir = _Dir.deg2rad;
  double _input = 45;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ui = theme.extension<RadianUiTheme>()!;
    final canvas = theme.extension<RadianCanvasTheme>()!;

    final deg = _dir == _Dir.deg2rad ? _input : calc.radToDeg(_input);
    final rad = _dir == _Dir.deg2rad ? calc.degToRad(_input) : _input;
    final theta = calc.normalizeDeg(deg);
    final degRad = calc.degToRad(deg);
    final sin = math.sin(degRad), cos = math.cos(degRad);
    final tan = cos == 0 ? double.nan : sin / cos;

    return CalcTwoColumn(
      controls: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalcSegmented<_Dir>(
            label: 'Direction',
            value: _dir,
            onChanged: (v) => setState(() => _dir = v),
            options: const [
              (_Dir.deg2rad, 'Degrees → Radians'),
              (_Dir.rad2deg, 'Radians → Degrees'),
            ],
          ),
          const SizedBox(height: 18),
          CalcNumberField(
            label: _dir == _Dir.deg2rad ? 'Angle in degrees' : 'Angle in radians',
            value: _input,
            step: _dir == _Dir.deg2rad ? 15 : 0.1,
            suffix: _dir == _Dir.deg2rad ? '°' : 'rad',
            onChanged: (v) => setState(() => _input = v),
          ),
          const SizedBox(height: 18),
          CalcReadout(items: [
            (
              label: _dir == _Dir.deg2rad ? 'Radians' : 'Degrees',
              value: _dir == _Dir.deg2rad ? calc.fmt(rad, 4) : '${calc.fmt(deg, 3)}°',
              accent: true,
            ),
            (label: 'Exact', value: calc.toPiFraction(deg), accent: false),
            (label: 'sin θ', value: calc.fmt(sin, 4), accent: false),
            (label: 'cos θ', value: calc.fmt(cos, 4), accent: false),
            (label: 'tan θ', value: tan.isNaN ? 'undefined' : calc.fmt(tan, 4), accent: false),
            (label: 'Reference', value: '${calc.fmt(theta, 2)}°', accent: false),
          ]),
        ],
      ),
      figure: CalcFigureCard(
        caption: '${calc.fmt(theta, 1)}°  ·  ${calc.fmt(calc.degToRad(theta), 4)} rad',
        child: CustomPaint(
          painter: UnitCirclePainter(
            angleDeg: theta,
            cosVal: cos,
            sinVal: sin,
            canvasTheme: canvas,
            textColor: ui.textPrimary,
          ),
        ),
      ),
    );
  }
}

// ── Tab 2: Vector Addition ───────────────────────────────────────────────────

class _VectorTab extends StatefulWidget {
  const _VectorTab();

  @override
  State<_VectorTab> createState() => _VectorTabState();
}

class _VectorTabState extends State<_VectorTab> {
  double _m1 = 1, _a1 = 30, _m2 = 1, _a2 = 110;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canvas = theme.extension<RadianCanvasTheme>()!;

    final v1 = calc.fromPolar(_m1, _a1);
    final v2 = calc.fromPolar(_m2, _a2);
    final sum = calc.addVectors(v1, v2);

    return CalcTwoColumn(
      controls: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
                child: CalcNumberField(
                    label: 'Vector 1 · magnitude', value: _m1, step: 0.5, min: 0,
                    onChanged: (v) => setState(() => _m1 = v))),
            const SizedBox(width: 16),
            Expanded(
                child: CalcNumberField(
                    label: 'Vector 1 · angle', value: _a1, step: 15, suffix: '°',
                    onChanged: (v) => setState(() => _a1 = v))),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
                child: CalcNumberField(
                    label: 'Vector 2 · magnitude', value: _m2, step: 0.5, min: 0,
                    onChanged: (v) => setState(() => _m2 = v))),
            const SizedBox(width: 16),
            Expanded(
                child: CalcNumberField(
                    label: 'Vector 2 · angle', value: _a2, step: 15, suffix: '°',
                    onChanged: (v) => setState(() => _a2 = v))),
          ]),
          const SizedBox(height: 18),
          CalcReadout(items: [
            (label: 'Resultant x', value: calc.fmt(sum.resultant.x, 3), accent: false),
            (label: 'Resultant y', value: calc.fmt(sum.resultant.y, 3), accent: false),
            (label: 'Magnitude', value: calc.fmt(sum.magnitude, 3), accent: true),
            (label: 'Angle', value: '${calc.fmt(sum.angleDeg, 2)}°', accent: true),
          ]),
        ],
      ),
      figure: CalcFigureCard(
        caption: 'Arm 1 + Arm 2 → resultant (parallelogram)',
        child: CustomPaint(
          painter: CalcVectorPainter(v1: v1, v2: v2, sum: sum, canvasTheme: canvas),
        ),
      ),
    );
  }
}

// ── Tab 3: Rotation Matrix ───────────────────────────────────────────────────

class _RotationTab extends StatefulWidget {
  const _RotationTab();

  @override
  State<_RotationTab> createState() => _RotationTabState();
}

class _RotationTabState extends State<_RotationTab> {
  double _x = 1, _y = 0.5, _angle = 45;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ui = theme.extension<RadianUiTheme>()!;
    final canvas = theme.extension<RadianCanvasTheme>()!;

    final input = calc.Vec2(_x, _y);
    final rotation = calc.rotateVec(input, _angle);
    final out = rotation.out;
    final m = rotation.matrix;

    return CalcTwoColumn(
      controls: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
                child: CalcNumberField(
                    label: 'Vector x', value: _x, step: 0.5,
                    onChanged: (v) => setState(() => _x = v))),
            const SizedBox(width: 16),
            Expanded(
                child: CalcNumberField(
                    label: 'Vector y', value: _y, step: 0.5,
                    onChanged: (v) => setState(() => _y = v))),
          ]),
          const SizedBox(height: 16),
          CalcNumberField(
              label: 'Rotation angle θ', value: _angle, step: 15, suffix: '°',
              onChanged: (v) => setState(() => _angle = v)),
          const SizedBox(height: 18),

          // Live rotation matrix.
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: ui.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ui.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('R(θ) · v',
                    style: theme.textTheme.bodyMedium!.copyWith(
                        color: ui.textFaint, fontSize: 10.5, letterSpacing: 1.0)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('[', style: TextStyle(fontSize: 26, color: ui.textFaint)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(children: [
                          _MatrixCell(calc.fmt(m.a, 4)),
                          const SizedBox(width: 16),
                          _MatrixCell(calc.fmt(m.b, 4)),
                        ]),
                        const SizedBox(height: 4),
                        Row(children: [
                          _MatrixCell(calc.fmt(m.c, 4)),
                          const SizedBox(width: 16),
                          _MatrixCell(calc.fmt(m.d, 4)),
                        ]),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Text(']', style: TextStyle(fontSize: 26, color: ui.textFaint)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('[[cos θ, −sin θ], [sin θ, cos θ]]',
                    style: theme.textTheme.bodyMedium!.copyWith(color: ui.textFaint, fontSize: 11)),
              ],
            ),
          ),

          const SizedBox(height: 18),
          CalcReadout(items: [
            (label: "Rotated x'", value: calc.fmt(out.x, 3), accent: true),
            (label: "Rotated y'", value: calc.fmt(out.y, 3), accent: true),
            (label: 'Magnitude', value: calc.fmt(calc.vecMagnitude(out), 3), accent: false),
            (label: 'Angle', value: '${calc.fmt(calc.vecAngleDeg(out), 2)}°', accent: false),
          ]),
        ],
      ),
      figure: CalcFigureCard(
        caption: 'rotated by ${calc.fmt(_angle, 1)}°',
        child: CustomPaint(
          painter: CalcRotationPainter(
              vIn: input, vOut: out, canvasTheme: canvas, mutedColor: ui.textFaint),
        ),
      ),
    );
  }
}

class _MatrixCell extends StatelessWidget {
  final String text;
  const _MatrixCell(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 60,
      child: Text(text,
          textAlign: TextAlign.center,
          style: theme.textTheme.displayMedium!.copyWith(fontSize: 13)),
    );
  }
}

// ── Tab 4: Polygon Angles ────────────────────────────────────────────────────

class _PolygonTab extends StatefulWidget {
  const _PolygonTab();

  @override
  State<_PolygonTab> createState() => _PolygonTabState();
}

class _PolygonTabState extends State<_PolygonTab> {
  int _sides = 6;

  static const _minSides = 3;
  static const _maxSides = 20;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ui = theme.extension<RadianUiTheme>()!;
    final canvas = theme.extension<RadianCanvasTheme>()!;

    final a = calc.polygonAngles(_sides.toDouble());

    return CalcTwoColumn(
      controls: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalcRangeField(
            label: 'Number of sides',
            value: _sides,
            min: _minSides,
            max: _maxSides,
            onChanged: (v) => setState(() => _sides = v.clamp(_minSides, _maxSides)),
          ),
          const SizedBox(height: 18),
          CalcReadout(items: [
            (label: 'Interior angle', value: '${calc.fmt(a.interior, 2)}°', accent: true),
            (label: 'Exterior angle', value: '${calc.fmt(a.exterior, 2)}°', accent: true),
            (label: 'Interior sum', value: '${calc.fmt(a.interiorSum, 0)}°', accent: false),
            (label: 'Central angle', value: '${calc.fmt(a.central, 2)}°', accent: false),
          ]),
          const SizedBox(height: 14),
          Text(
            'Regular ${a.sides}-gon: interior = (n−2)·180 / n, exterior = 360 / n, and the '
            'interior angles sum to (n−2)·180.',
            style: theme.textTheme.bodyMedium!.copyWith(color: ui.textSecondary, fontSize: 12, height: 1.5),
          ),
        ],
      ),
      figure: CalcFigureCard(
        caption: 'regular ${a.sides}-gon',
        child: CustomPaint(
          painter: CalcPolygonPainter(sides: a.sides, canvasTheme: canvas),
        ),
      ),
    );
  }
}

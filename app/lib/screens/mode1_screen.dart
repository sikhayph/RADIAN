// ─────────────────────────────────────────────────────────────────────────────
// mode1_screen.dart  –  Mode 1: Degree / Radian Conversion
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_theme.dart';
import '../providers/providers.dart';
import '../widgets/painters/unit_circle_painter.dart';
import 'screen_widgets.dart';

class Mode1Screen extends ConsumerWidget {
  const Mode1Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packetAsync = ref.watch(packetStreamProvider);
    final last        = ref.watch(lastPacketProvider);
    final theme       = Theme.of(context);
    final canvas      = theme.extension<RadianCanvasTheme>()!;

    final packet = packetAsync.whenOrNull(data: (p) => p) ?? last;

    final deg    = packet.a1;
    final rad    = deg * math.pi / 180.0;
    final cosVal = math.cos(rad);
    final sinVal = math.sin(rad);

    final displayRad = packet.mode == 1 && packet.val.rad != 0.0 ? packet.val.rad : rad;
    final displayCos = packet.mode == 1 ? packet.val.rx : cosVal;
    final displaySin = packet.mode == 1 ? packet.val.ry : sinVal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ModeTitle(modeLabel: 'MODE 01', title: 'DEGREE / RADIAN CONVERSION'),

        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: CustomPaint(
                  painter: UnitCirclePainter(
                    angleDeg:    deg,
                    cosVal:      displayCos,
                    sinVal:      displaySin,
                    canvasTheme: canvas,
                    textColor:   theme.colorScheme.onSurface,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20, top: 10, bottom: 10),
                child: SizedBox(
                  width: 240,
                  child: SingleChildScrollView(
                    child: FloatingCard(
                      child: _DataPanel(deg: deg, rad: displayRad, cos: displayCos, sin: displaySin),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        FloatingFormulaBar(
          formula: 'θ(rad) = θ(deg) × π / 180',
          right: _PiFractionHint(deg: deg),
        ),
      ],
    );
  }
}

class _DataPanel extends StatelessWidget {
  final double deg, rad, cos, sin;
  const _DataPanel({required this.deg, required this.rad, required this.cos, required this.sin});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PanelHeader(label: 'CONVERSION', icon: '⋯'),
        const SizedBox(height: 16),
        const FieldLabel('ANGLE'),
        const SizedBox(height: 4),
        Text('${deg.toStringAsFixed(1)}°',
          style: theme.textTheme.displayMedium!.copyWith(color: VernierColors.navy,
              fontSize: 28, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text('${rad.toStringAsFixed(4)} rad',
          style: theme.textTheme.displayMedium!.copyWith(color: VernierColors.inkSoft, fontSize: 13)),

        const SizedBox(height: 20),
        Container(height: 1, color: VernierColors.line),
        const SizedBox(height: 20),

        const FieldLabel('TRIGONOMETRY'),
        const SizedBox(height: 12),
        _TrigRow('cos θ', cos.toStringAsFixed(4)),
        const SizedBox(height: 10),
        _TrigRow('sin θ', sin.toStringAsFixed(4)),
        const SizedBox(height: 10),
        const _TrigRow('|r|', '1.0000'),
      ],
    );
  }
}

class _TrigRow extends StatelessWidget {
  final String label, value;
  const _TrigRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium!.copyWith(color: VernierColors.inkSoft,
            fontSize: 11)),
        Text(value, style: theme.textTheme.displayMedium!.copyWith(color: VernierColors.navy,
            fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _PiFractionHint extends StatelessWidget {
  final double deg;
  const _PiFractionHint({required this.deg});

  static const Map<int, String> _piMap = {
    0: '0', 30: 'π/6', 45: 'π/4', 60: 'π/3', 90: 'π/2', 120: '2π/3',
    135: '3π/4', 150: '5π/6', 180: 'π', 210: '7π/6', 225: '5π/4', 240: '4π/3',
    270: '3π/2', 300: '5π/3', 315: '7π/4', 330: '11π/6', 360: '2π',
  };

  @override
  Widget build(BuildContext context) {
    final nearest  = deg.round() % 360;
    final fraction = _piMap[nearest];
    if (fraction == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Text('${deg.round()}° = $fraction',
      style: theme.textTheme.displayMedium!.copyWith(color: VernierColors.teal, fontSize: 10.5));
  }
}

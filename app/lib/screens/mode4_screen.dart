// ─────────────────────────────────────────────────────────────────────────────
// mode4_screen.dart  –  Mode 4: Polygon & Central Angle Snap
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_theme.dart';
import '../providers/providers.dart';
import '../widgets/painters/polygon_painter.dart';
import 'screen_widgets.dart';

class Mode4Screen extends ConsumerWidget {
  const Mode4Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packetAsync = ref.watch(packetStreamProvider);
    final last        = ref.watch(lastPacketProvider);
    final theme       = Theme.of(context);
    final canvas      = theme.extension<RadianCanvasTheme>()!;

    final packet   = packetAsync.whenOrNull(data: (p) => p) ?? last;
    final n        = packet.val.snap.clamp(3, 12);
    final interior = packet.val.interior != 0.0 ? packet.val.interior : ((n - 2) * 180.0) / n;
    final exterior = packet.val.exterior != 0.0 ? packet.val.exterior : 360.0 / n;
    final central  = 360.0 / n;
    final armAngle = packet.a1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ModeTitle(modeLabel: 'MODE 04', title: 'POLYGON & CENTRAL ANGLE SNAP'),

        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: CustomPaint(
                  painter: PolygonPainter(
                    n: n, armAngle: armAngle, canvasTheme: canvas,
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
                      child: _DataPanel(
                        n: n, interior: interior, exterior: exterior,
                        central: central, armAngle: armAngle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        FloatingFormulaBar(
          formula: '(N-2) × 180° = ${(n - 2) * 180}°  ·  sum of interior angles',
          right: Text('SNAPPED TO: ${armAngle.toStringAsFixed(1)}°',
            style: theme.textTheme.displayMedium!.copyWith(color: VernierColors.teal, fontSize: 10.5)),
        ),
      ],
    );
  }
}

class _DataPanel extends StatelessWidget {
  final int    n;
  final double interior, exterior, central, armAngle;
  const _DataPanel({
    required this.n, required this.interior, required this.exterior,
    required this.central, required this.armAngle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PanelHeader(label: 'POLYGON', icon: '⋯'),
        const SizedBox(height: 16),
        _StatRow(label: 'SIDES (N)', value: '$n', color: VernierColors.navy, large: true),
        const SizedBox(height: 16),
        Container(height: 1, color: VernierColors.line),
        const SizedBox(height: 16),
        _StatRow(label: 'INTERIOR ANGLE', value: '${interior.toStringAsFixed(1)}°', color: VernierColors.navy),
        const SizedBox(height: 14),
        _StatRow(label: 'EXTERIOR ANGLE', value: '${exterior.toStringAsFixed(1)}°', color: VernierColors.navy),
        const SizedBox(height: 14),
        _StatRow(label: 'CENTRAL ANGLE', value: '${central.toStringAsFixed(1)}°', color: VernierColors.amber),
      ],
    );
  }

  String _polygonName(int n) {
    switch (n) {
      case 3:  return 'Equilateral Triangle';
      case 4:  return 'Square';
      case 5:  return 'Pentagon';
      case 6:  return 'Hexagon';
      case 7:  return 'Heptagon';
      case 8:  return 'Octagon';
      case 9:  return 'Nonagon';
      case 10: return 'Decagon';
      case 11: return 'Hendecagon';
      case 12: return 'Dodecagon';
      default: return 'Regular $n-gon';
    }
  }
}

class _StatRow extends StatelessWidget {
  final String label, value;
  final Color color;
  final bool large;
  const _StatRow({required this.label, required this.value, required this.color, this.large = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium!.copyWith(color: VernierColors.inkFaint, fontSize: 9,
            fontWeight: FontWeight.w600, letterSpacing: 1.5)),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.displayMedium!.copyWith(color: color,
            fontSize: large ? 28.0 : 18.0, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

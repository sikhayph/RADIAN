// ─────────────────────────────────────────────────────────────────────────────
// mode2_screen.dart  –  Mode 2: Vector Addition
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_theme.dart';
import '../providers/providers.dart';
import '../widgets/painters/vector_diagram_painter.dart';
import 'screen_widgets.dart';

class Mode2Screen extends ConsumerWidget {
  const Mode2Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packet = ref.watch(lastPacketProvider);
    final theme  = Theme.of(context);
    final canvas = theme.extension<RadianCanvasTheme>()!;

    final a1   = packet.a1;
    final a2   = packet.a2;
    final rmag = packet.val.rmag;
    final rang = packet.val.rang;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ModeTitle(modeLabel: 'MODE 02', title: 'VECTOR ADDITION / R = v1 + v2'),

        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: VectorDiagramPainter(
                      a1: a1, a2: a2, rmag: rmag, rang: rang, canvasTheme: canvas,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20, top: 10, bottom: 10),
                child: SizedBox(
                  width: 240,
                  child: SingleChildScrollView(
                    child: _DataPanel(a1: a1, a2: a2, rmag: rmag, rang: rang),
                  ),
                ),
              ),
            ],
          ),
        ),

        FloatingFormulaBar(
          formula: 'R = v1 + v2  ·  |R| = √(Rx² + Ry²)',
          right: Text('SNAPPED TO: ${a1.toStringAsFixed(1)}°',
            style: theme.textTheme.displayMedium!.copyWith(color: VernierColors.teal, fontSize: 10.5)),
        ),
      ],
    );
  }
}

class _DataPanel extends StatelessWidget {
  final double a1, a2, rmag, rang;
  const _DataPanel({required this.a1, required this.a2, required this.rmag, required this.rang});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        FloatingCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PanelHeader(label: 'VECTORS', icon: '⋯'),
              const SizedBox(height: 14),
              _VectorRow(
                label: 'v1 — Arm 1',
                sublabel: '[ ${a1.toStringAsFixed(3)}, 0.000 ]',
                color: VernierColors.coral,
              ),
              const SizedBox(height: 10),
              _VectorRow(
                label: 'v2 — Arm 2',
                sublabel: a2 == 0.0 ? '[ 0.000, 1.000 ]' : '[ 0.000, ${a2.toStringAsFixed(3)} ]',
                color: VernierColors.teal,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FloatingCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PanelHeader(label: 'RESULTANT |R|', icon: '⋯'),
              const SizedBox(height: 8),
              Text(rmag.toStringAsFixed(2),
                style: theme.textTheme.displayMedium!.copyWith(color: VernierColors.amber,
                    fontSize: 28, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('∠ ${rang.toStringAsFixed(1)}°',
                style: theme.textTheme.displayMedium!.copyWith(color: VernierColors.inkSoft, fontSize: 13)),
              const SizedBox(height: 4),
              Text(a2 == 0.0 ? 'not detected' : '${a2.toStringAsFixed(1)}°',
                style: theme.textTheme.displayMedium!.copyWith(color: VernierColors.inkFaint, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}

class _VectorRow extends StatelessWidget {
  final String label, sublabel;
  final Color color;
  const _VectorRow({required this.label, required this.sublabel, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 9, height: 9,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(border: Border.all(color: color, width: 1.5)),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.bodyMedium!.copyWith(color: VernierColors.inkSoft,
                fontSize: 10)),
            const SizedBox(height: 2),
            Text(sublabel, style: theme.textTheme.displayMedium!.copyWith(color: VernierColors.inkFaint,
                fontSize: 10)),
          ],
        ),
      ],
    );
  }
}

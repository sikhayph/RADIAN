// ─────────────────────────────────────────────────────────────────────────────
// mode3_screen.dart  –  Mode 3: Rotation Matrix
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_theme.dart';
import '../providers/providers.dart';
import '../widgets/painters/rotation_matrix_painter.dart';
import 'screen_widgets.dart';

class Mode3Screen extends ConsumerWidget {
  const Mode3Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packetAsync = ref.watch(packetStreamProvider);
    final last        = ref.watch(lastPacketProvider);
    final theme       = Theme.of(context);
    final canvas      = theme.extension<RadianCanvasTheme>()!;

    final packet   = packetAsync.whenOrNull(data: (p) => p) ?? last;
    final theta    = packet.a1;
    final thetaRad = theta * math.pi / 180.0;
    final cosT     = math.cos(thetaRad);
    final sinT     = math.sin(thetaRad);
    final a2Deg    = packet.a2;
    final a2Rad    = a2Deg * math.pi / 180.0;
    final vxOrig   = math.cos(a2Rad);
    final vyOrig   = math.sin(a2Rad);
    final vxp      = packet.mode == 3 && packet.val.rx != 0.0
        ? packet.val.rx : cosT * vxOrig - sinT * vyOrig;
    final vyp      = packet.mode == 3 && packet.val.ry != 0.0
        ? packet.val.ry : sinT * vxOrig + cosT * vyOrig;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ModeTitle(modeLabel: 'MODE 03', title: 'ROTATION MATRIX'),

        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: CustomPaint(
                  painter: RotationMatrixPainter(
                    theta: theta, a2: a2Deg, vxp: vxp, vyp: vyp, canvasTheme: canvas,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20, top: 10, bottom: 10),
                child: SizedBox(
                  width: 240,
                  child: SingleChildScrollView(
                    child: _DataPanel(
                      theta: theta, cosT: cosT, sinT: sinT,
                      vx: vxOrig, vy: vyOrig, vxp: vxp, vyp: vyp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        FloatingFormulaBar(
          formula: "v' = R(θ) · v",
          right: Text('SNAPPED TO: ${theta.toStringAsFixed(1)}°',
            style: const TextStyle(color: VernierColors.teal, fontFamily: 'IBM Plex Mono', fontSize: 10.5)),
        ),
      ],
    );
  }
}

class _DataPanel extends StatelessWidget {
  final double theta, cosT, sinT, vx, vy, vxp, vyp;
  const _DataPanel({
    required this.theta, required this.cosT, required this.sinT,
    required this.vx, required this.vy, required this.vxp, required this.vyp,
  });

  @override
  Widget build(BuildContext context) {
    const matStyle = TextStyle(
      color: VernierColors.navy, fontFamily: 'IBM Plex Mono',
      fontSize: 13, fontWeight: FontWeight.w500,
    );

    return Column(
      children: [
        FloatingCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PanelHeader(label: "TRANSFORMED v'(x, y)", icon: '⋯'),
              const SizedBox(height: 8),
              Text('( ${vxp.toStringAsFixed(2)}, ${vyp.toStringAsFixed(2)} )',
                style: const TextStyle(color: VernierColors.coral, fontFamily: 'IBM Plex Mono',
                    fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('∠ ${theta.toStringAsFixed(1)}° ROTATION',
                style: const TextStyle(color: VernierColors.inkSoft, fontFamily: 'IBM Plex Mono', fontSize: 11)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FloatingCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PanelHeader(label: 'ROTATION MATRIX R(θ)', icon: '⋯'),
              const SizedBox(height: 10),
              IntrinsicWidth(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 4, height: 38,
                      decoration: const BoxDecoration(border: Border(
                        left:   BorderSide(color: VernierColors.inkSoft, width: 1.5),
                        top:    BorderSide(color: VernierColors.inkSoft, width: 1.5),
                        bottom: BorderSide(color: VernierColors.inkSoft, width: 1.5),
                      ))),
                    const SizedBox(width: 8),
                    Column(mainAxisSize: MainAxisSize.min, children: [
                      Row(children: [
                        SizedBox(width: 44, child: Text(cosT.toStringAsFixed(2), textAlign: TextAlign.center, style: matStyle)),
                        SizedBox(width: 44, child: Text((-sinT).toStringAsFixed(2), textAlign: TextAlign.center, style: matStyle)),
                      ]),
                      const SizedBox(height: 4),
                      Row(children: [
                        SizedBox(width: 44, child: Text(sinT.toStringAsFixed(2), textAlign: TextAlign.center, style: matStyle)),
                        SizedBox(width: 44, child: Text(cosT.toStringAsFixed(2), textAlign: TextAlign.center, style: matStyle)),
                      ]),
                    ]),
                    const SizedBox(width: 8),
                    Container(width: 4, height: 38,
                      decoration: const BoxDecoration(border: Border(
                        right:  BorderSide(color: VernierColors.inkSoft, width: 1.5),
                        top:    BorderSide(color: VernierColors.inkSoft, width: 1.5),
                        bottom: BorderSide(color: VernierColors.inkSoft, width: 1.5),
                      ))),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FloatingCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PanelHeader(label: 'ORIGINAL v(x, y)', icon: '⋯'),
              const SizedBox(height: 8),
              Text('( ${vx.toStringAsFixed(2)}, ${vy.toStringAsFixed(2)} )',
                style: const TextStyle(color: VernierColors.teal, fontFamily: 'IBM Plex Mono',
                    fontSize: 20, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

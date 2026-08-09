// ─────────────────────────────────────────────────────────────────────────────
// mode3_screen.dart
// Mode 3 — Rotation Matrix live visualizer
// Valiger — RADIAN Companion App
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_theme.dart';
import '../providers/providers.dart';
import '../ble/ble_manager.dart';
import '../widgets/painters/rotation_matrix_painter.dart';

class Mode3Screen extends ConsumerWidget {
  const Mode3Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packetAsync = ref.watch(packetStreamProvider);
    final last        = ref.watch(lastPacketProvider);
    final theme       = Theme.of(context);
    final canvas      = theme.extension<RadianCanvasTheme>()!;

    // Use live packet when available, otherwise use last known value
    final packet = packetAsync.whenOrNull(data: (p) => p) ?? last;

    // Rotation angle θ from Arm 1
    final theta    = packet.a1;
    final thetaRad = theta * math.pi / 180.0;
    final cosT     = math.cos(thetaRad);
    final sinT     = math.sin(thetaRad);

    // Original vector from Arm 2
    final a2Deg = packet.a2;
    final a2Rad = a2Deg * math.pi / 180.0;

    // Transformed vector: prefer firmware values, fallback to local computation
    final vxOrig = math.cos(a2Rad);
    final vyOrig = math.sin(a2Rad);
    final vxp = packet.mode == 3 && packet.val.rx != 0.0
        ? packet.val.rx
        : cosT * vxOrig - sinT * vyOrig;
    final vyp = packet.mode == 3 && packet.val.ry != 0.0
        ? packet.val.ry
        : sinT * vxOrig + cosT * vyOrig;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Mode 3 — Rotation Matrix'),
        actions: [
          _BLEStatusIndicator(),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Canvas ─────────────────────────────────────────────────────
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 80),
                  child: CustomPaint(
                    key: ValueKey('${theta.round()}_${a2Deg.round()}'),
                    painter: RotationMatrixPainter(
                      theta:       theta,
                      a2:          a2Deg,
                      vxp:         vxp,
                      vyp:         vyp,
                      canvasTheme: canvas,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),

            // ── Data Panel ─────────────────────────────────────────────────
            _DataPanel(
              theta:  theta,
              cosT:   cosT,
              sinT:   sinT,
              a2:     a2Deg,
              vxp:    vxp,
              vyp:    vyp,
              theme:  theme,
              canvas: canvas,
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ── Data Panel ────────────────────────────────────────────────────────────────

class _DataPanel extends StatelessWidget {
  final double theta, cosT, sinT, a2, vxp, vyp;
  final ThemeData theme;
  final RadianCanvasTheme canvas;

  const _DataPanel({
    required this.theta,
    required this.cosT,
    required this.sinT,
    required this.a2,
    required this.vxp,
    required this.vyp,
    required this.theme,
    required this.canvas,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Rotation angle headline ────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _ValueTile(
                  label: 'θ  (ARM 1)',
                  value: '${theta.toStringAsFixed(1)}°',
                  color: canvas.arm1Color,
                  large: true,
                ),
              ),
              const SizedBox(width: 12),
              // 2×2 matrix compact display
              _MatrixCompact(cosT: cosT, sinT: sinT, theme: theme),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: theme.colorScheme.outline, height: 1),
          const SizedBox(height: 12),

          // ── Before / after row ─────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _ValueTile(
                  label: 'v  (ARM 2)',
                  value: '${a2.toStringAsFixed(1)}°',
                  color: canvas.arm2Color,
                ),
              ),
              Container(
                width: 1, height: 32,
                color: theme.colorScheme.outline,
              ),
              Expanded(
                child: _ValueTile(
                  label: "v'x",
                  value: vxp.toStringAsFixed(3),
                  color: canvas.resultantColor,
                ),
              ),
              Container(
                width: 1, height: 32,
                color: theme.colorScheme.outline,
              ),
              Expanded(
                child: _ValueTile(
                  label: "v'y",
                  value: vyp.toStringAsFixed(3),
                  color: canvas.resultantColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Formula hint ───────────────────────────────────────────────
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 12,
                    color: theme.colorScheme.secondary),
                const SizedBox(width: 6),
                Text(
                  "v' = R(θ) · v",
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 2×2 Matrix compact inline display ────────────────────────────────────────

class _MatrixCompact extends StatelessWidget {
  final double cosT, sinT;
  final ThemeData theme;
  const _MatrixCompact({
    required this.cosT,
    required this.sinT,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = theme.extension<RadianCanvasTheme>()!;
    final style = theme.textTheme.displayMedium?.copyWith(
      color: canvas.positiveColor,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: IntrinsicWidth(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Left bracket
            Container(
              width: 3, height: 52,
              decoration: BoxDecoration(
                border: Border(
                  left:   BorderSide(color: theme.colorScheme.onSurface, width: 2),
                  top:    BorderSide(color: theme.colorScheme.onSurface, width: 2),
                  bottom: BorderSide(color: theme.colorScheme.onSurface, width: 2),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  SizedBox(width: 52, child: Text(cosT.toStringAsFixed(2),
                      textAlign: TextAlign.center, style: style)),
                  SizedBox(width: 52, child: Text((-sinT).toStringAsFixed(2),
                      textAlign: TextAlign.center, style: style)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  SizedBox(width: 52, child: Text(sinT.toStringAsFixed(2),
                      textAlign: TextAlign.center, style: style)),
                  SizedBox(width: 52, child: Text(cosT.toStringAsFixed(2),
                      textAlign: TextAlign.center, style: style)),
                ]),
              ],
            ),
            const SizedBox(width: 8),
            // Right bracket
            Container(
              width: 3, height: 52,
              decoration: BoxDecoration(
                border: Border(
                  right:  BorderSide(color: theme.colorScheme.onSurface, width: 2),
                  top:    BorderSide(color: theme.colorScheme.onSurface, width: 2),
                  bottom: BorderSide(color: theme.colorScheme.onSurface, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Value tile ────────────────────────────────────────────────────────────────

class _ValueTile extends StatelessWidget {
  final String label;
  final String value;
  final Color  color;
  final bool   large;

  const _ValueTile({
    required this.label,
    required this.value,
    required this.color,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: (large
              ? theme.textTheme.displayLarge
              : theme.textTheme.displayMedium)
              ?.copyWith(color: color),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── BLE Status Indicator ──────────────────────────────────────────────────────

class _BLEStatusIndicator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bleAsync = ref.watch(bleStateProvider);
    final theme    = Theme.of(context);

    return bleAsync.when(
      data: (state) {
        final (icon, color, label) = switch (state) {
          BLEState.connected    => (Icons.bluetooth_connected, theme.colorScheme.secondary,  'Connected'),
          BLEState.scanning     => (Icons.bluetooth_searching, theme.colorScheme.primary,    'Scanning'),
          BLEState.connecting   => (Icons.bluetooth,           theme.colorScheme.primary,    'Connecting'),
          BLEState.disconnected => (Icons.bluetooth_disabled,  theme.colorScheme.outline,    'Disconnected'),
          BLEState.error        => (Icons.error_outline,       theme.colorScheme.error,      'Error'),
          BLEState.idle         => (Icons.bluetooth,           theme.colorScheme.outline,    'Idle'),
        };
        return Tooltip(
          message: label,
          child: Icon(icon, color: color, size: 20),
        );
      },
      loading: () => const SizedBox.shrink(),
      error:   (_, __) => Icon(Icons.bluetooth_disabled,
          color: theme.colorScheme.outline, size: 20),
    );
  }
}

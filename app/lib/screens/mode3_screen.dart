// ─────────────────────────────────────────────────────────────────────────────
// mode3_screen.dart
// Mode 3 — Rotation Matrix live visualizer
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/packet_provider.dart';
import '../providers/scan_provider.dart';
import '../widgets/painters/rotation_matrix_painter.dart';
import '../app_theme.dart';
import '../ble/ble_manager.dart';

class Mode3Screen extends ConsumerWidget {
  const Mode3Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packet   = ref.watch(lastPacketProvider);
    final bleState = ref.watch(bleStateProvider);
    final theme    = Theme.of(context);
    final canvas   = theme.extension<RadianCanvasTheme>()!;
    final isWide   = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rotation Matrix'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _BleBadge(state: bleState),
          ),
        ],
      ),

      body: isWide
          ? _WideLayout(packet: packet, canvas: canvas, theme: theme)
          : _NarrowLayout(packet: packet, canvas: canvas, theme: theme),
    );
  }
}

// ── Wide Layout ───────────────────────────────────────────────────────────────

class _WideLayout extends StatelessWidget {
  final dynamic packet;
  final RadianCanvasTheme canvas;
  final ThemeData theme;

  const _WideLayout({
    required this.packet,
    required this.canvas,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 300,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _DataPanel(packet: packet, canvas: canvas, theme: theme),
          ),
        ),
        VerticalDivider(width: 1, color: theme.colorScheme.outline),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _Canvas(packet: packet, canvas: canvas),
          ),
        ),
      ],
    );
  }
}

// ── Narrow Layout ─────────────────────────────────────────────────────────────

class _NarrowLayout extends StatelessWidget {
  final dynamic packet;
  final RadianCanvasTheme canvas;
  final ThemeData theme;

  const _NarrowLayout({
    required this.packet,
    required this.canvas,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _Canvas(packet: packet, canvas: canvas),
          ),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _DataPanel(packet: packet, canvas: canvas, theme: theme),
          ),
        ),
      ],
    );
  }
}

// ── Canvas ────────────────────────────────────────────────────────────────────

class _Canvas extends StatelessWidget {
  final dynamic packet;
  final RadianCanvasTheme canvas;

  const _Canvas({required this.packet, required this.canvas});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: RotationMatrixPainter(
          theta:       packet.a1,
          a2:          packet.a2,
          vxp:         packet.val.rx,
          vyp:         packet.val.ry,
          canvasTheme: canvas,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

// ── Data Panel ────────────────────────────────────────────────────────────────

class _DataPanel extends StatelessWidget {
  final dynamic packet;
  final RadianCanvasTheme canvas;
  final ThemeData theme;

  const _DataPanel({
    required this.packet,
    required this.canvas,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final theta = packet.a1     as double;
    final a2    = packet.a2     as double;
    final vxp   = packet.val.rx as double;
    final vyp   = packet.val.ry as double;

    final rad     = theta * pi / 180.0;
    final cosT    = cos(rad);
    final sinT    = sin(rad);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rotation angle — the headline
          _BigReadout(
            label: 'Rotation angle θ (Arm 1)',
            value: '${theta.toStringAsFixed(1)}°',
            theme: theme,
          ),

          const Divider(height: 32),

          // Live rotation matrix
          Text('Rotation matrix R(θ)', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          _MatrixCard(
            r00: cosT, r01: -sinT,
            r10: sinT, r11:  cosT,
            theme: theme,
          ),

          const Divider(height: 32),

          // Vector before and after
          Text('Transformation', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          _VectorRow(
            label: 'v — original (Arm 2)',
            value: a2 == 0.0 ? 'not detected' : '${a2.toStringAsFixed(1)}°',
            color: canvas.arm2Color,
            theme: theme,
          ),
          const SizedBox(height: 8),
          _VectorRow(
            label: "v' — transformed",
            value: '(${vxp.toStringAsFixed(3)}, ${vyp.toStringAsFixed(3)})',
            color: canvas.arm1Color,
            theme: theme,
          ),

          const Divider(height: 32),

          // Formula card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:        theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border:       Border.all(color: theme.colorScheme.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Formula', style: theme.textTheme.labelSmall),
                const SizedBox(height: 6),
                Text("v' = R(θ) · v", style: theme.textTheme.displayMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Matrix Card ───────────────────────────────────────────────────────────────

class _MatrixCard extends StatelessWidget {
  final double r00, r01, r10, r11;
  final ThemeData theme;

  const _MatrixCard({
    required this.r00, required this.r01,
    required this.r10, required this.r11,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color:        theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border:       Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Left bracket
          Container(
            width: 3, height: 64,
            decoration: BoxDecoration(
              border: Border(
                left:   BorderSide(color: theme.colorScheme.onSurface, width: 2),
                top:    BorderSide(color: theme.colorScheme.onSurface, width: 2),
                bottom: BorderSide(color: theme.colorScheme.onSurface, width: 2),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Matrix values
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _MatrixCell(r00, theme), const SizedBox(width: 20),
                  _MatrixCell(r01, theme),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _MatrixCell(r10, theme), const SizedBox(width: 20),
                  _MatrixCell(r11, theme),
                ],
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Right bracket
          Container(
            width: 3, height: 64,
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
    );
  }
}

class _MatrixCell extends StatelessWidget {
  final double    value;
  final ThemeData theme;
  const _MatrixCell(this.value, this.theme);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Text(
        value.toStringAsFixed(3),
        textAlign: TextAlign.center,
        style: theme.textTheme.displayMedium,
      ),
    );
  }
}

// ── Vector Row ────────────────────────────────────────────────────────────────

class _VectorRow extends StatelessWidget {
  final String    label;
  final String    value;
  final Color     color;
  final ThemeData theme;

  const _VectorRow({
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(
            color:        color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        Text(value, style: theme.textTheme.displayMedium),
      ],
    );
  }
}

// ── Big Readout ───────────────────────────────────────────────────────────────

class _BigReadout extends StatelessWidget {
  final String    label;
  final String    value;
  final ThemeData theme;
  const _BigReadout({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(value,  style: theme.textTheme.displayLarge),
      ],
    );
  }
}

// ── BLE Badge ─────────────────────────────────────────────────────────────────

class _BleBadge extends StatelessWidget {
  final BLEState state;
  const _BleBadge({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color  color;
    String label;

    switch (state) {
      case BLEState.connected:
        color = Colors.green;
        label = 'Connected';
        break;
      case BLEState.error:
        color = theme.colorScheme.error;
        label = 'Error';
        break;
      default:
        color = theme.colorScheme.outline;
        label = 'Waiting';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}

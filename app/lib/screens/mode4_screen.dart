// ─────────────────────────────────────────────────────────────────────────────
// mode4_screen.dart
// Mode 4 — Polygon / Central Angle Snap live visualizer
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/packet_provider.dart';
import '../providers/scan_provider.dart';
import '../widgets/painters/polygon_painter.dart';
import '../app_theme.dart';
import '../ble/ble_manager.dart';

class Mode4Screen extends ConsumerWidget {
  const Mode4Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packet   = ref.watch(lastPacketProvider);
    final bleState = ref.watch(bleStateProvider);
    final theme    = Theme.of(context);
    final canvas   = theme.extension<RadianCanvasTheme>()!;
    final isWide   = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Polygon Snap'),
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
        painter: PolygonPainter(
          n:           packet.val.snap,
          armAngle:    packet.a1,
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
    final n        = packet.val.snap     as int;
    final interior = packet.val.interior as double;
    final exterior = packet.val.exterior as double;
    final central  = 360.0 / n;
    final armAngle = packet.a1           as double;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // N — the headline
          _BigReadout(
            label: 'Polygon sides (N)',
            value: '$n',
            theme: theme,
          ),
          const SizedBox(height: 4),
          Text(
            'Set N with the device buttons',
            style: theme.textTheme.labelSmall,
          ),

          const Divider(height: 32),

          // Angle values — three-value panel
          Text('Angles', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          _AngleRow(
            label: 'Interior',
            value: '${interior.toStringAsFixed(1)}°',
            hint:  '(N−2) × 180 ÷ N',
            color: canvas.arm2Color,
            theme: theme,
          ),
          const SizedBox(height: 10),
          _AngleRow(
            label: 'Exterior',
            value: '${exterior.toStringAsFixed(1)}°',
            hint:  '360 ÷ N',
            color: canvas.arm1Color,
            theme: theme,
          ),
          const SizedBox(height: 10),
          _AngleRow(
            label: 'Central',
            value: '${central.toStringAsFixed(1)}°',
            hint:  '360 ÷ N',
            color: canvas.resultantColor,
            theme: theme,
          ),

          const Divider(height: 32),

          // Arm position
          Text('Arm position', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Snapped to', style: theme.textTheme.bodyMedium),
              Text(
                '${armAngle.toStringAsFixed(1)}°',
                style: theme.textTheme.displayMedium,
              ),
            ],
          ),

          const Divider(height: 32),

          // Angle sum card — a teaching fact that changes with N
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
                Text('Sum of interior angles',
                    style: theme.textTheme.labelSmall),
                const SizedBox(height: 6),
                Text(
                  '(${n}−2) × 180° = ${((n - 2) * 180)}°',
                  style: theme.textTheme.displayMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Angle Row ─────────────────────────────────────────────────────────────────

class _AngleRow extends StatelessWidget {
  final String    label;
  final String    value;
  final String    hint;
  final Color     color;
  final ThemeData theme;

  const _AngleRow({
    required this.label,
    required this.value,
    required this.hint,
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodyMedium),
              Text(hint,  style: theme.textTheme.labelSmall),
            ],
          ),
        ),
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

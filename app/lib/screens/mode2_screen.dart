// ─────────────────────────────────────────────────────────────────────────────
// mode2_screen.dart
// Mode 2 — Vector Addition live visualizer
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/packet_provider.dart';
import '../providers/scan_provider.dart';
import '../widgets/painters/vector_diagram_painter.dart';
import '../app_theme.dart';
import '../ble/ble_manager.dart';

class Mode2Screen extends ConsumerWidget {
  const Mode2Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packet   = ref.watch(lastPacketProvider);
    final bleState = ref.watch(bleStateProvider);
    final theme    = Theme.of(context);
    final canvas   = theme.extension<RadianCanvasTheme>()!;
    final isWide   = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vector Addition'),
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
        painter: VectorDiagramPainter(
          a1:          packet.a1,
          a2:          packet.a2,
          rmag:        packet.val.rmag,
          rang:        packet.val.rang,
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
    final a1   = packet.a1       as double;
    final a2   = packet.a2       as double;
    final rmag = packet.val.rmag as double;
    final rang = packet.val.rang as double;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resultant — the headline numbers
          _BigReadout(
            label: 'Resultant magnitude',
            value: '|R| = ${rmag.toStringAsFixed(2)}',
            theme: theme,
          ),
          const SizedBox(height: 8),
          _BigReadout(
            label: 'Resultant angle',
            value: '∠ ${rang.toStringAsFixed(1)}°',
            theme: theme,
          ),

          const Divider(height: 32),

          // Input vectors, color-keyed to the canvas
          Text('Input vectors', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          _VectorRow(
            label:  'v1 — Arm 1',
            value:  '${a1.toStringAsFixed(1)}°',
            color:  canvas.arm1Color,
            theme:  theme,
          ),
          const SizedBox(height: 8),
          _VectorRow(
            label:  'v2 — Arm 2',
            value:  a2 == 0.0 ? 'not detected' : '${a2.toStringAsFixed(1)}°',
            color:  canvas.arm2Color,
            theme:  theme,
          ),
          const SizedBox(height: 8),
          _VectorRow(
            label:  'R — Resultant',
            value:  '${rmag.toStringAsFixed(2)} @ ${rang.toStringAsFixed(1)}°',
            color:  canvas.resultantColor,
            theme:  theme,
          ),

          const Divider(height: 32),

          // Formula reference card
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
                Text('R = v1 + v2',
                    style: theme.textTheme.displayMedium),
                const SizedBox(height: 4),
                Text('|R| = √(Rx² + Ry²)',
                    style: theme.textTheme.displayMedium),
              ],
            ),
          ),
        ],
      ),
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
        Expanded(
          child: Text(label, style: theme.textTheme.bodyMedium),
        ),
        Text(value, style: theme.textTheme.displayMedium),
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

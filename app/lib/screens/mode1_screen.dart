// ─────────────────────────────────────────────────────────────────────────────
// mode1_screen.dart
// Mode 1 — Degree / Radian Conversion live visualizer
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/packet_provider.dart';
import '../providers/scan_provider.dart';
import '../widgets/painters/unit_circle_painter.dart';
import '../app_theme.dart';
import '../ble/ble_manager.dart';

class Mode1Screen extends ConsumerWidget {
  const Mode1Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packet     = ref.watch(lastPacketProvider);
    final bleState   = ref.watch(bleStateProvider);
    final theme      = Theme.of(context);
    final canvas     = theme.extension<RadianCanvasTheme>()!;
    final isWide     = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Degree / Radian'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          // BLE badge
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
        // Left panel — data readout
        SizedBox(
          width: 300,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _DataPanel(packet: packet, theme: theme),
          ),
        ),
        VerticalDivider(
          width: 1,
          color: theme.colorScheme.outline,
        ),
        // Right panel — canvas
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
        // Canvas takes upper 60%
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _Canvas(packet: packet, canvas: canvas),
          ),
        ),
        // Data panel bottom 40%
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _DataPanel(packet: packet, theme: theme),
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
        painter: UnitCirclePainter(
          degrees:    packet.a1,
          cosVal:     packet.val.rx,
          sinVal:     packet.val.ry,
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
  final ThemeData theme;

  const _DataPanel({required this.packet, required this.theme});

  @override
  Widget build(BuildContext context) {
    final degrees = packet.a1 as double;
    final radians = packet.val.rad as double;
    final cosVal  = packet.val.rx  as double;
    final sinVal  = packet.val.ry  as double;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Primary readouts
        _BigReadout(
          label: 'Degrees',
          value: '${degrees.toStringAsFixed(1)}°',
          theme: theme,
        ),
        const SizedBox(height: 8),
        _BigReadout(
          label: 'Radians',
          value: radians.toStringAsFixed(4),
          theme: theme,
        ),

        const Divider(height: 32),

        // Coordinate readouts
        Text('Coordinates', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),

        _CoordRow('cos θ', cosVal.toStringAsFixed(4), theme),
        const SizedBox(height: 8),
        _CoordRow('sin θ', sinVal.toStringAsFixed(4), theme),

        const Divider(height: 32),

        // π-fraction hint
        _PiFractionHint(degrees: degrees, theme: theme),
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

// ── Coordinate Row ────────────────────────────────────────────────────────────

class _CoordRow extends StatelessWidget {
  final String    label;
  final String    value;
  final ThemeData theme;
  const _CoordRow(this.label, this.value, this.theme);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(value,  style: theme.textTheme.displayMedium),
      ],
    );
  }
}

// ── π-Fraction Hint ───────────────────────────────────────────────────────────
// Shows the common radian fraction for 16 key angles

class _PiFractionHint extends StatelessWidget {
  final double    degrees;
  final ThemeData theme;
  const _PiFractionHint({required this.degrees, required this.theme});

  static const Map<double, String> _hints = {
    0.0:   '0',
    30.0:  'π/6',
    45.0:  'π/4',
    60.0:  'π/3',
    90.0:  'π/2',
    120.0: '2π/3',
    135.0: '3π/4',
    150.0: '5π/6',
    180.0: 'π',
    210.0: '7π/6',
    225.0: '5π/4',
    240.0: '4π/3',
    270.0: '3π/2',
    300.0: '5π/3',
    315.0: '7π/4',
    330.0: '11π/6',
    360.0: '2π',
  };

  @override
  Widget build(BuildContext context) {
    // Find nearest key angle within ±2°
    String? hint;
    for (final entry in _hints.entries) {
      if ((degrees - entry.key).abs() < 2.0) {
        hint = entry.value;
        break;
      }
    }

    if (hint == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color:        theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border:       Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lightbulb_outline,
              size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            'This angle = $hint',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
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
          decoration: BoxDecoration(
              color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}
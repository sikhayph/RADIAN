// ─────────────────────────────────────────────────────────────────────────────
// mode1_screen.dart
// Mode 1 — Degree / Radian Conversion Visualizer
// Valiger — RADIAN Companion App
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_theme.dart';
import '../providers/providers.dart';
import '../ble/radian_packet.dart';
import '../widgets/painters/unit_circle_painter.dart';

class Mode1Screen extends ConsumerWidget {
  const Mode1Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packetAsync = ref.watch(packetStreamProvider);
    final last        = ref.watch(lastPacketProvider);
    final theme       = Theme.of(context);
    final canvas      = theme.extension<RadianCanvasTheme>()!;

    // Use live packet when available, otherwise use last known value
    final packet = packetAsync.whenOrNull(data: (p) => p) ?? last;

    // Recompute cos/sin from a1 in case BLE packet doesn't carry them
    final deg    = packet.a1;
    final rad    = deg * math.pi / 180.0;
    final cosVal = math.cos(rad);
    final sinVal = math.sin(rad);
    // Prefer firmware-computed values if present and packet is mode 1
    final displayRad  = packet.mode == 1 && packet.val.rad != 0.0
        ? packet.val.rad
        : rad;
    final displayCos  = packet.mode == 1 ? packet.val.rx : cosVal;
    final displaySin  = packet.mode == 1 ? packet.val.ry : sinVal;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Mode 1 — Degree / Radian'),
        actions: [
          // BLE connection indicator
          _BLEStatusIndicator(),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Unit Circle Canvas ──────────────────────────────────────────
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 80),
                  child: CustomPaint(
                    key: ValueKey(deg.round()),
                    painter: UnitCirclePainter(
                      angleDeg:   deg,
                      cosVal:     displayCos,
                      sinVal:     displaySin,
                      canvasTheme: canvas,
                      textColor:  theme.colorScheme.onSurface,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),

            // ── Data Panel ─────────────────────────────────────────────────
            _DataPanel(
              deg:    deg,
              rad:    displayRad,
              cos:    displayCos,
              sin:    displaySin,
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
  final double deg, rad, cos, sin;
  final ThemeData theme;
  final RadianCanvasTheme canvas;

  const _DataPanel({
    required this.deg,
    required this.rad,
    required this.cos,
    required this.sin,
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
        children: [
          // Angle row — big monospace numbers
          Row(
            children: [
              Expanded(
                child: _ValueTile(
                  label: 'DEGREES',
                  value: '${deg.toStringAsFixed(1)}°',
                  color: canvas.arm1Color,
                  large: true,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: theme.colorScheme.outline,
              ),
              Expanded(
                child: _ValueTile(
                  label: 'RADIANS',
                  value: '${rad.toStringAsFixed(4)} rad',
                  color: canvas.arm1Color,
                  large: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: theme.colorScheme.outline, height: 1),
          const SizedBox(height: 12),

          // cos / sin row
          Row(
            children: [
              Expanded(
                child: _ValueTile(
                  label: 'cos θ',
                  value: cos.toStringAsFixed(4),
                  color: canvas.positiveColor,
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: theme.colorScheme.outline,
              ),
              Expanded(
                child: _ValueTile(
                  label: 'sin θ',
                  value: sin.toStringAsFixed(4),
                  color: canvas.positiveColor,
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: theme.colorScheme.outline,
              ),
              Expanded(
                child: _ValueTile(
                  label: '|r|',
                  value: '1.0000',
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // π fraction hint
          _PiFractionHint(deg: deg, theme: theme),
        ],
      ),
    );
  }
}

// ── Value tile ────────────────────────────────────────────────────────────────

class _ValueTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool large;

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

// ── π fraction hint ───────────────────────────────────────────────────────────

class _PiFractionHint extends StatelessWidget {
  final double deg;
  final ThemeData theme;

  const _PiFractionHint({required this.deg, required this.theme});

  // Common angle → π fraction mappings
  static const Map<int, String> _piMap = {
    0:   '0',
    30:  'π/6',
    45:  'π/4',
    60:  'π/3',
    90:  'π/2',
    120: '2π/3',
    135: '3π/4',
    150: '5π/6',
    180: 'π',
    210: '7π/6',
    225: '5π/4',
    240: '4π/3',
    270: '3π/2',
    300: '5π/3',
    315: '7π/4',
    330: '11π/6',
    360: '2π',
  };

  @override
  Widget build(BuildContext context) {
    final nearest = deg.round() % 360;
    final fraction = _piMap[nearest];
    if (fraction == null) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.auto_awesome, size: 12, color: theme.colorScheme.secondary),
        const SizedBox(width: 6),
        Text(
          '${deg.round()}° = $fraction',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.secondary,
            letterSpacing: 0.5,
          ),
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
      error:   (_, __) => Icon(Icons.bluetooth_disabled, color: theme.colorScheme.outline, size: 20),
    );
  }
}

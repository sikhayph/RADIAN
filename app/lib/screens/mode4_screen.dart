// ─────────────────────────────────────────────────────────────────────────────
// mode4_screen.dart
// Mode 4 — Polygon / Central Angle Snap live visualizer
// Valiger — RADIAN Companion App
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_theme.dart';
import '../providers/providers.dart';
import '../ble/ble_manager.dart';
import '../widgets/painters/polygon_painter.dart';

class Mode4Screen extends ConsumerWidget {
  const Mode4Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packetAsync = ref.watch(packetStreamProvider);
    final last        = ref.watch(lastPacketProvider);
    final theme       = Theme.of(context);
    final canvas      = theme.extension<RadianCanvasTheme>()!;

    // Use live packet when available, otherwise use last known value
    final packet = packetAsync.whenOrNull(data: (p) => p) ?? last;

    // Polygon data from packet
    final n        = packet.val.snap.clamp(3, 12);
    final interior = packet.val.interior != 0.0
        ? packet.val.interior
        : ((n - 2) * 180.0) / n;
    final exterior = packet.val.exterior != 0.0
        ? packet.val.exterior
        : 360.0 / n;
    final central  = 360.0 / n;
    final armAngle = packet.a1;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Mode 4 — Polygon Snap'),
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
                  duration: const Duration(milliseconds: 120),
                  child: CustomPaint(
                    key: ValueKey('n${n}_a${armAngle.round()}'),
                    painter: PolygonPainter(
                      n:           n,
                      armAngle:    armAngle,
                      canvasTheme: canvas,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),

            // ── Data Panel ─────────────────────────────────────────────────
            _DataPanel(
              n:        n,
              interior: interior,
              exterior: exterior,
              central:  central,
              armAngle: armAngle,
              theme:    theme,
              canvas:   canvas,
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
  final int    n;
  final double interior, exterior, central, armAngle;
  final ThemeData theme;
  final RadianCanvasTheme canvas;

  const _DataPanel({
    required this.n,
    required this.interior,
    required this.exterior,
    required this.central,
    required this.armAngle,
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
          // ── Top row: N headline + polygon name ─────────────────────────
          Row(
            children: [
              _ValueTile(
                label: 'SIDES (N)',
                value: '$n',
                color: canvas.arm1Color,
                large: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _polygonName(n),
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      'Set N on the device buttons',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              _ValueTile(
                label: 'SNAPPED TO',
                value: '${armAngle.toStringAsFixed(1)}°',
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: theme.colorScheme.outline, height: 1),
          const SizedBox(height: 12),

          // ── Three-angle row: Interior · Exterior · Central ──────────────
          Row(
            children: [
              Expanded(
                child: _ValueTile(
                  label: 'INTERIOR',
                  value: '${interior.toStringAsFixed(1)}°',
                  color: canvas.arm2Color,
                ),
              ),
              Container(width: 1, height: 36, color: theme.colorScheme.outline),
              Expanded(
                child: _ValueTile(
                  label: 'EXTERIOR',
                  value: '${exterior.toStringAsFixed(1)}°',
                  color: canvas.arm1Color,
                ),
              ),
              Container(width: 1, height: 36, color: theme.colorScheme.outline),
              Expanded(
                child: _ValueTile(
                  label: 'CENTRAL',
                  value: '${central.toStringAsFixed(1)}°',
                  color: canvas.resultantColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Sum of interior angles teaching fact ────────────────────────
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 12,
                    color: theme.colorScheme.secondary),
                const SizedBox(width: 6),
                Text(
                  '(${n}−2) × 180° = ${(n - 2) * 180}°  ·  sum of interior angles',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _polygonName(int n) {
    switch (n) {
      case 3:  return 'Equilateral Triangle';
      case 4:  return 'Square';
      case 5:  return 'Regular Pentagon';
      case 6:  return 'Regular Hexagon';
      case 7:  return 'Regular Heptagon';
      case 8:  return 'Regular Octagon';
      case 9:  return 'Regular Nonagon';
      case 10: return 'Regular Decagon';
      case 11: return 'Regular Hendecagon';
      case 12: return 'Regular Dodecagon';
      default: return 'Regular $n-gon';
    }
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

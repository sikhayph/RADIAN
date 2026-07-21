// ─────────────────────────────────────────────────────────────────────────────
// home_screen.dart
// Mode selection hub — shows live angle readout and navigates to mode screens
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/scan_provider.dart';
import '../providers/packet_provider.dart';
import '../ble/ble_manager.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bleState     = ref.watch(bleStateProvider);
    final lastPacket   = ref.watch(lastPacketProvider);
    final theme        = Theme.of(context);
    final isWide       = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('RADIAN'),
        actions: [
          // Live angle badge
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Text(
                '${lastPacket.a1.toStringAsFixed(1)}°',
                style: theme.textTheme.displayMedium,
              ),
            ),
          ),
          // BLE status
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _BleBadge(state: bleState),
          ),
        ],
      ),

      body: isWide
          ? _WideLayout(lastPacket: lastPacket)
          : _NarrowLayout(lastPacket: lastPacket),

      // Disconnect FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await BLEManager().disconnect();
          if (context.mounted) context.go('/');
        },
        icon: const Icon(Icons.bluetooth_disabled),
        label: const Text('Disconnect'),
      ),
    );
  }
}

// ── Wide Layout (tablet / widescreen) ────────────────────────────────────────

class _WideLayout extends StatelessWidget {
  final dynamic lastPacket;
  const _WideLayout({required this.lastPacket});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left panel — mode selector + readout
        SizedBox(
          width: 300,
          child: _LeftPanel(lastPacket: lastPacket),
        ),
        // Divider
        VerticalDivider(
          width: 1,
          color: Theme.of(context).colorScheme.outline,
        ),
        // Right panel — placeholder until mode screen fills it
        const Expanded(
          child: Center(
            child: Text('Select a mode to begin'),
          ),
        ),
      ],
    );
  }
}

// ── Narrow Layout (phone) ─────────────────────────────────────────────────────

class _NarrowLayout extends StatelessWidget {
  final dynamic lastPacket;
  const _NarrowLayout({required this.lastPacket});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReadoutCard(lastPacket: lastPacket),
          const SizedBox(height: 24),
          _ModeGrid(),
        ],
      ),
    );
  }
}

// ── Left Panel ────────────────────────────────────────────────────────────────

class _LeftPanel extends StatelessWidget {
  final dynamic lastPacket;
  const _LeftPanel({required this.lastPacket});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReadoutCard(lastPacket: lastPacket),
          const SizedBox(height: 24),
          _ModeGrid(),
        ],
      ),
    );
  }
}

// ── Live Readout Card ─────────────────────────────────────────────────────────

class _ReadoutCard extends StatelessWidget {
  final dynamic lastPacket;
  const _ReadoutCard({required this.lastPacket});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Live Readout', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _ReadoutRow('Arm 1',
                '${lastPacket.a1.toStringAsFixed(1)}°', theme),
            _ReadoutRow('Arm 2',
                lastPacket.a2 == 0.0
                    ? '—'
                    : '${lastPacket.a2.toStringAsFixed(1)}°',
                theme),
            const Divider(height: 20),
            _ReadoutRow('Radians',
                lastPacket.val.rad.toStringAsFixed(4), theme),
            _ReadoutRow('cos θ',
                lastPacket.val.rx.toStringAsFixed(3), theme),
            _ReadoutRow('sin θ',
                lastPacket.val.ry.toStringAsFixed(3), theme),
          ],
        ),
      ),
    );
  }
}

class _ReadoutRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  const _ReadoutRow(this.label, this.value, this.theme);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(value,  style: theme.textTheme.displayMedium),
        ],
      ),
    );
  }
}

// ── Mode Grid ─────────────────────────────────────────────────────────────────

class _ModeGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final modes = [
      _ModeInfo(1, 'Degree / Radian',  Icons.rotate_right,      '/mode/1'),
      _ModeInfo(2, 'Vector Addition',  Icons.arrow_outward,      '/mode/2'),
      _ModeInfo(3, 'Rotation Matrix',  Icons.grid_on,            '/mode/3'),
      _ModeInfo(4, 'Polygon Snap',     Icons.hexagon_outlined,   '/mode/4'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Teaching Modes', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: modes
              .map((m) => _ModeTile(mode: m))
              .toList(),
        ),
      ],
    );
  }
}

class _ModeInfo {
  final int    number;
  final String label;
  final IconData icon;
  final String route;
  const _ModeInfo(this.number, this.label, this.icon, this.route);
}

class _ModeTile extends StatelessWidget {
  final _ModeInfo mode;
  const _ModeTile({required this.mode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => context.go(mode.route),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(mode.icon,
                size: 32, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              'Mode ${mode.number}',
              style: theme.textTheme.labelSmall,
            ),
            const SizedBox(height: 4),
            Text(
              mode.label,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
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
      case BLEState.scanning:
        color = theme.colorScheme.primary;
        label = 'Scanning';
        break;
      case BLEState.connecting:
        color = Colors.orange;
        label = 'Connecting';
        break;
      case BLEState.error:
        color = theme.colorScheme.error;
        label = 'Error';
        break;
      default:
        color = theme.colorScheme.outline;
        label = 'Idle';
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
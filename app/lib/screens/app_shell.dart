// ─────────────────────────────────────────────────────────────────────────────
// app_shell.dart
// Global shell: top nav bar + left sidebar + page content
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_theme.dart';
import '../ble/ble_manager.dart';
import '../providers/providers.dart';
import 'screen_widgets.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: VernierColors.bg,
      body: Stack(
        children: [
          // Background grid
          Positioned.fill(
            child: CustomPaint(painter: _CanvasBackgroundPainter()),
          ),

          // Main layout
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Top nav bar ──────────────────────────────────────────────
                _NavBar(),

                // ── Body: sidebar + content ───────────────────────────────────
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _LeftSidebar(),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: child,
                        ),
                      ),
                    ],
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

// ── Top Nav Bar ───────────────────────────────────────────────────────────────

class _NavBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bleState = ref.watch(bleStateProvider).valueOrNull ?? BLEState.idle;
    final loc = GoRouterState.of(context).uri.path;
    int currentIndex = 1;
    if (loc.startsWith('/mode/')) {
      currentIndex = int.tryParse(loc.split('/').last) ?? 1;
    }

    final theme = Theme.of(context);

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: VernierColors.white,
        border: Border(
          bottom: BorderSide(color: VernierColors.lineStrong),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Brand
          Row(
            children: [
              const Text('✛', style: TextStyle(
                color: VernierColors.coral,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              )),
              const SizedBox(width: 9),
              Text('RADIAN', style: theme.textTheme.bodyMedium!.copyWith(
                color: VernierColors.navy,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.5,
              )),
            ],
          ),

          // Mode tabs
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _NavTab(label: 'MODE 1', active: currentIndex == 1,
                  onTap: () => context.go('/mode/1')),
              _NavTab(label: 'MODE 2', active: currentIndex == 2,
                  onTap: () => context.go('/mode/2')),
              _NavTab(label: 'MODE 3', active: currentIndex == 3,
                  onTap: () => context.go('/mode/3')),
              _NavTab(label: 'MODE 4', active: currentIndex == 4,
                  onTap: () => context.go('/mode/4')),
            ],
          ),

          // BLE status
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Signal dots
              Row(
                children: [
                  _SignalBar(active: bleState == BLEState.connected, height: 5),
                  const SizedBox(width: 2),
                  _SignalBar(active: bleState == BLEState.connected, height: 8),
                  const SizedBox(width: 2),
                  _SignalBar(active: bleState == BLEState.connected, height: 11),
                ],
              ),
              const SizedBox(width: 8),
              Text(
                bleState == BLEState.connected ? 'CONNECTED' : 'DISCONNECTED',
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: VernierColors.inkSoft,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavTab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: active ? VernierColors.navy : Colors.transparent,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium!.copyWith(
            color: active ? const Color(0xFFF4F0E6) : VernierColors.inkSoft,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _SignalBar extends StatelessWidget {
  final bool active;
  final double height;
  const _SignalBar({required this.active, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: height,
      alignment: Alignment.bottomCenter,
      child: Container(
        width: 3,
        height: height,
        decoration: BoxDecoration(
          color: active ? VernierColors.teal : VernierColors.inkFaint,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

// ── Left Sidebar ──────────────────────────────────────────────────────────────

class _LeftSidebar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = GoRouterState.of(context).uri.path;
    int currentIndex = 1;
    if (loc.startsWith('/mode/')) {
      currentIndex = int.tryParse(loc.split('/').last) ?? 1;
    }

    return Container(
      width: 56,
      decoration: BoxDecoration(
        color: VernierColors.white,
        border: Border(
          right: BorderSide(color: VernierColors.lineStrong),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          _SidebarModeItem(
            index: 1, label: 'DEG/RAD',
            active: currentIndex == 1,
            onTap: () => context.go('/mode/1'),
          ),
          _SidebarModeItem(
            index: 2, label: 'VECTOR',
            active: currentIndex == 2,
            onTap: () => context.go('/mode/2'),
          ),
          _SidebarModeItem(
            index: 3, label: 'ROTATE',
            active: currentIndex == 3,
            onTap: () => context.go('/mode/3'),
          ),
          _SidebarModeItem(
            index: 4, label: 'POLYGON',
            active: currentIndex == 4,
            onTap: () => context.go('/mode/4'),
          ),
          const Spacer(),
          Container(height: 1, color: VernierColors.line),
          _SidebarActionItem(
            icon: Icons.build_outlined, label: 'TOOLS',
            onTap: () => _showAppModal(context,
                title: 'Tools', child: const _ToolsModalContent()),
          ),
          _SidebarActionItem(
            icon: Icons.settings_outlined, label: 'SETTINGS',
            onTap: () => _showAppModal(context,
                title: 'Settings', child: const _SettingsModalContent()),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SidebarModeItem extends StatelessWidget {
  final int index;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _SidebarModeItem({
    required this.index,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: active
              ? Border(left: BorderSide(color: VernierColors.navy, width: 2))
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: active ? VernierColors.navy : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: active ? VernierColors.navy : VernierColors.navySoft,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '$index',
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: active ? Colors.white : VernierColors.navySoft,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodyMedium!.copyWith(
                color: active ? VernierColors.navy : VernierColors.inkFaint,
                fontSize: 7.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _SidebarActionItem({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: VernierColors.inkFaint),
            const SizedBox(height: 3),
            Text(
              label,
              style: theme.textTheme.bodyMedium!.copyWith(
                color: VernierColors.inkFaint,
                fontSize: 7.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Modal Overlay Shell ──────────────────────────────────────────────────────
// Shared floating-card-styled dialog used by both the Tools and Settings
// sidebar actions.

void _showAppModal(BuildContext context, {required String title, required Widget child}) {
  showDialog(
    context: context,
    barrierColor: const Color(0x59212B3B), // VernierColors.ink @ ~35%
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Container(
            decoration: BoxDecoration(
              color: VernierColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: VernierColors.lineStrong),
              boxShadow: const [
                BoxShadow(color: Color(0x261C3A5E), blurRadius: 24, offset: Offset(0, 12)),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: theme.textTheme.titleLarge),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        color: VernierColors.inkSoft,
                        onPressed: () => Navigator.of(dialogContext).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  child,
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// Shared label/value row used inside the Tools and Settings modals.
class _InfoRow extends StatelessWidget {
  final String label, value;
  final bool mono;
  const _InfoRow(this.label, this.value, {this.mono = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valueStyle = mono
        ? theme.textTheme.displayMedium!.copyWith(color: VernierColors.navy, fontSize: 13, fontWeight: FontWeight.w600)
        : theme.textTheme.bodyMedium!.copyWith(color: VernierColors.navy, fontSize: 13, fontWeight: FontWeight.w600);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium!.copyWith(color: VernierColors.inkSoft, fontSize: 11)),
        Text(value, style: valueStyle),
      ],
    );
  }
}

// ── Tools Modal ───────────────────────────────────────────────────────────────
// Read-only live diagnostics, sourced from the existing lastPacketProvider.

class _ToolsModalContent extends ConsumerWidget {
  const _ToolsModalContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packet = ref.watch(lastPacketProvider);

    return SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PanelHeader(label: 'LIVE DIAGNOSTICS', icon: '⋯'),
          const SizedBox(height: 12),
          _InfoRow('MODE', packet.modeName, mono: false),
          const SizedBox(height: 8),
          _InfoRow('ARM 1 (a1)', '${packet.a1.toStringAsFixed(2)}°'),
          const SizedBox(height: 8),
          _InfoRow('ARM 2 (a2)', '${packet.a2.toStringAsFixed(2)}°'),
          const SizedBox(height: 8),
          _InfoRow('TIMESTAMP', '${packet.ts} ms'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                final json = const JsonEncoder.withIndent('  ').convert(packet.toJson());
                Clipboard.setData(ClipboardData(text: json));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Packet JSON copied to clipboard')),
                );
              },
              icon: const Icon(Icons.copy_outlined, size: 16),
              label: const Text('Copy raw packet JSON'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Settings Modal ───────────────────────────────────────────────────────────
// Connection status + disconnect, sourced from the existing bleStateProvider
// and BLEManager exactly as used elsewhere in the app.

class _SettingsModalContent extends ConsumerWidget {
  const _SettingsModalContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme    = Theme.of(context);
    final bleState = ref.watch(bleStateProvider).valueOrNull ?? BLEState.idle;

    late final String statusLabel;
    late final Color  statusColor;
    switch (bleState) {
      case BLEState.connected:
        statusLabel = 'Connected';
        statusColor = VernierColors.teal;
        break;
      case BLEState.scanning:
        statusLabel = 'Scanning';
        statusColor = VernierColors.amber;
        break;
      case BLEState.connecting:
        statusLabel = 'Connecting';
        statusColor = VernierColors.amber;
        break;
      case BLEState.error:
        statusLabel = 'Error';
        statusColor = VernierColors.coral;
        break;
      default:
        statusLabel = 'Not connected';
        statusColor = VernierColors.inkFaint;
    }

    return SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PanelHeader(label: 'CONNECTION', icon: '⋯'),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(statusLabel, style: theme.textTheme.bodyMedium!.copyWith(
                  color: VernierColors.ink, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: bleState == BLEState.connected
                  ? () async {
                      await BLEManager().disconnect();
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        context.go('/');
                      }
                    }
                  : null,
              icon: const Icon(Icons.bluetooth_disabled, size: 16),
              label: const Text('Disconnect'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: VernierColors.line),
          const SizedBox(height: 20),
          const PanelHeader(label: 'ABOUT', icon: '⋯'),
          const SizedBox(height: 12),
          const _InfoRow('APP', 'RADIAN Companion', mono: false),
          const SizedBox(height: 8),
          const _InfoRow('VERSION', '0.1.0', mono: false),
        ],
      ),
    );
  }
}

// ── Background Grid Painter ───────────────────────────────────────────────────

class _CanvasBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = VernierColors.line
      ..strokeWidth = 1.0;

    const double lineSpacing = 26.0;

    for (double i = 0; i < size.width; i += lineSpacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), linePaint);
    }
    for (double i = 0; i < size.height; i += lineSpacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CanvasBackgroundPainter oldDelegate) => false;
}

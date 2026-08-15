// ─────────────────────────────────────────────────────────────────────────────
// app_shell.dart
// Global shell: top nav bar + left sidebar + page content
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_theme.dart';
import '../ble/ble_manager.dart';
import '../providers/providers.dart';

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
          const Row(
            children: [
              Text('✛', style: TextStyle(
                color: VernierColors.coral,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              )),
              SizedBox(width: 9),
              Text('RADIAN', style: TextStyle(
                color: VernierColors.navy,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.5,
                fontFamily: 'IBM Plex Mono',
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
                style: const TextStyle(
                  color: VernierColors.inkSoft,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  fontFamily: 'IBM Plex Mono',
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
          style: TextStyle(
            color: active ? const Color(0xFFF4F0E6) : VernierColors.inkSoft,
            fontSize: 10,
            fontFamily: 'IBM Plex Mono',
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
          _SidebarActionItem(icon: Icons.build_outlined, label: 'TOOLS'),
          _SidebarActionItem(icon: Icons.settings_outlined, label: 'SETTINGS'),
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
                style: TextStyle(
                  color: active ? Colors.white : VernierColors.navySoft,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'IBM Plex Mono',
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: active ? VernierColors.navy : VernierColors.inkFaint,
                fontSize: 7.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                fontFamily: 'IBM Plex Mono',
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
  const _SidebarActionItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: VernierColors.inkFaint),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: VernierColors.inkFaint,
              fontSize: 7.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              fontFamily: 'IBM Plex Mono',
            ),
          ),
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

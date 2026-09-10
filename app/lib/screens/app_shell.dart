// ─────────────────────────────────────────────────────────────────────────────
// app_shell.dart
// Global shell: top nav bar + left sidebar + page content
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_theme.dart';
import '../ble/ble_manager.dart';
import '../providers/providers.dart';
import 'screen_widgets.dart';
import 'waitlist_section.dart';
import 'docs_section.dart';
import 'faq_section.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background grid
          Positioned.fill(
            child: CustomPaint(
              painter: _CanvasBackgroundPainter(
                Theme.of(context).extension<RadianUiTheme>()!.divider,
              ),
            ),
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
    final ui    = theme.extension<RadianUiTheme>()!;
    final canvas = theme.extension<RadianCanvasTheme>()!;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: ui.surface,
        border: Border(
          bottom: BorderSide(color: ui.border),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Brand
          Row(
            children: [
              Text('✛', style: TextStyle(
                color: canvas.arm1Color,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              )),
              const SizedBox(width: 9),
              Text('RADIAN', style: theme.textTheme.bodyMedium!.copyWith(
                color: ui.textPrimary,
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
              _NavTab(label: 'CALC', active: currentIndex == 5,
                  onTap: () => context.go('/mode/5')),
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
                  color: ui.textSecondary,
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
    final ui    = theme.extension<RadianUiTheme>()!;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: active ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8), // rounded-lg — matches website nav pill radius
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium!.copyWith(
            color: active ? theme.colorScheme.onPrimary : ui.textSecondary,
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
    final ui = Theme.of(context).extension<RadianUiTheme>()!;
    return Container(
      width: 3,
      height: height,
      alignment: Alignment.bottomCenter,
      child: Container(
        width: 3,
        height: height,
        decoration: BoxDecoration(
          color: active ? ui.success : ui.textFaint,
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

    final ui = Theme.of(context).extension<RadianUiTheme>()!;
    return Container(
      width: 56,
      decoration: BoxDecoration(
        color: ui.surface,
        border: Border(
          right: BorderSide(color: ui.border),
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
          _SidebarModeItem(
            index: 5, label: 'CALC',
            active: currentIndex == 5,
            onTap: () => context.go('/mode/5'),
          ),
          const Spacer(),
          Container(height: 1, color: ui.divider),
          _SidebarActionItem(
            icon: Icons.mail_outline, label: 'WAITLIST',
            onTap: () => _showAppModal(context,
                title: 'Join the Waitlist', child: const _WaitlistModalContent()),
          ),
          _SidebarActionItem(
            icon: Icons.menu_book_outlined, label: 'DOCS',
            onTap: () => _showAppModal(context,
                title: 'Documentation', maxWidth: 480, child: const DocsSection()),
          ),
          _SidebarActionItem(
            icon: Icons.help_outline, label: 'FAQ',
            onTap: () => _showAppModal(context,
                title: 'Frequently Asked Questions', maxWidth: 480, child: const FaqSection()),
          ),
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
    final ui    = theme.extension<RadianUiTheme>()!;
    final accent = theme.colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: active
              ? Border(left: BorderSide(color: accent, width: 2))
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: active ? accent : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: active ? accent : ui.accentSoft,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '$index',
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: active ? theme.colorScheme.onPrimary : ui.accentSoft,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodyMedium!.copyWith(
                color: active ? accent : ui.textFaint,
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
    final ui    = theme.extension<RadianUiTheme>()!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: ui.textFaint),
            const SizedBox(height: 3),
            Text(
              label,
              style: theme.textTheme.bodyMedium!.copyWith(
                color: ui.textFaint,
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

void _showAppModal(BuildContext context,
    {required String title, required Widget child, double maxWidth = 380}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);
      final ui    = theme.extension<RadianUiTheme>()!;
      final maxDialogHeight = MediaQuery.of(dialogContext).size.height * 0.8;
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxDialogHeight),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16), // rounded-2xl — matches website dropdown/card radius
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: ui.surface.withOpacity(0.92), // mirrors website's --surface-glass
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ui.border),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.24), blurRadius: 24, offset: const Offset(0, 12)),
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
                          Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            color: ui.textSecondary,
                            onPressed: () => Navigator.of(dialogContext).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Flexible(child: SingleChildScrollView(child: child)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

// ── Waitlist Modal ───────────────────────────────────────────────────────────
// Native port of the website's WaitlistSection — posts to the live
// /api/waitlist endpoint. See screens/waitlist_section.dart + services/waitlist_api.dart.

class _WaitlistModalContent extends StatelessWidget {
  const _WaitlistModalContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ui = theme.extension<RadianUiTheme>()!;
    return SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Get notified when the v1 hardware ships — we'll email you, nothing else.",
            style: theme.textTheme.bodyMedium!
                .copyWith(color: ui.textSecondary, fontSize: 12.5, height: 1.4),
          ),
          const SizedBox(height: 18),
          const WaitlistSection(),
        ],
      ),
    );
  }
}

/// Shared label/value row used inside the Tools and Settings modals.
class _InfoRow extends StatelessWidget {
  final String label, value;
  final bool mono;
  const _InfoRow(this.label, this.value, {this.mono = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ui    = theme.extension<RadianUiTheme>()!;
    final valueStyle = mono
        ? theme.textTheme.displayMedium!.copyWith(color: theme.colorScheme.primary, fontSize: 13, fontWeight: FontWeight.w600)
        : theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.primary, fontSize: 13, fontWeight: FontWeight.w600);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium!.copyWith(color: ui.textSecondary, fontSize: 11)),
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
    final ui       = theme.extension<RadianUiTheme>()!;
    final bleState = ref.watch(bleStateProvider).valueOrNull ?? BLEState.idle;

    late final String statusLabel;
    late final Color  statusColor;
    switch (bleState) {
      case BLEState.connected:
        statusLabel = 'Connected';
        statusColor = ui.success;
        break;
      case BLEState.scanning:
        statusLabel = 'Scanning';
        statusColor = ui.warning;
        break;
      case BLEState.connecting:
        statusLabel = 'Connecting';
        statusColor = ui.warning;
        break;
      case BLEState.error:
        statusLabel = 'Error';
        statusColor = theme.colorScheme.error;
        break;
      default:
        statusLabel = 'Not connected';
        statusColor = ui.textFaint;
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
                  color: ui.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
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
          Container(height: 1, color: ui.divider),
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
  final Color lineColor;
  const _CanvasBackgroundPainter(this.lineColor);

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
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
  bool shouldRepaint(covariant _CanvasBackgroundPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor;
}

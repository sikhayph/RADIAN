// ─────────────────────────────────────────────────────────────────────────────
// settings_screen.dart
// Theme picker, device nickname, connection management
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app_theme.dart';
import '../providers/scan_provider.dart';
import '../providers/theme_provider.dart';
import '../ble/ble_manager.dart';

// ── Device Nickname Provider ──────────────────────────────────────────────────

final nicknameProvider = StateProvider<String>((ref) => 'My RADIAN');

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _nicknameController;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(
      text: ref.read(nicknameProvider),
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme      = Theme.of(context);
    final bleState   = ref.watch(scanFlowStateProvider);
    final themeMode  = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [

          // ── Theme Section ──────────────────────────────────────────────────
          _SectionHeader('Appearance', theme),
          const SizedBox(height: 12),

          ...RadianThemeMode.values.map((mode) {
            final isSelected = mode == themeMode;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ThemeTile(
                mode:       mode,
                isSelected: isSelected,
                onTap: () {
                  ref.read(themeNotifierProvider.notifier).setTheme(mode);
                },
              ),
            );
          }),

          const SizedBox(height: 32),

          // ── Device Section ─────────────────────────────────────────────────
          _SectionHeader('Device', theme),
          const SizedBox(height: 12),

          // Nickname field
          TextField(
            controller: _nicknameController,
            decoration: InputDecoration(
              labelText: 'Device nickname',
              hintText: 'My RADIAN',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.check),
                onPressed: () {
                  ref.read(nicknameProvider.notifier).state =
                      _nicknameController.text.trim().isEmpty
                          ? 'My RADIAN'
                          : _nicknameController.text.trim();
                  FocusScope.of(context).unfocus();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nickname saved')),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Connection status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      color: bleState == BLEState.connected
                          ? Colors.green
                          : theme.colorScheme.outline,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      bleState == BLEState.connected
                          ? 'Connected to RADIAN'
                          : 'Not connected',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Disconnect button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: bleState == BLEState.connected
                  ? () async {
                      await BLEManager().disconnect();
                      if (context.mounted) context.go('/');
                    }
                  : null,
              icon: const Icon(Icons.bluetooth_disabled),
              label: const Text('Disconnect'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // ── About Section ──────────────────────────────────────────────────
          _SectionHeader('About', theme),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AboutRow('App',      'RADIAN Companion',    theme),
                  _AboutRow('Version',  '0.1.0',               theme),
                  _AboutRow('By',       'Sikhay and Valiger',  theme),
                  _AboutRow('Firmware', 'v0.1 (ESP32)',        theme),
                ],
              ),
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ── Theme Tile ────────────────────────────────────────────────────────────────

class _ThemeTile extends StatelessWidget {
  final RadianThemeMode mode;
  final bool            isSelected;
  final VoidCallback    onTap;

  const _ThemeTile({
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.08)
              : theme.colorScheme.surface,
        ),
        child: Row(
          children: [
            // Color preview dot
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: mode.themeData.colorScheme.primary,
                border: Border.all(
                  color: theme.colorScheme.outline,
                  width: 1,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mode.displayName,
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    mode.description,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle,
                  color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String    text;
  final ThemeData theme;
  const _SectionHeader(this.text, this.theme);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: theme.textTheme.titleLarge);
  }
}

class _AboutRow extends StatelessWidget {
  final String    label;
  final String    value;
  final ThemeData theme;
  const _AboutRow(this.label, this.value, this.theme);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(value,  style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}

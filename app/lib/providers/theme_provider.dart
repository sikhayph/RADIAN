// ─────────────────────────────────────────────────────────────────────────────
// theme_provider.dart
// Riverpod provider for RadianThemeMode with Hive persistence
// Valiger — RADIAN Companion App
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../app_theme.dart';

// ── Hive box constants ────────────────────────────────────────────────────────

const _kBoxName   = 'radian_prefs';
const _kThemeKey  = 'theme_mode';

// ── Theme notifier ────────────────────────────────────────────────────────────

class ThemeNotifier extends StateNotifier<RadianThemeMode> {
  ThemeNotifier(RadianThemeMode initial) : super(initial);

  /// Persist and apply a new theme mode.
  Future<void> setTheme(RadianThemeMode mode) async {
    state = mode;
    final box = await Hive.openBox(_kBoxName);
    await box.put(_kThemeKey, mode.name);
  }

  /// Cycle through Obsidian → Chalk → Sikhay → Obsidian.
  Future<void> cycle() async {
    final next = RadianThemeMode.values[
      (state.index + 1) % RadianThemeMode.values.length
    ];
    await setTheme(next);
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

/// Reads the persisted theme from Hive on first access, defaults to Obsidian.
/// Call [ThemeNotifier.setTheme] or [ThemeNotifier.cycle] to change the theme.
final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, RadianThemeMode>((ref) {
  // Synchronously read from Hive if box is already open
  RadianThemeMode initial = RadianThemeMode.obsidian;
  try {
    if (Hive.isBoxOpen(_kBoxName)) {
      final box   = Hive.box(_kBoxName);
      final saved = box.get(_kThemeKey) as String?;
      if (saved != null) {
        initial = RadianThemeMode.values.firstWhere(
          (m) => m.name == saved,
          orElse: () => RadianThemeMode.obsidian,
        );
      }
    }
  } catch (_) {
    // Hive not yet initialised — fall back to default
  }
  return ThemeNotifier(initial);
});

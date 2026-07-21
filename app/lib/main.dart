// ─────────────────────────────────────────────────────────────────────────────
// main.dart
// RADIAN Companion App — Entry Point
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_theme.dart';
import 'screens/scan_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: RadianApp(),
    ),
  );
}

// ── Theme Provider ────────────────────────────────────────────────────────────

final themeProvider = StateProvider<RadianThemeMode>(
  (ref) => RadianThemeMode.obsidian,
);

// ── Router ────────────────────────────────────────────────────────────────────

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'scan',
      builder: (context, state) => const ScanScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),    ),
    GoRoute(
      path: '/mode/1',
      name: 'mode1',
      builder: (context, state) => const ModePlaceholder(mode: 1),
    ),
    GoRoute(
      path: '/mode/2',
      name: 'mode2',
      builder: (context, state) => const ModePlaceholder(mode: 2),
    ),
    GoRoute(
      path: '/mode/3',
      name: 'mode3',
      builder: (context, state) => const ModePlaceholder(mode: 3),
    ),
    GoRoute(
      path: '/mode/4',
      name: 'mode4',
      builder: (context, state) => const ModePlaceholder(mode: 4),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),    ),
  ],
);

// ── App Root ──────────────────────────────────────────────────────────────────

class RadianApp extends ConsumerWidget {
  const RadianApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title:        'RADIAN',
      debugShowCheckedModeBanner: false,
      theme:        themeMode.themeData,
      routerConfig: _router,
    );
  }
}

// ── Placeholder Screens ───────────────────────────────────────────────────────
// Replaced one by one as real screens are built.
// Do not delete until the corresponding real screen is wired in.

class HomePlaceholder extends StatelessWidget {
  const HomePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RADIAN — Home')),
      body: const Center(child: Text('Home screen — coming soon')),
    );
  }
}

class ModePlaceholder extends StatelessWidget {
  final int mode;
  const ModePlaceholder({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('RADIAN — Mode $mode')),
      body: Center(child: Text('Mode $mode screen — coming soon')),
    );
  }
}

class SettingsPlaceholder extends StatelessWidget {
  const SettingsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RADIAN — Settings')),
      body: const Center(child: Text('Settings screen — coming soon')),
    );
  }
}
// ─────────────────────────────────────────────────────────────────────────────
// main.dart
// RADIAN Companion App — Entry Point
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_theme.dart';

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
      builder: (context, state) => const ScanPlaceholder(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomePlaceholder(),
    ),
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
      builder: (context, state) => const SettingsPlaceholder(),
    ),
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
// These are replaced by Valiger with real screen implementations.
// Do not delete — they keep flutter run working until screens are built.

class ScanPlaceholder extends StatelessWidget {
  const ScanPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RADIAN — Scan')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bluetooth_searching, size: 64),
            SizedBox(height: 16),
            Text('Scan screen — Valiger to implement'),
          ],
        ),
      ),
    );
  }
}

class HomePlaceholder extends StatelessWidget {
  const HomePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RADIAN — Home')),
      body: const Center(child: Text('Home screen — Valiger to implement')),
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
      body: Center(child: Text('Mode $mode screen — Valiger to implement')),
    );
  }
}

class SettingsPlaceholder extends StatelessWidget {
  const SettingsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RADIAN — Settings')),
      body: const Center(child: Text('Settings screen — Valiger to implement')),
    );
  }
}
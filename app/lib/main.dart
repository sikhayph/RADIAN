// ─────────────────────────────────────────────────────────────────────────────
// main.dart
// RADIAN Companion App — Entry Point
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app_theme.dart';
import 'providers/providers.dart';
import 'screens/mode1_screen.dart';
import 'screens/mode2_screen.dart';
import 'screens/mode3_screen.dart';
import 'screens/mode4_screen.dart';
import 'screens/app_shell.dart';
// ─────────────────────────────────────────────────────────────────────────────
// Backwards-compat shim: Sikhay's main.dart declared themeProvider as a
// StateProvider<RadianThemeMode>. We now use themeNotifierProvider from
// providers/theme_provider.dart. This alias keeps any code that still
// references themeProvider compiling without changes.
// ─────────────────────────────────────────────────────────────────────────────
final themeProvider = themeNotifierProvider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(
    const ProviderScope(
      child: RadianApp(),
    ),
  );
}

// ── Router ────────────────────────────────────────────────────────────────────

final _router = GoRouter(
  initialLocation: '/mode/1',
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
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsPlaceholder(),
    ),
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/mode/1',
          name: 'mode1',
          builder: (context, state) => const Mode1Screen(),
        ),
        GoRoute(
          path: '/mode/2',
          name: 'mode2',
          builder: (context, state) => const Mode2Screen(),
        ),
        GoRoute(
          path: '/mode/3',
          name: 'mode3',
          builder: (context, state) => const Mode3Screen(),
        ),
        GoRoute(
          path: '/mode/4',
          name: 'mode4',
          builder: (context, state) => const Mode4Screen(),
        ),
      ],
    ),
  ],
);

// ── App Root ──────────────────────────────────────────────────────────────────

class RadianApp extends ConsumerWidget {
  const RadianApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);

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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('RADIAN — Scan')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bluetooth_searching, size: 64,
                color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text('Scan screen — coming soon',
                style: theme.textTheme.bodyLarge),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/mode/1'),
              child: const Text('Preview Mode 1 →'),
            ),
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
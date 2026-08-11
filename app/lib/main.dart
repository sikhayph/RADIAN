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
import 'screens/mode1_screen.dart';
import 'screens/mode2_screen.dart';
import 'screens/mode3_screen.dart';
import 'screens/mode4_screen.dart';

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
      builder: (context, state) => const HomeScreen(),    
    ),
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
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),    
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
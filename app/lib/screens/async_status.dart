// ─────────────────────────────────────────────────────────────────────────────
// async_status.dart
// Shared loading / error states for network-backed sections (Docs, FAQ),
// styled with the obsidian theme tokens.
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../app_theme.dart';

class AsyncLoadingState extends StatelessWidget {
  const AsyncLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ui = theme.extension<RadianUiTheme>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text('Loading…',
                style: theme.textTheme.bodyMedium!.copyWith(color: ui.textSecondary, fontSize: 12.5)),
          ],
        ),
      ),
    );
  }
}

class AsyncErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const AsyncErrorState({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ui = theme.extension<RadianUiTheme>()!;
    final canvas = theme.extension<RadianCanvasTheme>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline, size: 18, color: canvas.arm1Color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(message,
                    style: theme.textTheme.bodyMedium!.copyWith(color: ui.textPrimary, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

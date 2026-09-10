// ─────────────────────────────────────────────────────────────────────────────
// screen_widgets.dart
// Shared layout widgets used across all mode screens:
//   TitleBar, FormulaBar, PanelHeader, FieldLabel
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Floating title text for each mode screen.
/// Shows `✛  MODE 0X  •  TITLE`
class ModeTitle extends StatelessWidget {
  final String modeLabel, title;
  const ModeTitle({super.key, required this.modeLabel, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canvas = theme.extension<RadianCanvasTheme>()!;
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 20, right: 24, bottom: 8),
      child: Row(
        children: [
          Text('✛', style: TextStyle(color: canvas.arm1Color, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Text('$modeLabel  •  $title',
            style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.primary, fontSize: 10,
                fontWeight: FontWeight.w600, letterSpacing: 1.4)),
        ],
      ),
    );
  }
}

/// Floating card for data panels.
class FloatingCard extends StatelessWidget {
  final Widget child;
  const FloatingCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ui    = theme.extension<RadianUiTheme>()!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ui.surface,
        borderRadius: BorderRadius.circular(16), // rounded-2xl — matches website FAQ/mode cards
        border: Border.all(color: ui.border),
      ),
      child: child,
    );
  }
}

/// Floating bottom formula strip.
class FloatingFormulaBar extends StatelessWidget {
  final String formula;
  final Widget? right;
  const FloatingFormulaBar({super.key, required this.formula, this.right});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ui    = theme.extension<RadianUiTheme>()!;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: ui.success.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12), // rounded-xl — matches website pill/input radius
        border: Border.all(color: ui.success.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Text('✦', style: TextStyle(color: ui.success, fontSize: 10)),
          const SizedBox(width: 8),
          Text(formula, style: theme.textTheme.bodyMedium!.copyWith(color: ui.success,
              fontSize: 10.5)),
          const Spacer(),
          if (right != null) right!,
        ],
      ),
    );
  }
}

/// Small section header inside the right data panel.
class PanelHeader extends StatelessWidget {
  final String label, icon;
  const PanelHeader({super.key, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ui    = theme.extension<RadianUiTheme>()!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium!.copyWith(color: ui.textFaint, fontSize: 9,
            fontWeight: FontWeight.w700, letterSpacing: 1.6)),
        Text(icon, style: TextStyle(color: ui.textFaint, fontSize: 10)),
      ],
    );
  }
}

/// Tiny all-caps field label above a value.
class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ui    = theme.extension<RadianUiTheme>()!;
    return Text(text, style: theme.textTheme.bodyMedium!.copyWith(color: ui.textFaint, fontSize: 9,
        fontWeight: FontWeight.w600, letterSpacing: 1.5));
  }
}

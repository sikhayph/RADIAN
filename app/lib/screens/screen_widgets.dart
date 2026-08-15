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
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 20, right: 24, bottom: 8),
      child: Row(
        children: [
          const Text('✛', style: TextStyle(color: VernierColors.navySoft, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Text('$modeLabel  •  $title',
            style: const TextStyle(color: VernierColors.navySoft, fontSize: 10,
                fontWeight: FontWeight.w600, letterSpacing: 1.4, fontFamily: 'IBM Plex Mono')),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: VernierColors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: VernierColors.lineStrong),
        boxShadow: const [
          BoxShadow(color: Color(0x081C3A5E), blurRadius: 8, offset: Offset(0, 4)),
        ],
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
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: VernierColors.tealWash,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: VernierColors.line),
      ),
      child: Row(
        children: [
          const Text('✦', style: TextStyle(color: VernierColors.teal, fontSize: 10)),
          const SizedBox(width: 8),
          Text(formula, style: const TextStyle(color: VernierColors.teal,
              fontFamily: 'IBM Plex Mono', fontSize: 10.5)),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: VernierColors.inkFaint, fontSize: 9,
            fontWeight: FontWeight.w700, letterSpacing: 1.6, fontFamily: 'IBM Plex Mono')),
        Text(icon, style: const TextStyle(color: VernierColors.inkFaint, fontSize: 10)),
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
    return Text(text, style: const TextStyle(color: VernierColors.inkFaint, fontSize: 9,
        fontWeight: FontWeight.w600, letterSpacing: 1.5, fontFamily: 'IBM Plex Mono'));
  }
}

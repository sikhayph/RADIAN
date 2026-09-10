// ─────────────────────────────────────────────────────────────────────────────
// calculator_controls.dart
// Shared form controls + layout for the Calculator mode's four tabs. Ports the
// website's components/calculator/controls.tsx to Flutter, styled with the
// obsidian theme tokens (RadianUiTheme / ThemeData.inputDecorationTheme) set
// up in app_theme.dart rather than raw CSS custom properties.
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Two-column layout: controls on the left, figure on the right — collapses
/// to a single column below [breakpoint] (mirrors the website's lg: grid).
class CalcTwoColumn extends StatelessWidget {
  final Widget controls;
  final Widget figure;
  const CalcTwoColumn({super.key, required this.controls, required this.figure});

  static const double breakpoint = 760;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth >= breakpoint) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: controls),
            const SizedBox(width: 32),
            SizedBox(width: 320, child: figure),
          ],
        );
      }
      return Column(
        children: [
          controls,
          const SizedBox(height: 24),
          figure,
        ],
      );
    });
  }
}

/// Figure card — wraps a square CustomPaint in the app's floating-card surface.
class CalcFigureCard extends StatelessWidget {
  final Widget child;
  final String? caption;
  const CalcFigureCard({super.key, required this.child, this.caption});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ui = theme.extension<RadianUiTheme>()!;
    return Column(
      children: [
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ui.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ui.border),
          ),
          child: AspectRatio(aspectRatio: 1, child: child),
        ),
        if (caption != null) ...[
          const SizedBox(height: 10),
          Text(caption!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium!.copyWith(
                  color: ui.textSecondary, fontFamily: 'JetBrainsMono', fontSize: 11)),
        ],
      ],
    );
  }
}

/// A labeled numeric input field with an optional unit suffix.
class CalcNumberField extends StatefulWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final double step;
  final double? min;
  final String? suffix;
  const CalcNumberField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.step = 1,
    this.min,
    this.suffix,
  });

  @override
  State<CalcNumberField> createState() => _CalcNumberFieldState();
}

class _CalcNumberFieldState extends State<CalcNumberField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatValue(widget.value));
  }

  @override
  void didUpdateWidget(CalcNumberField old) {
    super.didUpdateWidget(old);
    // Keep the field synced when the parent recomputes value externally
    // (e.g. switching direction in the degree/radian tab).
    final current = double.tryParse(_controller.text);
    if (current != widget.value && widget.value != old.value) {
      _controller.text = _formatValue(widget.value);
    }
  }

  String _formatValue(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toString();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: theme.textTheme.bodyMedium!.copyWith(
                color: theme.colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: _controller,
          keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
          style: theme.textTheme.bodyLarge!.copyWith(fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            suffixText: widget.suffix,
            suffixStyle: theme.textTheme.bodyMedium!.copyWith(fontFamily: 'JetBrainsMono'),
          ),
          onChanged: (text) {
            final n = double.tryParse(text);
            if (n == null) return;
            final clamped = widget.min != null && n < widget.min! ? widget.min! : n;
            widget.onChanged(clamped);
          },
        ),
      ],
    );
  }
}

/// A range slider paired with its live numeric value (used for polygon sides).
class CalcRangeField extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  const CalcRangeField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: theme.textTheme.bodyMedium!.copyWith(
                    color: theme.colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w500)),
            Text('$value',
                style: theme.textTheme.displayMedium!
                    .copyWith(color: theme.colorScheme.primary, fontSize: 13)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            overlayShape: SliderComponentShape.noOverlay,
          ),
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            activeColor: theme.colorScheme.primary,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
      ],
    );
  }
}

/// Two-option segmented toggle (e.g. Degrees → Radians / Radians → Degrees).
class CalcSegmented<T> extends StatelessWidget {
  final String label;
  final List<(T value, String label)> options;
  final T value;
  final ValueChanged<T> onChanged;
  const CalcSegmented({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ui = theme.extension<RadianUiTheme>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.bodyMedium!.copyWith(
                color: theme.colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: ui.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: options.map((opt) {
              final selected = opt.$1 == value;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: InkWell(
                  onTap: () => onChanged(opt.$1),
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? theme.colorScheme.primary.withOpacity(0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(opt.$2,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: selected ? theme.colorScheme.onSurface : ui.textSecondary,
                        )),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Read-out grid — a bordered surface card of label/value pairs.
class CalcReadout extends StatelessWidget {
  final List<({String label, String value, bool accent})> items;
  const CalcReadout({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ui = theme.extension<RadianUiTheme>()!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ui.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ui.border),
      ),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 10,
        childAspectRatio: 5.6,
        children: items.map((item) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.label.toUpperCase(),
                  style: theme.textTheme.bodyMedium!.copyWith(
                      color: ui.textFaint, fontSize: 9.5, letterSpacing: 1.0, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(item.value,
                  style: theme.textTheme.displayMedium!.copyWith(
                    color: item.accent ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  )),
            ],
          );
        }).toList(),
      ),
    );
  }
}

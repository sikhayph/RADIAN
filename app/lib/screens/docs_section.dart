// ─────────────────────────────────────────────────────────────────────────────
// docs_section.dart
// Native "Docs" screen — fetches the website's docs search index
// (services/docs_api.dart) and renders it as an accordion: one row per
// document (BLE Contract, Architecture, Hardware Pinout, UI Spec), expanding
// to that document's heading sections. Badge labels/accent colors mirror
// app/docs/page.tsx's ACCENT / BADGE_LABEL maps on the website.
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/docs_api.dart';
import 'async_status.dart';

const Map<String, String> _badgeLabel = {
  'ble-contract': 'BLE',
  'architecture': 'ARCH',
  'hardware-pinout': 'HW',
  'ui-spec': 'UI',
};

Color _docAccent(String slug, ThemeData theme, RadianCanvasTheme canvas) {
  switch (slug) {
    case 'ble-contract':
      return theme.colorScheme.primary;
    case 'architecture':
      return canvas.arm1Color;
    case 'hardware-pinout':
      return canvas.arm2Color;
    case 'ui-spec':
      return canvas.resultantColor;
    default:
      return theme.colorScheme.primary;
  }
}

class DocsSection extends StatefulWidget {
  const DocsSection({super.key});

  @override
  State<DocsSection> createState() => _DocsSectionState();
}

class _DocsSectionState extends State<DocsSection> {
  late Future<List<DocGroup>> _future;

  @override
  void initState() {
    super.initState();
    _future = fetchDocsIndex();
  }

  void _retry() => setState(() => _future = fetchDocsIndex());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DocGroup>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const AsyncLoadingState();
        }
        if (snapshot.hasError) {
          return AsyncErrorState(message: snapshot.error.toString(), onRetry: _retry);
        }
        final groups = snapshot.data ?? const [];
        if (groups.isEmpty) {
          return AsyncErrorState(message: 'No documents found.', onRetry: _retry);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < groups.length; i++) ...[
              _DocCard(group: groups[i]),
              if (i != groups.length - 1) const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

class _DocCard extends StatefulWidget {
  final DocGroup group;
  const _DocCard({required this.group});

  @override
  State<_DocCard> createState() => _DocCardState();
}

class _DocCardState extends State<_DocCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ui = theme.extension<RadianUiTheme>()!;
    final canvas = theme.extension<RadianCanvasTheme>()!;
    final accent = _docAccent(widget.group.slug, theme, canvas);
    final label = _badgeLabel[widget.group.slug] ?? widget.group.slug.toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: ui.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ui.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(label,
                        style: TextStyle(
                          color: accent,
                          fontFamily: 'JetBrainsMono',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        )),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(widget.group.title,
                        style: theme.textTheme.bodyLarge!.copyWith(
                            fontSize: 14, fontWeight: FontWeight.w600, color: ui.textPrimary)),
                  ),
                  AnimatedRotation(
                    turns: _open ? 0.125 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(Icons.add, size: 18, color: ui.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: _open ? _DocSections(sections: widget.group.sections) : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _DocSections extends StatelessWidget {
  final List<DocSection> sections;
  const _DocSections({required this.sections});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ui = theme.extension<RadianUiTheme>()!;

    if (sections.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Text('No sections indexed for this document yet.',
            style: theme.textTheme.bodyMedium!
                .copyWith(color: ui.textFaint, fontSize: 12.5, fontStyle: FontStyle.italic)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 1, color: ui.divider),
        for (final section in sections)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(section.heading,
                    style: theme.textTheme.bodyMedium!.copyWith(
                        color: ui.textPrimary, fontSize: 12.5, fontWeight: FontWeight.w600)),
                if (section.text.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(section.text,
                      style: theme.textTheme.bodyMedium!
                          .copyWith(color: ui.textSecondary, fontSize: 12, height: 1.5)),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

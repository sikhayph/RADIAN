// ─────────────────────────────────────────────────────────────────────────────
// faq_section.dart
// Native "FAQ" screen — fetches the website's FAQ endpoint
// (services/faq_api.dart) and renders it as an accordion, matching
// components/ui/Faq.tsx's flat question list (tap a question to expand its
// answer, chevron rotates 45°). Each row also shows its category as a small
// muted tag, using the category data the API already sends.
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/faq_api.dart';
import 'async_status.dart';

class FaqSection extends StatefulWidget {
  const FaqSection({super.key});

  @override
  State<FaqSection> createState() => _FaqSectionState();
}

class _FaqSectionState extends State<FaqSection> {
  late Future<FaqData> _future;

  @override
  void initState() {
    super.initState();
    _future = fetchFaq();
  }

  void _retry() => setState(() => _future = fetchFaq());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FaqData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const AsyncLoadingState();
        }
        if (snapshot.hasError) {
          return AsyncErrorState(message: snapshot.error.toString(), onRetry: _retry);
        }
        final items = snapshot.data?.items ?? const [];
        if (items.isEmpty) {
          return AsyncErrorState(message: 'No FAQ entries found.', onRetry: _retry);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < items.length; i++) ...[
              _FaqRow(item: items[i]),
              if (i != items.length - 1) const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

class _FaqRow extends StatefulWidget {
  final FaqItem item;
  const _FaqRow({required this.item});

  @override
  State<_FaqRow> createState() => _FaqRowState();
}

class _FaqRowState extends State<_FaqRow> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ui = theme.extension<RadianUiTheme>()!;

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
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.item.question,
                            style: theme.textTheme.bodyLarge!.copyWith(
                                fontSize: 13.5, fontWeight: FontWeight.w600, color: ui.textPrimary)),
                        if (widget.item.category.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(widget.item.category.toUpperCase(),
                              style: theme.textTheme.bodyMedium!.copyWith(
                                  color: ui.textFaint, fontSize: 9.5, letterSpacing: 1.0)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: AnimatedRotation(
                      turns: _open ? 0.125 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(Icons.add, size: 18, color: ui.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: _open
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: Text(widget.item.answer,
                        style: theme.textTheme.bodyMedium!
                            .copyWith(color: ui.textSecondary, fontSize: 12.5, height: 1.5)),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

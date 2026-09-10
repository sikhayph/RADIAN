// ─────────────────────────────────────────────────────────────────────────────
// docs_api.dart
// Client for the website's docs search index —
// https://radian-alpha.vercel.app/api/docs-index (see
// website/app/api/docs-index/route.ts). The endpoint returns the flat
// heading-level search index (website/public/search-index.json) as a JSON
// array of { slug, docTitle, heading, level, anchor, text }. We group those
// entries by slug into per-document sections for the native Docs screen.
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String _docsIndexUrl = 'https://radian-alpha.vercel.app/api/docs-index';

class DocsApiException implements Exception {
  final String message;
  const DocsApiException(this.message);
  @override
  String toString() => message;
}

/// One heading-level entry from the search index.
class DocSection {
  final String slug;
  final String docTitle;
  final String heading;
  final int level;
  final String anchor;
  final String text;

  const DocSection({
    required this.slug,
    required this.docTitle,
    required this.heading,
    required this.level,
    required this.anchor,
    required this.text,
  });

  factory DocSection.fromJson(Map<String, dynamic> json) {
    return DocSection(
      slug: json['slug'] as String? ?? '',
      docTitle: json['docTitle'] as String? ?? '',
      heading: json['heading'] as String? ?? '',
      level: (json['level'] as num?)?.toInt() ?? 1,
      anchor: json['anchor'] as String? ?? '',
      text: json['text'] as String? ?? '',
    );
  }
}

/// One document — its title plus its level ≥2 heading sections (the level-1
/// entry is the document's own title, so it isn't listed again as a section).
class DocGroup {
  final String slug;
  final String title;
  final List<DocSection> sections;
  const DocGroup({required this.slug, required this.title, required this.sections});
}

/// Fetches and groups the docs index. Throws [DocsApiException] on any
/// non-2xx response, unparsable body, or network failure — the caller
/// (DocsSection) catches it and shows a retry state.
Future<List<DocGroup>> fetchDocsIndex() async {
  http.Response res;
  try {
    res = await http.get(Uri.parse(_docsIndexUrl)).timeout(const Duration(seconds: 15));
  } on TimeoutException {
    throw const DocsApiException('Network error. Please check your connection and try again.');
  } catch (_) {
    throw const DocsApiException('Network error. Please check your connection and try again.');
  }

  if (res.statusCode < 200 || res.statusCode >= 300) {
    throw DocsApiException('Failed to load docs (HTTP ${res.statusCode}).');
  }

  dynamic decoded;
  try {
    decoded = jsonDecode(res.body);
  } catch (_) {
    throw const DocsApiException('Received an unreadable response from the docs index.');
  }
  if (decoded is! List) {
    throw const DocsApiException('Unexpected docs index format.');
  }

  final entries = decoded
      .whereType<Map<String, dynamic>>()
      .map(DocSection.fromJson)
      .toList();

  final order = <String>[];
  final titles = <String, String>{};
  final sections = <String, List<DocSection>>{};

  for (final entry in entries) {
    if (!sections.containsKey(entry.slug)) {
      sections[entry.slug] = [];
      order.add(entry.slug);
      titles[entry.slug] = entry.docTitle;
    }
    if (entry.level >= 2) sections[entry.slug]!.add(entry);
  }

  return order
      .map((slug) => DocGroup(slug: slug, title: titles[slug] ?? slug, sections: sections[slug]!))
      .toList();
}

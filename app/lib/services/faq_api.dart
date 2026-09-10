// ─────────────────────────────────────────────────────────────────────────────
// faq_api.dart
// Client for the website's FAQ endpoint —
// https://radian-alpha.vercel.app/api/faq (see website/app/api/faq/route.ts,
// which serves website/lib/faq.ts as { categories: string[], faq: FaqItem[] }).
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String _faqUrl = 'https://radian-alpha.vercel.app/api/faq';

class FaqApiException implements Exception {
  final String message;
  const FaqApiException(this.message);
  @override
  String toString() => message;
}

class FaqItem {
  final String question;
  final String answer;
  final String category;
  const FaqItem({required this.question, required this.answer, required this.category});

  factory FaqItem.fromJson(Map<String, dynamic> json) {
    return FaqItem(
      question: json['q'] as String? ?? '',
      answer: json['a'] as String? ?? '',
      category: json['category'] as String? ?? '',
    );
  }
}

class FaqData {
  final List<String> categories;
  final List<FaqItem> items;
  const FaqData({required this.categories, required this.items});
}

/// Fetches the FAQ list. Throws [FaqApiException] on any non-2xx response,
/// unparsable body, or network failure — the caller (FaqSection) catches it
/// and shows a retry state.
Future<FaqData> fetchFaq() async {
  http.Response res;
  try {
    res = await http.get(Uri.parse(_faqUrl)).timeout(const Duration(seconds: 15));
  } on TimeoutException {
    throw const FaqApiException('Network error. Please check your connection and try again.');
  } catch (_) {
    throw const FaqApiException('Network error. Please check your connection and try again.');
  }

  if (res.statusCode < 200 || res.statusCode >= 300) {
    throw FaqApiException('Failed to load the FAQ (HTTP ${res.statusCode}).');
  }

  dynamic decoded;
  try {
    decoded = jsonDecode(res.body);
  } catch (_) {
    throw const FaqApiException('Received an unreadable response from the FAQ endpoint.');
  }
  if (decoded is! Map<String, dynamic>) {
    throw const FaqApiException('Unexpected FAQ response format.');
  }

  final categories = (decoded['categories'] as List?)?.whereType<String>().toList() ?? const [];
  final items = (decoded['faq'] as List?)
          ?.whereType<Map<String, dynamic>>()
          .map(FaqItem.fromJson)
          .toList() ??
      const [];

  return FaqData(categories: categories, items: items);
}

// ─────────────────────────────────────────────────────────────────────────────
// waitlist_api.dart
// Client for the website's waitlist endpoint — POSTs an email to
// https://radian-alpha.vercel.app/api/waitlist and maps the response to a
// WaitlistResult. Request shape and response handling mirror
// website/app/api/waitlist/route.ts + components/ui/WaitlistForm.tsx exactly:
//   - 201 { status: 'subscribed' }         → success, new signup
//   - 200 { status: 'already_subscribed' } → success, already on the list
//   - 400 { error: string }                → validation error (bad email)
//   - 429 { error: string }                → rate limited
//   - anything else / network failure      → generic error
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String _waitlistUrl = 'https://radian-alpha.vercel.app/api/waitlist';

/// Deliberately pragmatic, not RFC 5322-complete — matches
/// website/lib/waitlist/validate.ts's EMAIL_RE exactly so client-side
/// validation rejects the same inputs the server would.
final RegExp _emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
const int _maxEmailLength = 254;

bool isValidEmail(String raw) {
  final email = raw.trim();
  if (email.isEmpty || email.length > _maxEmailLength) return false;
  if ('@'.allMatches(email).length != 1) return false;
  return _emailRe.hasMatch(email);
}

enum WaitlistOutcome { subscribed, alreadySubscribed, error }

class WaitlistResult {
  final WaitlistOutcome outcome;
  final String message;
  const WaitlistResult(this.outcome, this.message);

  bool get isDone => outcome != WaitlistOutcome.error;
}

/// POSTs [email] to the waitlist API. Never throws — network/parse failures
/// come back as a WaitlistResult with outcome == error, same as the website
/// form's catch block.
Future<WaitlistResult> joinWaitlist(String email) async {
  try {
    final res = await http
        .post(
          Uri.parse(_waitlistUrl),
          headers: const {'Content-Type': 'application/json'},
          // 'company' is the website form's honeypot field — always empty here.
          body: jsonEncode({'email': email, 'company': ''}),
        )
        .timeout(const Duration(seconds: 15));

    Map<String, dynamic> data = const {};
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) data = decoded;
    } catch (_) {
      // Non-JSON body — fall through to status-code-based handling below.
    }

    if (res.statusCode == 200 && data['status'] == 'already_subscribed') {
      return const WaitlistResult(
        WaitlistOutcome.alreadySubscribed,
        "You're already on the list — we'll be in touch.",
      );
    }
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return const WaitlistResult(
        WaitlistOutcome.subscribed,
        "You're on the list. We'll email you when v1 ships.",
      );
    }

    // 400 (validation), 429 (rate limit), or anything else the server sends —
    // surface its error message the same way the website form does.
    final serverMessage = data['error'];
    return WaitlistResult(
      WaitlistOutcome.error,
      serverMessage is String ? serverMessage : 'Something went wrong. Please try again.',
    );
  } on TimeoutException {
    return const WaitlistResult(
      WaitlistOutcome.error,
      'Network error. Please check your connection and try again.',
    );
  } catch (_) {
    return const WaitlistResult(
      WaitlistOutcome.error,
      'Network error. Please check your connection and try again.',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// waitlist_section.dart
// "Join the Waitlist" — native port of components/ui/WaitlistForm.tsx. Posts
// to the website's live waitlist API (services/waitlist_api.dart) and handles
// the same states the website form does: idle, submitting, subscribed,
// already-subscribed, and error (validation / rate-limit / network).
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/waitlist_api.dart';

class WaitlistSection extends StatefulWidget {
  const WaitlistSection({super.key});

  @override
  State<WaitlistSection> createState() => _WaitlistSectionState();
}

enum _Status { idle, submitting, done, error }

class _WaitlistSectionState extends State<WaitlistSection> {
  final _controller = TextEditingController();
  _Status _status = _Status.idle;
  String _message = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_status == _Status.submitting) return;

    final email = _controller.text.trim();
    if (!isValidEmail(email)) {
      setState(() {
        _status = _Status.error;
        _message = 'Enter a valid email address.';
      });
      return;
    }

    setState(() {
      _status = _Status.submitting;
      _message = '';
    });

    final result = await joinWaitlist(email);
    if (!mounted) return;

    setState(() {
      _status = result.isDone ? _Status.done : _Status.error;
      _message = result.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ui = theme.extension<RadianUiTheme>()!;
    final canvas = theme.extension<RadianCanvasTheme>()!;

    if (_status == _Status.done) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: ui.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ui.border),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ui.success.withOpacity(0.2),
              ),
              child: Icon(Icons.check, size: 14, color: ui.success),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(_message,
                  style: theme.textTheme.bodyMedium!.copyWith(color: ui.textPrimary, fontSize: 13)),
            ),
          ],
        ),
      );
    }

    final showError = _status == _Status.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Email address',
            style: theme.textTheme.bodyMedium!.copyWith(
                color: ui.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        LayoutBuilder(builder: (context, constraints) {
          final field = TextField(
            controller: _controller,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            style: theme.textTheme.bodyLarge!.copyWith(fontSize: 14),
            decoration: const InputDecoration(
              isDense: true,
              hintText: 'you@school.edu',
            ),
            onChanged: (_) {
              if (_status == _Status.error) {
                setState(() {
                  _status = _Status.idle;
                  _message = '';
                });
              }
            },
            onSubmitted: (_) => _submit(),
          );

          final button = SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: _status == _Status.submitting ? null : _submit,
              child: _status == _Status.submitting
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: theme.colorScheme.onPrimary),
                    )
                  : const Text('Join the waitlist'),
            ),
          );

          if (constraints.maxWidth >= 420) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: field),
                const SizedBox(width: 12),
                button,
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              field,
              const SizedBox(height: 12),
              button,
            ],
          );
        }),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 18),
          child: showError
              ? Text(_message,
                  style: theme.textTheme.bodyMedium!.copyWith(color: canvas.arm1Color, fontSize: 12.5))
              : null,
        ),
      ],
    );
  }
}

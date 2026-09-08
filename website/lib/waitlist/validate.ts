// ─────────────────────────────────────────────────────────────────────────────
// lib/waitlist/validate.ts
// Email validation + normalization for the waitlist route. No dependencies.
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

// Deliberately pragmatic, not RFC 5322-complete: one @, non-empty local part,
// a dotted domain with a 2+ char TLD, no whitespace. Good enough to reject
// typos and junk without turning away valid addresses.
const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/

/** Max email length per the RFC (local 64 + @ + domain 255, capped at 254). */
export const MAX_EMAIL_LENGTH = 254

export function normalizeEmail(raw: string): string {
  return raw.trim().toLowerCase()
}

export function isValidEmail(raw: unknown): raw is string {
  if (typeof raw !== 'string') return false
  const email = raw.trim()
  if (email.length === 0 || email.length > MAX_EMAIL_LENGTH) return false
  if ((email.match(/@/g) ?? []).length !== 1) return false
  return EMAIL_RE.test(email)
}

// ─────────────────────────────────────────────────────────────────────────────
// lib/waitlist/rateLimit.ts
// Tiny in-memory sliding-window rate limiter, keyed by client IP.
//
// Process-local, same caveat as the in-memory store: per serverless instance,
// resets on cold start. Enough to blunt casual abuse of the waitlist form.
//
// FOLLOW-UP: replace with @upstash/ratelimit (sliding window) once Redis is
// wired — same call site, just `await ratelimit.limit(ip)`.
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

const WINDOW_MS = 10 * 60 * 1000 // 10 minutes
const MAX_HITS = 5 // per window, per IP

const globalForRateLimit = globalThis as unknown as {
  __waitlistHits?: Map<string, number[]>
}

function hits(): Map<string, number[]> {
  if (!globalForRateLimit.__waitlistHits) {
    globalForRateLimit.__waitlistHits = new Map()
  }
  return globalForRateLimit.__waitlistHits
}

export interface RateLimitResult {
  ok: boolean
  /** Seconds until the window frees up (only meaningful when ok === false). */
  retryAfter: number
}

/** Records one hit for `key` and reports whether it is within the limit. */
export function checkRateLimit(key: string): RateLimitResult {
  const now = Date.now()
  const store = hits()
  const recent = (store.get(key) ?? []).filter((t) => now - t < WINDOW_MS)

  if (recent.length >= MAX_HITS) {
    const oldest = recent[0]
    store.set(key, recent)
    return { ok: false, retryAfter: Math.ceil((WINDOW_MS - (now - oldest)) / 1000) }
  }

  recent.push(now)
  store.set(key, recent)

  // Opportunistic cleanup so the map does not grow unbounded.
  if (store.size > 5000) {
    store.forEach((times, k) => {
      if (times.every((t) => now - t >= WINDOW_MS)) store.delete(k)
    })
  }

  return { ok: true, retryAfter: 0 }
}

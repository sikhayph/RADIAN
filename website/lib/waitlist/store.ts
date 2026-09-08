// ─────────────────────────────────────────────────────────────────────────────
// lib/waitlist/store.ts
// Storage adapter for waitlist signups.
//
// Tonight only the in-memory implementation is wired. It is process-local, so
// on Vercel each serverless instance keeps its own set and entries do not
// survive a cold start — fine for local dev and a demo, NOT for production.
//
// FOLLOW-UP — swap to a durable store:
//   1. Add the Upstash Redis integration in the Vercel dashboard (injects
//      KV_REST_API_URL / KV_REST_API_TOKEN).
//   2. `npm i @upstash/redis`
//   3. Implement RedisWaitlistStore below and return it from getWaitlistStore()
//      when the env vars are present. Sketch:
//
//        import { Redis } from '@upstash/redis'
//        const redis = Redis.fromEnv()
//        // has:   await redis.sismember('waitlist:emails', email)
//        // add:   await redis.sadd('waitlist:emails', email)
//        //        await redis.hset(`waitlist:entry:${email}`, entry)
//        //        await redis.lpush('waitlist:log', email)
//        // count: await redis.scard('waitlist:emails')
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

export interface WaitlistEntry {
  email: string
  /** Unix epoch milliseconds. */
  ts: number
  /** Best-effort client IP, for abuse triage only. */
  ip?: string
}

export interface WaitlistStore {
  /** True if this (already-normalized) email is on the list. */
  has(email: string): Promise<boolean>
  /** Add an entry. Caller guarantees the email is normalized and new. */
  add(entry: WaitlistEntry): Promise<void>
  /** Total signups. */
  count(): Promise<number>
  /** All entries, newest first. Used by the token-guarded admin export. */
  list(): Promise<WaitlistEntry[]>
}

// ── In-memory implementation ─────────────────────────────────────────────────

class InMemoryWaitlistStore implements WaitlistStore {
  private readonly entries = new Map<string, WaitlistEntry>()

  async has(email: string): Promise<boolean> {
    return this.entries.has(email)
  }

  async add(entry: WaitlistEntry): Promise<void> {
    this.entries.set(entry.email, entry)
  }

  async count(): Promise<number> {
    return this.entries.size
  }

  async list(): Promise<WaitlistEntry[]> {
    return Array.from(this.entries.values()).sort((a, b) => b.ts - a.ts)
  }
}

// A single instance survives module reloads within one server process. In dev,
// Next.js hot-reload re-evaluates modules, so stash it on globalThis to keep
// submitted emails across edits.
const globalForWaitlist = globalThis as unknown as {
  __waitlistStore?: WaitlistStore
}

export function getWaitlistStore(): WaitlistStore {
  if (!globalForWaitlist.__waitlistStore) {
    globalForWaitlist.__waitlistStore = new InMemoryWaitlistStore()
  }
  return globalForWaitlist.__waitlistStore
}

// ─────────────────────────────────────────────────────────────────────────────
// app/api/waitlist/route.ts
// POST — add an email to the v1-hardware waitlist.
// GET  — token-guarded export of collected entries.
//
// Storage is in-memory tonight (see lib/waitlist/store.ts). The route contract
// is stable, so swapping in Redis later needs no changes here.
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import { NextRequest, NextResponse } from 'next/server'
import { getWaitlistStore } from '../../../lib/waitlist/store'
import { checkRateLimit } from '../../../lib/waitlist/rateLimit'
import { isValidEmail, normalizeEmail } from '../../../lib/waitlist/validate'

export const runtime = 'nodejs'
// Never cache — this route mutates and reads live state.
export const dynamic = 'force-dynamic'

function clientIp(req: NextRequest): string {
  const fwd = req.headers.get('x-forwarded-for')
  if (fwd) return fwd.split(',')[0]!.trim()
  return req.headers.get('x-real-ip') ?? 'unknown'
}

// ── POST ─────────────────────────────────────────────────────────────────────

export async function POST(req: NextRequest) {
  const ip = clientIp(req)

  const limit = checkRateLimit(ip)
  if (!limit.ok) {
    return NextResponse.json(
      { error: 'Too many attempts. Please try again in a little while.' },
      { status: 429, headers: { 'Retry-After': String(limit.retryAfter) } },
    )
  }

  let body: unknown
  try {
    body = await req.json()
  } catch {
    return NextResponse.json({ error: 'Invalid request body.' }, { status: 400 })
  }

  const { email, company } = (body ?? {}) as { email?: unknown; company?: unknown }

  // Honeypot — real users never see or fill the "company" field. Pretend success.
  if (typeof company === 'string' && company.trim() !== '') {
    return NextResponse.json({ status: 'subscribed' }, { status: 201 })
  }

  if (!isValidEmail(email)) {
    return NextResponse.json(
      { error: 'Enter a valid email address.' },
      { status: 400 },
    )
  }

  const normalized = normalizeEmail(email)
  const store = getWaitlistStore()

  if (await store.has(normalized)) {
    return NextResponse.json({ status: 'already_subscribed' }, { status: 200 })
  }

  await store.add({ email: normalized, ts: Date.now(), ip })

  return NextResponse.json({ status: 'subscribed' }, { status: 201 })
}

// ── GET — admin export ───────────────────────────────────────────────────────

export async function GET(req: NextRequest) {
  const token = process.env.WAITLIST_ADMIN_TOKEN
  const provided = req.nextUrl.searchParams.get('token')

  // If no token is configured, or it doesn't match, don't reveal the endpoint.
  if (!token || provided !== token) {
    return NextResponse.json({ error: 'Not found' }, { status: 404 })
  }

  const store = getWaitlistStore()
  const entries = await store.list()

  return NextResponse.json(
    { count: entries.length, entries },
    { headers: { 'Cache-Control': 'no-store' } },
  )
}

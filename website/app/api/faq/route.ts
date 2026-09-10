// ─────────────────────────────────────────────────────────────────────────────
// app/api/faq/route.ts
// GET — the FAQ content from lib/faq.ts as JSON, for the Flutter app to consume.
// Static data; no request handling beyond serving it.
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import { NextResponse } from 'next/server'
import { faq, getFaqCategories } from '../../../lib/faq'

export const runtime = 'nodejs'
export const dynamic = 'force-static'

export async function GET() {
  return NextResponse.json(
    { categories: getFaqCategories(), faq },
    { headers: { 'Cache-Control': 'public, max-age=0, s-maxage=3600' } },
  )
}

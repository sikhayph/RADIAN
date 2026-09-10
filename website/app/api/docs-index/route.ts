// ─────────────────────────────────────────────────────────────────────────────
// app/api/docs-index/route.ts
// GET — the build-time docs search index (public/search-index.json) as JSON,
// for the Flutter app to consume. Same records the web docs search uses.
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import { NextResponse } from 'next/server'
import searchIndex from '../../../public/search-index.json'

export const runtime = 'nodejs'
export const dynamic = 'force-static'

export async function GET() {
  return NextResponse.json(searchIndex, {
    headers: { 'Cache-Control': 'public, max-age=0, s-maxage=3600' },
  })
}

// ─────────────────────────────────────────────────────────────────────────────
// app/demo/page.tsx
// Demo page — server component shell that owns metadata; interactive tabs live
// in DemoClient (client component) so metadata can be exported from a server
// module (Next.js App Router forbids metadata exports from 'use client' files).
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import type { Metadata } from 'next'
import DemoClient from './DemoClient'

export const metadata: Metadata = {
  title: 'Demo | RADIAN',
  description:
    "Explore RADIAN's four interactive teaching modes — degree/radian conversion, vector addition, rotation matrices, and polygon angles — live in the browser.",
  openGraph: {
    title: 'Demo | RADIAN',
    description:
      "Explore RADIAN's four interactive teaching modes live in the browser.",
    type: 'website',
  },
}

export default function DemoPage() {
  return <DemoClient />
}

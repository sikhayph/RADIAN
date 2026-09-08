// ─────────────────────────────────────────────────────────────────────────────
// app/calculator/page.tsx
// Server shell — owns metadata; the interactive tabs live in CalculatorClient.
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import type { Metadata } from 'next'
import CalculatorClient from './CalculatorClient'

export const metadata: Metadata = {
  title: 'Calculator | RADIAN',
  description:
    'Work through the four RADIAN teaching modes in the browser — degree ⇄ radian conversion, vector addition, rotation matrices, and polygon angles, each with a live figure.',
  openGraph: {
    title: 'Calculator | RADIAN',
    description:
      'Degree ⇄ radian, vector addition, rotation matrices, and polygon angles — worked live in the browser.',
    type: 'website',
  },
}

export default function CalculatorPage() {
  return <CalculatorClient />
}

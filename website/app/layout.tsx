// ─────────────────────────────────────────────────────────────────────────────
// app/layout.tsx
// Root layout — Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title:       'RADIAN — Rotary Angular Display with Intuitive Angle Notation',
  description: 'An ESP32-powered educational device that teaches abstract mathematics through physical rotation. A Sikhay and Valiger collaboration.',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}

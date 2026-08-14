// ─────────────────────────────────────────────────────────────────────────────
// app/docs/page.tsx
// Documentation hub — lists all four docs as linked cards.
// Static Server Component (no 'use client').
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import type { Metadata } from 'next'
import Link from 'next/link'
import Reveal from '../../components/ui/Reveal'
import { getAllDocMeta, type DocMeta } from '../../lib/docs'

export const metadata: Metadata = {
  title:       'Docs | RADIAN',
  description: 'Technical documentation for the RADIAN system — BLE contract, system architecture, hardware pinout, and UI/UX specification.',
  openGraph: {
    title:       'Docs | RADIAN',
    description: 'Technical documentation for the RADIAN system — BLE contract, system architecture, hardware pinout, and UI/UX specification.',
    type:        'website',
  },
}

// ── Per-card accent colors map — keyed by slug ────────────────────────────────

const ACCENT: Record<string, { badge: string; glow: string }> = {
  'ble-contract':    { badge: 'text-[var(--primary)]   bg-[color-mix(in_srgb,var(--primary)_15%,transparent)]',   glow: 'hover:shadow-[0_0_40px_-8px_var(--primary)]   hover:border-[var(--primary)]'   },
  'architecture':    { badge: 'text-[var(--arm1)]      bg-[color-mix(in_srgb,var(--arm1)_15%,transparent)]',      glow: 'hover:shadow-[0_0_40px_-8px_var(--arm1)]      hover:border-[var(--arm1)]'      },
  'hardware-pinout': { badge: 'text-[var(--arm2)]      bg-[color-mix(in_srgb,var(--arm2)_15%,transparent)]',      glow: 'hover:shadow-[0_0_40px_-8px_var(--arm2)]      hover:border-[var(--arm2)]'      },
  'ui-spec':         { badge: 'text-[var(--resultant)] bg-[color-mix(in_srgb,var(--resultant)_15%,transparent)]', glow: 'hover:shadow-[0_0_40px_-8px_var(--resultant)] hover:border-[var(--resultant)]' },
}

const DELAY: Record<string, string> = {
  'ble-contract':    'delay-0',
  'architecture':    'delay-100',
  'hardware-pinout': 'delay-200',
  'ui-spec':         'delay-300',
}

// ── Short human label shown in the badge ──────────────────────────────────────

const BADGE_LABEL: Record<string, string> = {
  'ble-contract':    'BLE',
  'architecture':    'ARCH',
  'hardware-pinout': 'HW',
  'ui-spec':         'UI',
}

// ── Component ─────────────────────────────────────────────────────────────────

function DocCard({ doc }: { doc: DocMeta }) {
  const accent = ACCENT[doc.slug] ?? ACCENT['ble-contract']
  const delay  = DELAY[doc.slug]  ?? 'delay-0'
  const label  = BADGE_LABEL[doc.slug] ?? doc.slug.toUpperCase()

  return (
    <Reveal delayClass={delay} className="h-full">
      <Link
        href={`/docs/${doc.slug}`}
        className="group h-full rounded-2xl p-6 border border-[var(--border)] bg-[var(--surface)] flex flex-col gap-3 no-underline transition-all duration-500 ease-premium hover:-translate-y-1 block"
        style={{ display: 'flex' }}
      >
        {/* Badge row */}
        <div className="flex items-center gap-3">
          <span
            className={`inline-flex items-center justify-center px-2.5 py-0.5 rounded-md text-xs font-bold font-mono flex-shrink-0 ${accent.badge}`}
          >
            {label}
          </span>
          <h2 className="text-base font-semibold leading-snug text-[var(--text)] group-hover:text-[var(--primary)] transition-colors duration-300">
            {doc.title}
          </h2>
        </div>

        {/* Description */}
        <p className="text-sm leading-relaxed text-[var(--muted)] flex-1">
          {doc.description}
        </p>

        {/* Arrow cue */}
        <span className="text-xs font-mono text-[var(--muted)] group-hover:text-[var(--primary)] transition-colors duration-300 mt-1">
          Read doc →
        </span>
      </Link>
    </Reveal>
  )
}

export default function DocsPage() {
  const docs = getAllDocMeta()

  return (
    <main className="min-h-screen pt-28 pb-24">
      <div className="max-w-5xl mx-auto px-6">

        {/* ── Page heading ─────────────────────────────────────────────────── */}
        <Reveal className="mb-14 text-center">
          <p className="text-sm font-mono tracking-widest mb-4 uppercase text-[var(--primary)]">
            Technical Reference
          </p>
          <h1 className="text-4xl lg:text-5xl font-bold text-[var(--text)] mb-4">
            Documentation
          </h1>
          <p className="text-base leading-relaxed max-w-xl mx-auto text-[var(--muted)]">
            Internal technical specs for the RADIAN hardware device, firmware
            BLE contract, companion app UI, and full system architecture.
          </p>
        </Reveal>

        {/* ── 2×2 card grid ────────────────────────────────────────────────── */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
          {docs.map((doc) => (
            <DocCard key={doc.slug} doc={doc} />
          ))}
        </div>

        {/* ── Footer note ──────────────────────────────────────────────────── */}
        <Reveal delayClass="delay-300" className="mt-16 text-center">
          <p className="text-xs text-[var(--muted)] font-mono">
            Sikhay Research, Development and Prototyping × Valiger — Internal · Proprietary
          </p>
        </Reveal>

      </div>
    </main>
  )
}
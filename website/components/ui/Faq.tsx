// ─────────────────────────────────────────────────────────────────────────────
// components/ui/Faq.tsx
// Accordion FAQ list. Content is sourced entirely from lib/faq.ts.
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

'use client'

import { useState } from 'react'
import Reveal from './Reveal'
import { faq } from '../../lib/faq'

function FaqRow({
  q,
  a,
  open,
  onToggle,
}: {
  q: string
  a: string
  open: boolean
  onToggle: () => void
}) {
  return (
    <div className="rounded-2xl border border-[var(--border)] bg-[var(--surface)] transition-colors duration-300">
      <h3>
        <button
          type="button"
          onClick={onToggle}
          aria-expanded={open}
          className="flex w-full items-center justify-between gap-4 px-6 py-5 text-left"
        >
          <span className="text-base font-semibold text-[var(--text)]">{q}</span>
          <span
            aria-hidden="true"
            className={`flex-shrink-0 text-[var(--muted)] transition-transform duration-300 ease-premium ${
              open ? 'rotate-45' : ''
            }`}
          >
            <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
              <path
                d="M8 3v10M3 8h10"
                stroke="currentColor"
                strokeWidth="1.5"
                strokeLinecap="round"
              />
            </svg>
          </span>
        </button>
      </h3>
      <div
        className={`grid transition-all duration-300 ease-premium ${
          open ? 'grid-rows-[1fr] opacity-100' : 'grid-rows-[0fr] opacity-0'
        }`}
      >
        <div className="overflow-hidden">
          <p className="px-6 pb-5 text-sm leading-relaxed text-[var(--muted)]">{a}</p>
        </div>
      </div>
    </div>
  )
}

export default function Faq() {
  const [openIndex, setOpenIndex] = useState<number | null>(null)

  return (
    <div className="mx-auto flex max-w-2xl flex-col gap-3">
      {faq.map((item, i) => (
        <Reveal key={item.q}>
          <FaqRow
            q={item.q}
            a={item.a}
            open={openIndex === i}
            onToggle={() => setOpenIndex(openIndex === i ? null : i)}
          />
        </Reveal>
      ))}
    </div>
  )
}

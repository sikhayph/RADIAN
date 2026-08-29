// ─────────────────────────────────────────────────────────────────────────────
// app/demo/DemoClient.tsx
// Interactive demo shell — mode tab bar + per-mode preview panel.
// Canvas visualizations are planned for the v1 hardware release.
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

'use client'

import { useState } from 'react'
import Reveal from '../../components/ui/Reveal'

// ── Mode metadata (mirrors ModeShowcase.tsx exactly) ──────────────────────────

const modes = [
  {
    n:          1,
    name:       'Degree / Radian',
    desc:       'Unit circle, arc length, sin / cos — read live off the dial.',
    badgeText:  'text-[var(--primary)]',
    badgeBg:    'bg-[color-mix(in_srgb,var(--primary)_15%,transparent)]',
  },
  {
    n:          2,
    name:       'Vector Addition',
    desc:       'Two arms combine into a resultant with live magnitude and angle.',
    badgeText:  'text-[var(--arm1)]',
    badgeBg:    'bg-[color-mix(in_srgb,var(--arm1)_15%,transparent)]',
  },
  {
    n:          3,
    name:       'Rotation Matrix',
    desc:       'A 2×2 transform applied in real time, with its geometric effect.',
    badgeText:  'text-[var(--arm2)]',
    badgeBg:    'bg-[color-mix(in_srgb,var(--arm2)_15%,transparent)]',
  },
  {
    n:          4,
    name:       'Polygon Snap',
    desc:       'Interior, exterior, and central angles snap as sides are added.',
    badgeText:  'text-[var(--resultant)]',
    badgeBg:    'bg-[color-mix(in_srgb,var(--resultant)_15%,transparent)]',
  },
] as const

// ── Component ─────────────────────────────────────────────────────────────────

export default function DemoClient() {
  const [activeMode, setActiveMode] = useState(0)
  const mode = modes[activeMode]

  return (
    <main className="min-h-screen pt-16">

      {/* ── Page heading ──────────────────────────────────────────────────── */}
      <section className="py-[120px]">
        <div className="max-w-6xl mx-auto px-6">

          <Reveal className="text-center mb-12">
            <p className="text-sm font-mono tracking-widest mb-3 uppercase text-[var(--primary)]">
              Interactive Demos
            </p>
            <h1 className="text-4xl lg:text-5xl font-bold mb-4 bg-clip-text text-transparent bg-[linear-gradient(90deg,var(--primary),var(--arm1))]">
              Explore the four modes
            </h1>
            <p className="text-base leading-relaxed max-w-xl mx-auto text-[var(--muted)]">
              Each mode maps to one RADIAN teaching concept. Select a tab to load its
              interactive canvas demo.
            </p>
          </Reveal>

          {/* ── Mode selector tabs ──────────────────────────────────────── */}
          <Reveal delayClass="delay-100">
            <div className="flex flex-wrap gap-3 justify-center mb-8">
              {modes.map((m, i) => (
                <button
                  key={m.n}
                  onClick={() => setActiveMode(i)}
                  aria-pressed={activeMode === i}
                  className={`flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-medium border transition-all duration-300 ease-premium ${
                    activeMode === i
                      ? 'border-[var(--primary)] bg-[color-mix(in_srgb,var(--primary)_12%,transparent)] text-[var(--text)]'
                      : 'border-[var(--border)] bg-transparent text-[var(--muted)] hover:text-[var(--text)]'
                  }`}
                >
                  <span
                    className={`w-6 h-6 rounded-full flex items-center justify-center text-xs font-bold font-mono flex-shrink-0 ${m.badgeBg} ${m.badgeText}`}
                  >
                    {m.n}
                  </span>
                  {m.name}
                </button>
              ))}
            </div>
          </Reveal>

          {/* ── Mode preview panel ──────────────────────────────────────── */}
          <Reveal delayClass="delay-200">
            <div className="rounded-2xl border border-[var(--border)] bg-[var(--surface)] p-12 flex flex-col items-center justify-center text-center min-h-[420px] transition-all duration-500 ease-premium">

              {/* Mode badge */}
              <span
                className={`w-14 h-14 rounded-full flex items-center justify-center text-2xl font-bold font-mono mb-6 ${mode.badgeBg} ${mode.badgeText}`}
              >
                {mode.n}
              </span>

              {/* Mode name */}
              <h2 className={`text-2xl font-bold mb-3 ${mode.badgeText}`}>
                {mode.name}
              </h2>

              {/* Short description from mode metadata */}
              <p className="text-[var(--muted)] text-sm mb-6 max-w-sm leading-relaxed">
                {mode.desc}
              </p>

              {/* Status label */}
              <span className="inline-flex items-center gap-2 text-xs font-mono px-3 py-1.5 rounded-full border border-[var(--border)] text-[var(--muted)]">
                Canvas demo — available with v1 hardware release
              </span>

            </div>
          </Reveal>

        </div>
      </section>

    </main>
  )
}

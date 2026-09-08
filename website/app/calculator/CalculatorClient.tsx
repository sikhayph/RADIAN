// ─────────────────────────────────────────────────────────────────────────────
// app/calculator/CalculatorClient.tsx
// Interactive calculator shell — four tabs, one per RADIAN teaching mode.
// All math is client-side (lib/calculator/math.ts); no backend.
// Tab-bar pattern mirrors app/demo/DemoClient.tsx.
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

'use client'

import { useState } from 'react'
import Reveal from '../../components/ui/Reveal'
import { modes } from '../../lib/specs'
import { modeAccent } from '../../components/ui/modeAccent'
import DegreeRadianPanel from '../../components/calculator/DegreeRadianPanel'
import VectorPanel from '../../components/calculator/VectorPanel'
import RotationPanel from '../../components/calculator/RotationPanel'
import PolygonPanel from '../../components/calculator/PolygonPanel'

const PANELS = [DegreeRadianPanel, VectorPanel, RotationPanel, PolygonPanel]

export default function CalculatorClient() {
  const [active, setActive] = useState(0)
  const Panel = PANELS[active]
  const mode = modes[active]
  const accent = modeAccent(mode.accent)

  return (
    <main className="min-h-screen pt-16">
      <section className="py-[120px]">
        <div className="max-w-6xl mx-auto px-6">

          <Reveal className="text-center mb-12">
            <p className="text-sm font-mono tracking-widest mb-3 uppercase text-[var(--primary)]">
              Interactive Calculator
            </p>
            <h1 className="text-4xl lg:text-5xl font-bold mb-4 bg-clip-text text-transparent bg-[linear-gradient(90deg,var(--primary),var(--arm1))]">
              Run the math yourself
            </h1>
            <p className="text-base leading-relaxed max-w-xl mx-auto text-[var(--muted)]">
              The same four concepts RADIAN teaches on the dial — worked out live in the
              browser, with the figure updating as you type.
            </p>
          </Reveal>

          {/* Tabs */}
          <Reveal delayClass="delay-100">
            <div
              role="group"
              aria-label="Calculator modes"
              className="flex flex-wrap gap-3 justify-center mb-10"
            >
              {modes.map((m, i) => {
                const a = modeAccent(m.accent)
                return (
                  <button
                    key={m.n}
                    aria-pressed={active === i}
                    onClick={() => setActive(i)}
                    className={`flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-medium border transition-all duration-300 ease-premium ${
                      active === i
                        ? 'border-[var(--primary)] bg-[color-mix(in_srgb,var(--primary)_12%,transparent)] text-[var(--text)]'
                        : 'border-[var(--border)] bg-transparent text-[var(--muted)] hover:text-[var(--text)]'
                    }`}
                  >
                    <span
                      className={`w-6 h-6 rounded-full flex items-center justify-center text-xs font-bold font-mono flex-shrink-0 ${a.bg} ${a.text}`}
                    >
                      {m.n}
                    </span>
                    {m.name}
                  </button>
                )
              })}
            </div>
          </Reveal>

          {/* Active panel */}
          <Reveal key={active} delayClass="delay-100">
            <div className="rounded-2xl border border-[var(--border)] bg-[color-mix(in_srgb,var(--surface)_50%,transparent)] p-6 sm:p-10">
              <div className="mb-8 flex items-center gap-3">
                <span
                  className={`w-9 h-9 rounded-full flex items-center justify-center text-sm font-bold font-mono flex-shrink-0 ${accent.bg} ${accent.text}`}
                >
                  {mode.n}
                </span>
                <div>
                  <h2 className="text-lg font-semibold text-[var(--text)]">{mode.name}</h2>
                  <p className="text-xs text-[var(--muted)]">{mode.desc}</p>
                </div>
              </div>
              <Panel />
            </div>
          </Reveal>

        </div>
      </section>
    </main>
  )
}

// ─────────────────────────────────────────────────────────────────────────────
// components/ui/ModeShowcase.tsx
// Landing page mode grid — four teaching modes, 2×2
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import Reveal from './Reveal'
import { modes } from '../../lib/specs'
import { modeAccent, MODE_DELAY } from './modeAccent'

export default function ModeShowcase() {
  return (
    <section className="py-[120px]">
      <div className="max-w-6xl mx-auto px-6">

        {/* Section heading */}
        <Reveal className="text-center mb-12">
          <p className="text-sm font-mono tracking-widest mb-3 uppercase text-[var(--primary)]">
            Four Modes, One Dial
          </p>
          <h2 className="text-3xl lg:text-4xl font-bold text-[var(--text)]">
            What RADIAN teaches
          </h2>
        </Reveal>

        {/* 2×2 grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
          {modes.map((mode) => {
            const accent = modeAccent(mode.accent)
            return (
            <Reveal key={mode.n} delayClass={MODE_DELAY[mode.n]} className="h-full">
              <div className="h-full rounded-2xl p-6 border border-[var(--border)] bg-[var(--surface)] transition-all duration-500 ease-premium hover:-translate-y-1 hover:border-[var(--primary)] hover:shadow-[0_0_40px_-8px_var(--primary)]">
                <div className="flex items-center gap-3 mb-3">
                  <span
                    className={`w-9 h-9 rounded-full flex items-center justify-center text-sm font-bold font-mono flex-shrink-0 ${accent.bg} ${accent.text}`}
                  >
                    {mode.n}
                  </span>
                  <h3 className="text-lg font-semibold text-[var(--text)]">
                    {mode.name}
                  </h3>
                </div>
                <p className="text-sm leading-relaxed text-[var(--muted)]">
                  {mode.desc}
                </p>
              </div>
            </Reveal>
            )
          })}
        </div>

      </div>
    </section>
  )
}

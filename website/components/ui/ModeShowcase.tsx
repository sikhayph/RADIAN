// ─────────────────────────────────────────────────────────────────────────────
// components/ui/ModeShowcase.tsx
// Landing page mode grid — four teaching modes, 2×2
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import Reveal from './Reveal'

const modes = [
  {
    n:        1,
    name:     'Degree / Radian',
    desc:     'Unit circle, arc length, sin / cos — read live off the dial.',
    badgeText: 'text-[var(--primary)]',
    badgeBg:   'bg-[color-mix(in_srgb,var(--primary)_15%,transparent)]',
    delayClass: 'delay-0',
  },
  {
    n:        2,
    name:     'Vector Addition',
    desc:     'Two arms combine into a resultant with live magnitude and angle.',
    badgeText: 'text-[var(--arm1)]',
    badgeBg:   'bg-[color-mix(in_srgb,var(--arm1)_15%,transparent)]',
    delayClass: 'delay-100',
  },
  {
    n:        3,
    name:     'Rotation Matrix',
    desc:     'A 2×2 transform applied in real time, with its geometric effect.',
    badgeText: 'text-[var(--arm2)]',
    badgeBg:   'bg-[color-mix(in_srgb,var(--arm2)_15%,transparent)]',
    delayClass: 'delay-200',
  },
  {
    n:        4,
    name:     'Polygon Snap',
    desc:     'Interior, exterior, and central angles snap as sides are added.',
    badgeText: 'text-[var(--resultant)]',
    badgeBg:   'bg-[color-mix(in_srgb,var(--resultant)_15%,transparent)]',
    delayClass: 'delay-300',
  },
]

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
          {modes.map((mode) => (
            <Reveal key={mode.n} delayClass={mode.delayClass} className="h-full">
              <div className="h-full rounded-2xl p-6 border border-[var(--border)] bg-[var(--surface)] transition-all duration-500 ease-premium hover:-translate-y-1 hover:border-[var(--primary)] hover:shadow-[0_0_40px_-8px_var(--primary)]">
                <div className="flex items-center gap-3 mb-3">
                  <span
                    className={`w-9 h-9 rounded-full flex items-center justify-center text-sm font-bold font-mono flex-shrink-0 ${mode.badgeBg} ${mode.badgeText}`}
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
          ))}
        </div>

      </div>
    </section>
  )
}

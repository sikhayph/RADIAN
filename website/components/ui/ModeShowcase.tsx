// ─────────────────────────────────────────────────────────────────────────────
// components/ui/ModeShowcase.tsx
// Landing page mode grid — four teaching modes, 2×2
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

const modes = [
  {
    n:      1,
    name:   'Degree / Radian',
    desc:   'Unit circle, arc length, sin / cos — read live off the dial.',
    accent: 'var(--primary)',
  },
  {
    n:      2,
    name:   'Vector Addition',
    desc:   'Two arms combine into a resultant with live magnitude and angle.',
    accent: 'var(--arm1, #F78166)',
  },
  {
    n:      3,
    name:   'Rotation Matrix',
    desc:   'A 2×2 transform applied in real time, with its geometric effect.',
    accent: 'var(--arm2, #7EE787)',
  },
  {
    n:      4,
    name:   'Polygon Snap',
    desc:   'Interior, exterior, and central angles snap as sides are added.',
    accent: 'var(--resultant, #E3B341)',
  },
]

export default function ModeShowcase() {
  return (
    <section className="py-20">
      <div className="max-w-6xl mx-auto px-6">

        {/* Section heading */}
        <div className="text-center mb-12">
          <p
            className="text-sm font-mono tracking-widest mb-3 uppercase"
            style={{ color: 'var(--primary)' }}
          >
            Four Modes, One Dial
          </p>
          <h2
            className="text-3xl lg:text-4xl font-bold"
            style={{ color: 'var(--text)' }}
          >
            What RADIAN teaches
          </h2>
        </div>

        {/* 2×2 grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
          {modes.map((mode) => (
            <div
              key={mode.n}
              className="rounded-2xl p-6 border transition-transform hover:-translate-y-1"
              style={{
                backgroundColor: 'var(--surface)',
                borderColor:     'var(--border)',
              }}
            >
              <div className="flex items-center gap-3 mb-3">
                <span
                  className="w-9 h-9 rounded-full flex items-center justify-center text-sm font-bold font-mono flex-shrink-0"
                  style={{
                    backgroundColor: `${mode.accent}22`,
                    color:           mode.accent,
                  }}
                >
                  {mode.n}
                </span>
                <h3
                  className="text-lg font-semibold"
                  style={{ color: 'var(--text)' }}
                >
                  {mode.name}
                </h3>
              </div>
              <p
                className="text-sm leading-relaxed"
                style={{ color: 'var(--muted)' }}
              >
                {mode.desc}
              </p>
            </div>
          ))}
        </div>

      </div>
    </section>
  )
}

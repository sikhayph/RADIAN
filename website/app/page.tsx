// ─────────────────────────────────────────────────────────────────────────────
// app/page.tsx
// Landing page — scaffold placeholder
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────
// NOTE: This is a scaffold. Full landing page design begins at M4
// once the companion app visualizers pass end-to-end hardware validation.
// ─────────────────────────────────────────────────────────────────────────────

export default function Home() {
  return (
    <main className="min-h-screen flex flex-col items-center justify-center px-6">
      {/* Hero */}
      <div className="text-center max-w-2xl">
        <p className="text-sm tracking-widest mb-4" style={{ color: 'var(--muted)' }}>
          A SIKHAY AND VALIGER COLLABORATION
        </p>
        <h1 className="text-6xl font-bold mb-4" style={{ color: 'var(--text)' }}>
          RADIAN
        </h1>
        <p className="text-lg mb-2 font-mono" style={{ color: 'var(--primary)' }}>
          Rotary · Angular · Display · Intuitive · Angle · Notation
        </p>
        <p className="text-base mb-10" style={{ color: 'var(--muted)' }}>
          An ESP32-powered educational device that teaches abstract mathematics
          through physical rotation.
        </p>

        {/* CTA buttons — placeholder */}
        <div className="flex gap-4 justify-center flex-wrap">
          <button
            className="px-6 py-3 rounded-lg font-semibold transition-opacity hover:opacity-80"
            style={{ backgroundColor: 'var(--primary)', color: 'var(--bg)' }}
          >
            Learn More
          </button>
          <button
            className="px-6 py-3 rounded-lg font-semibold border transition-opacity hover:opacity-80"
            style={{ borderColor: 'var(--border)', color: 'var(--text)' }}
          >
            Try the Demo
          </button>
        </div>
      </div>

      {/* Mode cards — placeholder grid */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mt-20 w-full max-w-3xl">
        {[
          { n: 1, label: 'Degree / Radian',  sub: 'Unit circle, arc length, sin/cos' },
          { n: 2, label: 'Vector Addition',  sub: 'Resultant, magnitude, angle' },
          { n: 3, label: 'Rotation Matrix',  sub: '2×2 transform, geometric effect' },
          { n: 4, label: 'Polygon Snap',     sub: 'Interior, exterior, central angles' },
        ].map((mode) => (
          <div
            key={mode.n}
            className="rounded-xl p-4 border"
            style={{ backgroundColor: 'var(--surface)', borderColor: 'var(--border)' }}
          >
            <p className="text-xs mb-1" style={{ color: 'var(--muted)' }}>
              Mode {mode.n}
            </p>
            <p className="font-semibold text-sm mb-1" style={{ color: 'var(--text)' }}>
              {mode.label}
            </p>
            <p className="text-xs" style={{ color: 'var(--muted)' }}>
              {mode.sub}
            </p>
          </div>
        ))}
      </div>

      {/* Footer */}
      <footer className="mt-20 text-xs text-center" style={{ color: 'var(--muted)' }}>
        © 2026 Sikhay Research, Development and Prototyping and Valiger.
        All rights reserved.
      </footer>
    </main>
  )
}

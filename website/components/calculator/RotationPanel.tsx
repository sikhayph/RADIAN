// ─────────────────────────────────────────────────────────────────────────────
// components/calculator/RotationPanel.tsx
// Mode 3 — rotation matrix. Input vector + angle → rotated vector, with the
// live 2×2 matrix shown.
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

'use client'

import { useMemo, useState } from 'react'
import { rotate, fmt, magnitude, angleDeg, type Vec2 } from '../../lib/calculator/math'
import { CalcLayout, FigureCard, NumberField, Readout } from './controls'
import { VB, CENTER, toScreen, arrowHead } from './svgHelpers'

export default function RotationPanel() {
  const [x, setX] = useState(1)
  const [y, setY] = useState(0.5)
  const [angle, setAngle] = useState(45)

  const input = useMemo<Vec2>(() => ({ x, y }), [x, y])
  const { out, matrix } = useMemo(() => rotate(input, angle), [input, angle])

  const maxMag = Math.max(1e-3, magnitude(input), magnitude(out))
  const scale = 120 / maxMag

  const pIn = toScreen(input.x, input.y, scale)
  const pOut = toScreen(out.x, out.y, scale)
  const origin = { x: CENTER, y: CENTER }

  const m = (n: number) => fmt(n, 4)

  return (
    <CalcLayout
      controls={
        <>
          <div className="grid grid-cols-2 gap-4">
            <NumberField label="Vector x" value={x} onChange={setX} step={0.5} />
            <NumberField label="Vector y" value={y} onChange={setY} step={0.5} />
          </div>
          <NumberField label="Rotation angle θ" value={angle} onChange={setAngle} step={15} suffix="°" />

          {/* Live rotation matrix */}
          <div className="rounded-2xl border border-[var(--border)] bg-[var(--surface)] p-5">
            <p className="mb-3 text-xs uppercase tracking-wide text-[var(--muted)]">
              R(θ) · v
            </p>
            <div className="flex items-center gap-3 font-mono text-sm">
              <span className="text-2xl text-[var(--muted)]">[</span>
              <div className="grid grid-cols-2 gap-x-4 gap-y-1 text-[var(--text)]">
                <span>{m(matrix[0][0])}</span>
                <span>{m(matrix[0][1])}</span>
                <span>{m(matrix[1][0])}</span>
                <span>{m(matrix[1][1])}</span>
              </div>
              <span className="text-2xl text-[var(--muted)]">]</span>
            </div>
            <p className="mt-2 text-xs text-[var(--muted)]">
              [[cos θ, −sin θ], [sin θ, cos θ]]
            </p>
          </div>

          <Readout
            items={[
              { label: "Rotated x'", value: fmt(out.x, 3), accent: true },
              { label: "Rotated y'", value: fmt(out.y, 3), accent: true },
              { label: 'Magnitude', value: fmt(magnitude(out), 3) },
              { label: 'Angle', value: `${fmt(angleDeg(out), 2)}°` },
            ]}
          />
        </>
      }
      figure={
        <FigureCard caption={`rotated by ${fmt(angle, 1)}°`}>
          <svg viewBox={`0 0 ${VB} ${VB}`} className="w-full" role="img" aria-label="Rotation matrix diagram">
            <line x1={CENTER - 145} y1={CENTER} x2={CENTER + 145} y2={CENTER} stroke="var(--border)" strokeWidth={1} />
            <line x1={CENTER} y1={CENTER - 145} x2={CENTER} y2={CENTER + 145} stroke="var(--border)" strokeWidth={1} />
            {/* original (faded) */}
            <line x1={CENTER} y1={CENTER} x2={pIn.x} y2={pIn.y} stroke="var(--muted)" strokeWidth={2.5} strokeLinecap="round" opacity={0.55} />
            <polygon points={arrowHead(origin, pIn)} fill="var(--muted)" opacity={0.55} />
            <text x={pIn.x} y={pIn.y - 10} fill="var(--muted)" fontSize={11} textAnchor="middle">v</text>
            {/* rotated */}
            <line x1={CENTER} y1={CENTER} x2={pOut.x} y2={pOut.y} stroke="var(--arm2)" strokeWidth={3} strokeLinecap="round" />
            <polygon points={arrowHead(origin, pOut)} fill="var(--arm2)" />
            <text x={pOut.x} y={pOut.y - 10} fill="var(--arm2)" fontSize={11} fontWeight={700} textAnchor="middle">v′</text>
            <circle cx={CENTER} cy={CENTER} r={3} fill="var(--text)" opacity={0.6} />
          </svg>
        </FigureCard>
      }
    />
  )
}

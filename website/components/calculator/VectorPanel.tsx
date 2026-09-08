// ─────────────────────────────────────────────────────────────────────────────
// components/calculator/VectorPanel.tsx
// Mode 2 — vector addition. Two input vectors, live resultant + magnitude.
// Figure language ported from components/canvas/VectorDiagram.tsx (canvas → SVG).
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

'use client'

import { useMemo, useState } from 'react'
import { addVectors, fromPolar, fmt, type Vec2 } from '../../lib/calculator/math'
import { CalcLayout, FigureCard, NumberField, Readout } from './controls'
import { VB, CENTER, toScreen, points, arrowHead, type ScreenPoint } from './svgHelpers'

function Arrow({
  to,
  color,
  label,
}: {
  to: ScreenPoint
  color: string
  label: string
}) {
  const origin = { x: CENTER, y: CENTER }
  return (
    <g>
      <line x1={CENTER} y1={CENTER} x2={to.x} y2={to.y} stroke={color} strokeWidth={3} strokeLinecap="round" />
      <polygon points={arrowHead(origin, to)} fill={color} />
      <text x={to.x} y={to.y - 10} fill={color} fontSize={11} fontWeight={700} textAnchor="middle">
        {label}
      </text>
    </g>
  )
}

export default function VectorPanel() {
  const [m1, setM1] = useState(1)
  const [a1, setA1] = useState(30)
  const [m2, setM2] = useState(1)
  const [a2, setA2] = useState(110)

  const v1 = useMemo<Vec2>(() => fromPolar(m1, a1), [m1, a1])
  const v2 = useMemo<Vec2>(() => fromPolar(m2, a2), [m2, a2])
  const sum = useMemo(() => addVectors(v1, v2), [v1, v2])

  // Scale so the largest of the three vectors fits with margin.
  const maxMag = Math.max(1e-3, m1, m2, sum.magnitude)
  const scale = 130 / maxMag

  const p1 = toScreen(v1.x, v1.y, scale)
  const p2 = toScreen(v2.x, v2.y, scale)
  const pr = toScreen(sum.resultant.x, sum.resultant.y, scale)

  return (
    <CalcLayout
      controls={
        <>
          <div className="grid grid-cols-2 gap-4">
            <NumberField label="Vector 1 · magnitude" value={m1} onChange={setM1} step={0.5} min={0} />
            <NumberField label="Vector 1 · angle" value={a1} onChange={setA1} step={15} suffix="°" />
            <NumberField label="Vector 2 · magnitude" value={m2} onChange={setM2} step={0.5} min={0} />
            <NumberField label="Vector 2 · angle" value={a2} onChange={setA2} step={15} suffix="°" />
          </div>
          <Readout
            items={[
              { label: 'Resultant x', value: fmt(sum.resultant.x, 3) },
              { label: 'Resultant y', value: fmt(sum.resultant.y, 3) },
              { label: 'Magnitude', value: fmt(sum.magnitude, 3), accent: true },
              { label: 'Angle', value: `${fmt(sum.angleDeg, 2)}°`, accent: true },
            ]}
          />
        </>
      }
      figure={
        <FigureCard caption="Arm 1 + Arm 2 → resultant (parallelogram)">
          <svg viewBox={`0 0 ${VB} ${VB}`} className="w-full" role="img" aria-label="Vector addition diagram">
            <line x1={CENTER - 150} y1={CENTER} x2={CENTER + 150} y2={CENTER} stroke="var(--border)" strokeWidth={1} />
            <line x1={CENTER} y1={CENTER - 150} x2={CENTER} y2={CENTER + 150} stroke="var(--border)" strokeWidth={1} />
            {/* parallelogram construction */}
            <polyline
              points={points([p1, pr, p2])}
              fill="none"
              stroke="var(--resultant)"
              strokeWidth={1}
              strokeDasharray="4 4"
              opacity={0.5}
            />
            <Arrow to={p1} color="var(--arm1)" label="A₁" />
            <Arrow to={p2} color="var(--arm2)" label="A₂" />
            <Arrow to={pr} color="var(--resultant)" label="R" />
            <circle cx={CENTER} cy={CENTER} r={3} fill="var(--text)" opacity={0.6} />
          </svg>
        </FigureCard>
      }
    />
  )
}

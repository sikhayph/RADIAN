// ─────────────────────────────────────────────────────────────────────────────
// components/calculator/PolygonPanel.tsx
// Mode 4 — polygon angles. Side count → interior / exterior / sum / central,
// with a regular n-gon preview and one interior angle highlighted.
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

'use client'

import { useMemo, useState } from 'react'
import { polygonAngles, polygonVertices, fmt } from '../../lib/calculator/math'
import { CalcLayout, FigureCard, RangeField, Readout } from './controls'
import { VB, CENTER, points, type ScreenPoint } from './svgHelpers'

const MIN_SIDES = 3
const MAX_SIDES = 20

export default function PolygonPanel() {
  const [sides, setSides] = useState(6)

  const a = useMemo(() => polygonAngles(sides), [sides])

  const verts: ScreenPoint[] = useMemo(
    () =>
      polygonVertices(sides, 120, CENTER, CENTER).map((v) => ({ x: v.x, y: v.y })),
    [sides],
  )

  // Highlight the interior angle at vertex 0 with a small wedge.
  const wedge = useMemo(() => {
    const n = verts.length
    const v0 = verts[0]
    const prev = verts[(n - 1) % n]
    const next = verts[1 % n]
    const armTo = (p: ScreenPoint, t: number): ScreenPoint => ({
      x: v0.x + (p.x - v0.x) * t,
      y: v0.y + (p.y - v0.y) * t,
    })
    return { v0, p1: armTo(prev, 0.22), p2: armTo(next, 0.22) }
  }, [verts])

  return (
    <CalcLayout
      controls={
        <>
          <RangeField
            label="Number of sides"
            value={sides}
            onChange={(n) => setSides(Math.min(MAX_SIDES, Math.max(MIN_SIDES, n)))}
            min={MIN_SIDES}
            max={MAX_SIDES}
          />
          <Readout
            items={[
              { label: 'Interior angle', value: `${fmt(a.interior, 2)}°`, accent: true },
              { label: 'Exterior angle', value: `${fmt(a.exterior, 2)}°`, accent: true },
              { label: 'Interior sum', value: `${fmt(a.interiorSum, 0)}°` },
              { label: 'Central angle', value: `${fmt(a.central, 2)}°` },
            ]}
          />
          <p className="text-xs leading-relaxed text-[var(--muted)]">
            Regular {a.sides}-gon: interior = (n−2)·180 / n, exterior = 360 / n, and the
            interior angles sum to (n−2)·180.
          </p>
        </>
      }
      figure={
        <FigureCard caption={`regular ${a.sides}-gon`}>
          <svg viewBox={`0 0 ${VB} ${VB}`} className="w-full" role="img" aria-label={`Regular polygon with ${a.sides} sides`}>
            <polygon
              points={points(verts)}
              fill="color-mix(in srgb, var(--resultant) 8%, transparent)"
              stroke="var(--resultant)"
              strokeWidth={2}
              strokeLinejoin="round"
            />
            {/* highlighted interior angle wedge at vertex 0 */}
            <polyline
              points={points([wedge.p1, wedge.v0, wedge.p2])}
              fill="none"
              stroke="var(--primary)"
              strokeWidth={2}
            />
            {verts.map((v, i) => (
              <circle key={i} cx={v.x} cy={v.y} r={2.5} fill="var(--resultant)" />
            ))}
            <circle cx={wedge.v0.x} cy={wedge.v0.y} r={4} fill="var(--primary)" />
          </svg>
        </FigureCard>
      }
    />
  )
}

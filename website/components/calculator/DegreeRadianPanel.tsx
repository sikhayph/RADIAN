// ─────────────────────────────────────────────────────────────────────────────
// components/calculator/DegreeRadianPanel.tsx
// Mode 1 — degree ⇄ radian conversion with a live unit-circle figure.
// Visual language ported from Hero.tsx's UnitCirclePreview (canvas → SVG).
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

'use client'

import { useMemo, useState } from 'react'
import {
  degToRad,
  radToDeg,
  normalizeDeg,
  toPiFraction,
  fmt,
} from '../../lib/calculator/math'
import { CalcLayout, FigureCard, NumberField, Readout, Segmented } from './controls'
import { VB, CENTER, toScreen, arcPath } from './svgHelpers'

type Dir = 'deg2rad' | 'rad2deg'

export default function DegreeRadianPanel() {
  const [dir, setDir] = useState<Dir>('deg2rad')
  const [input, setInput] = useState(45)

  const deg = dir === 'deg2rad' ? input : radToDeg(input)
  const rad = dir === 'deg2rad' ? degToRad(input) : input

  const theta = normalizeDeg(deg)
  const r = 120
  const tip = toScreen(r * Math.cos(degToRad(theta)), r * Math.sin(degToRad(theta)))
  const foot = toScreen(r * Math.cos(degToRad(theta)), 0)

  const trig = useMemo(
    () => ({
      sin: Math.sin(degToRad(deg)),
      cos: Math.cos(degToRad(deg)),
      tan: Math.cos(degToRad(deg)) === 0 ? NaN : Math.tan(degToRad(deg)),
    }),
    [deg],
  )

  return (
    <CalcLayout
      controls={
        <>
          <Segmented<Dir>
            label="Direction"
            value={dir}
            onChange={setDir}
            options={[
              { value: 'deg2rad', label: 'Degrees → Radians' },
              { value: 'rad2deg', label: 'Radians → Degrees' },
            ]}
          />
          <NumberField
            label={dir === 'deg2rad' ? 'Angle in degrees' : 'Angle in radians'}
            value={input}
            onChange={setInput}
            step={dir === 'deg2rad' ? 15 : 0.1}
            suffix={dir === 'deg2rad' ? '°' : 'rad'}
          />
          <Readout
            items={[
              {
                label: dir === 'deg2rad' ? 'Radians' : 'Degrees',
                value: dir === 'deg2rad' ? `${fmt(rad, 4)}` : `${fmt(deg, 3)}°`,
                accent: true,
              },
              { label: 'Exact', value: toPiFraction(deg) },
              { label: 'sin θ', value: fmt(trig.sin, 4) },
              { label: 'cos θ', value: fmt(trig.cos, 4) },
              {
                label: 'tan θ',
                value: Number.isNaN(trig.tan) ? 'undefined' : fmt(trig.tan, 4),
              },
              { label: 'Reference', value: `${fmt(theta, 2)}°` },
            ]}
          />
        </>
      }
      figure={
        <FigureCard caption={`${fmt(theta, 1)}°  ·  ${fmt(degToRad(theta), 4)} rad`}>
          <svg viewBox={`0 0 ${VB} ${VB}`} className="w-full" role="img" aria-label={`Unit circle showing ${fmt(theta, 1)} degrees`}>
            {/* spokes every 30° */}
            {Array.from({ length: 6 }).map((_, i) => {
              const a = degToRad(i * 30)
              const p1 = toScreen(r * Math.cos(a), r * Math.sin(a))
              const p2 = toScreen(-r * Math.cos(a), -r * Math.sin(a))
              return (
                <line
                  key={i}
                  x1={p1.x}
                  y1={p1.y}
                  x2={p2.x}
                  y2={p2.y}
                  stroke="var(--border)"
                  strokeWidth={1}
                  opacity={0.4}
                />
              )
            })}
            {/* axes */}
            <line x1={CENTER - r - 14} y1={CENTER} x2={CENTER + r + 14} y2={CENTER} stroke="var(--border)" strokeWidth={1} />
            <line x1={CENTER} y1={CENTER - r - 14} x2={CENTER} y2={CENTER + r + 14} stroke="var(--border)" strokeWidth={1} />
            {/* unit circle */}
            <circle cx={CENTER} cy={CENTER} r={r} fill="none" stroke="var(--muted)" strokeWidth={1.5} opacity={0.5} />
            {/* swept arc */}
            <path
              d={`M ${CENTER + 34} ${CENTER} A 34 34 0 ${theta % 360 > 180 ? 1 : 0} 0 ${
                toScreen(34 * Math.cos(degToRad(theta)), 34 * Math.sin(degToRad(theta))).x
              } ${toScreen(34 * Math.cos(degToRad(theta)), 34 * Math.sin(degToRad(theta))).y}`}
              fill="none"
              stroke="var(--arm1)"
              strokeWidth={2}
            />
            {/* projections */}
            <line x1={tip.x} y1={tip.y} x2={tip.x} y2={CENTER} stroke="var(--arm1)" strokeWidth={1} strokeDasharray="4 4" opacity={0.5} />
            <line x1={tip.x} y1={tip.y} x2={CENTER} y2={tip.y} stroke="var(--arm1)" strokeWidth={1} strokeDasharray="4 4" opacity={0.5} />
            {/* arm */}
            <line x1={CENTER} y1={CENTER} x2={tip.x} y2={tip.y} stroke="var(--arm1)" strokeWidth={3} strokeLinecap="round" />
            <circle cx={tip.x} cy={tip.y} r={5} fill="var(--arm1)" />
            <circle cx={CENTER} cy={CENTER} r={3} fill="var(--text)" opacity={0.6} />
            <circle cx={foot.x} cy={foot.y} r={2.5} fill="var(--arm1)" opacity={0.7} />
          </svg>
        </FigureCard>
      }
    />
  )
}

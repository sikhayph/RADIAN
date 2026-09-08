// ─────────────────────────────────────────────────────────────────────────────
// components/calculator/svgHelpers.ts
// Small geometry helpers for the calculator SVG previews. All previews share a
// square viewBox with the origin at the center and math-convention axes
// (+x right, +y up) — SVG's +y-down is handled here so panels stay readable.
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

/** Shared viewBox size for every calculator figure. */
export const VB = 320
export const CENTER = VB / 2

export interface ScreenPoint {
  x: number
  y: number
}

/** Math point (origin-centered, +y up) → SVG point (top-left origin, +y down). */
export function toScreen(x: number, y: number, scale = 1): ScreenPoint {
  return { x: CENTER + x * scale, y: CENTER - y * scale }
}

/** SVG arc path from angle `a0` to `a1` (degrees, CCW+) at radius `r`. */
export function arcPath(r: number, a0Deg: number, a1Deg: number): string {
  const a0 = (a0Deg * Math.PI) / 180
  const a1 = (a1Deg * Math.PI) / 180
  const p0 = toScreen(r * Math.cos(a0), r * Math.sin(a0))
  const p1 = toScreen(r * Math.cos(a1), r * Math.sin(a1))
  const large = Math.abs(a1Deg - a0Deg) % 360 > 180 ? 1 : 0
  // sweep-flag 0 because SVG y is flipped relative to math orientation
  return `M ${p0.x} ${p0.y} A ${r} ${r} 0 ${large} 0 ${p1.x} ${p1.y}`
}

/** Points string for an SVG <polygon>/<polyline> from screen points. */
export function points(pts: ScreenPoint[]): string {
  return pts.map((p) => `${p.x},${p.y}`).join(' ')
}

/** A short arrowhead polygon at the tip of a vector from `from` to `to`. */
export function arrowHead(
  from: ScreenPoint,
  to: ScreenPoint,
  size = 9,
): string {
  const dx = to.x - from.x
  const dy = to.y - from.y
  const len = Math.hypot(dx, dy) || 1
  const ux = dx / len
  const uy = dy / len
  const nx = -uy
  const ny = ux
  const baseX = to.x - ux * size
  const baseY = to.y - uy * size
  const w = size * 0.6
  return points([
    to,
    { x: baseX + nx * w, y: baseY + ny * w },
    { x: baseX - nx * w, y: baseY - ny * w },
  ])
}

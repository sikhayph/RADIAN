// ─────────────────────────────────────────────────────────────────────────────
// lib/calculator/math.ts
// Pure math for the /calculator tabs. No dependencies, no side effects — every
// function takes numbers and returns numbers/objects so it can be unit-tested
// and reused by the SVG previews.
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

export const TAU = Math.PI * 2

// ── Angle conversion ─────────────────────────────────────────────────────────

export function degToRad(deg: number): number {
  return (deg * Math.PI) / 180
}

export function radToDeg(rad: number): number {
  return (rad * 180) / Math.PI
}

/** Wrap an angle in degrees to [0, 360). */
export function normalizeDeg(deg: number): number {
  return ((deg % 360) + 360) % 360
}

const GREEK_PI = 'π'

/**
 * Express `deg` degrees as an exact multiple of π radians when it lands on a
 * "nice" denominator (2..12), otherwise fall back to a decimal.
 * 90 → "π/2", 180 → "π", 270 → "3π/2", 45 → "π/4", 123 → "0.6833π".
 */
export function toPiFraction(deg: number): string {
  const ratio = deg / 180 // multiples of π
  if (ratio === 0) return '0'

  const sign = ratio < 0 ? '-' : ''
  const abs = Math.abs(ratio)

  for (let denom = 1; denom <= 12; denom++) {
    const num = abs * denom
    if (Math.abs(num - Math.round(num)) < 1e-9) {
      const n = Math.round(num)
      const numPart = n === 1 ? GREEK_PI : `${n}${GREEK_PI}`
      return denom === 1 ? `${sign}${numPart}` : `${sign}${numPart}/${denom}`
    }
  }
  return `${(ratio).toFixed(4)}${GREEK_PI}`
}

// ── Vectors ──────────────────────────────────────────────────────────────────

export interface Vec2 {
  x: number
  y: number
}

export function fromPolar(magnitude: number, angleDeg: number): Vec2 {
  const r = degToRad(angleDeg)
  return { x: magnitude * Math.cos(r), y: magnitude * Math.sin(r) }
}

export function magnitude(v: Vec2): number {
  return Math.hypot(v.x, v.y)
}

/** Angle of a vector in degrees, [0, 360). Returns 0 for the zero vector. */
export function angleDeg(v: Vec2): number {
  if (v.x === 0 && v.y === 0) return 0
  return normalizeDeg(radToDeg(Math.atan2(v.y, v.x)))
}

export interface VectorSum {
  resultant: Vec2
  magnitude: number
  angleDeg: number
}

export function addVectors(a: Vec2, b: Vec2): VectorSum {
  const resultant = { x: a.x + b.x, y: a.y + b.y }
  return {
    resultant,
    magnitude: magnitude(resultant),
    angleDeg: angleDeg(resultant),
  }
}

// ── Rotation ─────────────────────────────────────────────────────────────────

export interface Rotation {
  /** Rotated vector. */
  out: Vec2
  /** The 2×2 rotation matrix, row-major: [[a, b], [c, d]]. */
  matrix: [[number, number], [number, number]]
}

export function rotate(v: Vec2, angleDeg: number): Rotation {
  const t = degToRad(angleDeg)
  const cos = Math.cos(t)
  const sin = Math.sin(t)
  return {
    out: {
      x: v.x * cos - v.y * sin,
      y: v.x * sin + v.y * cos,
    },
    matrix: [
      [cos, -sin],
      [sin, cos],
    ],
  }
}

// ── Polygons ─────────────────────────────────────────────────────────────────

export interface PolygonAngles {
  sides: number
  /** One interior angle of a regular n-gon, degrees. */
  interior: number
  /** One exterior angle, degrees. */
  exterior: number
  /** Sum of all interior angles, degrees. */
  interiorSum: number
  /** Central angle subtended by one side, degrees. */
  central: number
}

export function polygonAngles(sides: number): PolygonAngles {
  const n = Math.max(3, Math.round(sides))
  return {
    sides: n,
    interior: ((n - 2) * 180) / n,
    exterior: 360 / n,
    interiorSum: (n - 2) * 180,
    central: 360 / n,
  }
}

/**
 * Vertices of a regular n-gon inscribed in a circle of radius `r` centered at
 * (cx, cy), first vertex at the top. Uses screen coordinates (+y down).
 */
export function polygonVertices(
  sides: number,
  r: number,
  cx = 0,
  cy = 0,
): Vec2[] {
  const n = Math.max(3, Math.round(sides))
  const verts: Vec2[] = []
  for (let i = 0; i < n; i++) {
    const a = -Math.PI / 2 + (i * TAU) / n
    verts.push({ x: cx + r * Math.cos(a), y: cy + r * Math.sin(a) })
  }
  return verts
}

// ── Formatting ───────────────────────────────────────────────────────────────

/** Trim a float to at most `dp` decimals, dropping trailing zeros. */
export function fmt(n: number, dp = 3): string {
  if (!Number.isFinite(n)) return '—'
  const rounded = Number(n.toFixed(dp))
  return String(rounded)
}

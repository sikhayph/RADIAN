// ─────────────────────────────────────────────────────────────────────────────
// lib/specs.ts
// Single source of truth for every RADIAN hardware / product number and for the
// four teaching-mode descriptions. Replaces figures that were previously typed
// straight into JSX (Hero stats, ModeShowcase / DemoClient mode lists).
//
// Canonical values are taken from the repo docs:
//   • docs/ble_contract.md    — notify interval, payload size
//   • docs/architecture.md    — 20 Hz loop, end-to-end latency
//   • docs/hardware_pinout.md — AS5600 encoder (12-bit)
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

// ── Raw specs ────────────────────────────────────────────────────────────────

export const specs = {
  /** Number of teaching modes on the dial. */
  teachingModes: 4,

  /** BLE notify rate, in Hz (≈ 50 ms interval). Source: ble_contract.md. */
  bleUpdateRateHz: 20,

  /** BLE notify interval, milliseconds. */
  bleIntervalMs: 50,

  /**
   * Practical angular resolution, degrees. The AS5600 is a 12-bit magnetic
   * encoder: 4096 steps / 360° ≈ 0.088°, rounded to 0.1° for display.
   * Source: hardware_pinout.md.
   */
  encoderAccuracyDeg: 0.1,

  /** Magnetic rotary encoder part (one per arm). Source: hardware_pinout.md. */
  encoderModel: 'AS5600',

  /** Microcontroller. Source: architecture.md. */
  mcu: 'ESP32',

  /** Maximum BLE payload size, bytes (JSON string, UTF-8). Source: ble_contract.md. */
  blePayloadMaxBytes: 100,

  /** Encoder read → canvas redraw, typical. Source: architecture.md §latency. */
  endToEndLatency: '50–80 ms',

  /** Number of physical arms / encoders. */
  arms: 2,
} as const

export type Specs = typeof specs

// ── Derived display strings ──────────────────────────────────────────────────

/** Pre-formatted spec strings for UI that wants a ready-to-render value. */
export const specDisplay = {
  teachingModes: String(specs.teachingModes),
  bleUpdateRate: `${specs.bleUpdateRateHz}Hz`,
  encoderAccuracy: `${specs.encoderAccuracyDeg}°`,
  blePayload: `${specs.blePayloadMaxBytes} bytes`,
  endToEndLatency: specs.endToEndLatency,
} as const

// ── Homepage hero stats ──────────────────────────────────────────────────────
// Consumed by components/ui/Hero.tsx — shape matches its .map() exactly.

export interface HomepageStat {
  value: string
  label: string
}

export const homepageStats: HomepageStat[] = [
  { value: specDisplay.teachingModes, label: 'Teaching modes' },
  { value: specDisplay.bleUpdateRate, label: 'BLE update rate' },
  { value: specDisplay.encoderAccuracy, label: 'Encoder accuracy' },
]

// ── Teaching modes ───────────────────────────────────────────────────────────
// Text/number data only. Per-file Tailwind color-class maps stay in the
// components (Tailwind can't see values pulled from here at build time).

export interface TeachingMode {
  /** Dial position, 1–4. */
  n: 1 | 2 | 3 | 4
  /** Canonical mode name. */
  name: string
  /** One-line description used on cards and tab panels. */
  desc: string
  /** Accent token key — maps to --primary / --arm1 / --arm2 / --resultant. */
  accent: 'primary' | 'arm1' | 'arm2' | 'resultant'
}

export const modes: TeachingMode[] = [
  {
    n: 1,
    name: 'Degree / Radian',
    desc: 'Unit circle, arc length, sin / cos — read live off the dial.',
    accent: 'primary',
  },
  {
    n: 2,
    name: 'Vector Addition',
    desc: 'Two arms combine into a resultant with live magnitude and angle.',
    accent: 'arm1',
  },
  {
    n: 3,
    name: 'Rotation Matrix',
    desc: 'A 2×2 transform applied in real time, with its geometric effect.',
    accent: 'arm2',
  },
  {
    n: 4,
    name: 'Polygon Snap',
    desc: 'Interior, exterior, and central angles snap as sides are added.',
    accent: 'resultant',
  },
]

/** Look up a single mode by dial position. */
export function getMode(n: TeachingMode['n']): TeachingMode {
  return modes[n - 1]
}

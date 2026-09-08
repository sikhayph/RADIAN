// ─────────────────────────────────────────────────────────────────────────────
// components/ui/modeAccent.ts
// Maps a teaching mode's accent token (from lib/specs.ts) to the literal
// Tailwind class strings used across the mode cards, demo tabs, and calculator
// tabs. These strings must live under app/ or components/ so Tailwind's content
// scanner keeps them in the build — lib/ is not scanned.
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import type { TeachingMode } from '../../lib/specs'

export interface ModeAccentClasses {
  /** Text color, e.g. for the numbered badge and active tab label. */
  text: string
  /** Translucent background fill for the numbered badge. */
  bg: string
  /** Solid CSS var reference, for inline SVG stroke/fill. */
  cssVar: string
}

const MAP: Record<TeachingMode['accent'], ModeAccentClasses> = {
  primary: {
    text: 'text-[var(--primary)]',
    bg: 'bg-[color-mix(in_srgb,var(--primary)_15%,transparent)]',
    cssVar: 'var(--primary)',
  },
  arm1: {
    text: 'text-[var(--arm1)]',
    bg: 'bg-[color-mix(in_srgb,var(--arm1)_15%,transparent)]',
    cssVar: 'var(--arm1)',
  },
  arm2: {
    text: 'text-[var(--arm2)]',
    bg: 'bg-[color-mix(in_srgb,var(--arm2)_15%,transparent)]',
    cssVar: 'var(--arm2)',
  },
  resultant: {
    text: 'text-[var(--resultant)]',
    bg: 'bg-[color-mix(in_srgb,var(--resultant)_15%,transparent)]',
    cssVar: 'var(--resultant)',
  },
}

export function modeAccent(accent: TeachingMode['accent']): ModeAccentClasses {
  return MAP[accent]
}

/** Staggered Reveal delay class, keyed by dial position 1–4. */
export const MODE_DELAY: Record<number, string> = {
  1: 'delay-0',
  2: 'delay-100',
  3: 'delay-200',
  4: 'delay-300',
}

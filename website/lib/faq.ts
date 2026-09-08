// ─────────────────────────────────────────────────────────────────────────────
// lib/faq.ts
// Single source of truth for FAQ content. Rendered by components/ui/Faq.tsx.
// Keep answers short, factual, and consistent with the docs and About page.
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import { specs } from './specs'

export type FaqCategory = 'Product' | 'Hardware' | 'Classroom' | 'Project'

export interface FaqItem {
  q: string
  a: string
  category: FaqCategory
}

export const faq: FaqItem[] = [
  {
    category: 'Product',
    q: 'What is RADIAN?',
    a: `RADIAN is a classroom device that teaches trigonometry, vectors, matrices, and polygon angles through physical rotation. A rotary dial with ${specs.arms} arms feeds live readings to a companion app, so abstract math becomes something students can turn with their hands and watch update in real time.`,
  },
  {
    category: 'Project',
    q: 'How is it related to ANGGULO?',
    a: 'RADIAN started as ANGGULO, a physical-rotation device built for the Regional Mathematics Fair 2025, where it placed second. The core hardware concept stayed; the scope expanded to firmware, a companion app, and this website, and the project was renamed RADIAN.',
  },
  {
    category: 'Product',
    q: 'What does it teach?',
    a: `Four modes on one dial: degree / radian conversion on the unit circle, vector addition with a live resultant, 2×2 rotation matrices, and polygon interior / exterior angles. You can try the math for all four in the browser on the Calculator page.`,
  },
  {
    category: 'Hardware',
    q: 'What hardware does it use?',
    a: `An ${specs.mcu} microcontroller reads two ${specs.encoderModel} magnetic rotary encoders (one per arm) and broadcasts angle data over Bluetooth Low Energy at ${specs.bleUpdateRateHz} Hz.`,
  },
  {
    category: 'Hardware',
    q: 'How accurate is it?',
    a: `Each arm uses a 12-bit magnetic encoder, giving roughly ${specs.encoderAccuracyDeg}° of angular resolution. End to end — encoder read to an updated drawing on the app — is about ${specs.endToEndLatency}, which feels instantaneous in class.`,
  },
  {
    category: 'Hardware',
    q: 'Does it need internet or an account?',
    a: 'No. The device talks directly to the companion app over Bluetooth Low Energy. There is no account, no cloud sync, and no internet requirement for the core teaching experience.',
  },
  {
    category: 'Classroom',
    q: 'When can I get one?',
    a: 'The v1 hardware release is in progress. Join the waitlist on the homepage and we will email you when units are available.',
  },
  {
    category: 'Classroom',
    q: 'How much will it cost?',
    a: 'Classroom pricing has not been finalized. Waitlist members will be the first to hear pricing and availability for schools.',
  },
  {
    category: 'Project',
    q: 'Is RADIAN open source?',
    a: 'The firmware, companion app, and this website are developed in the open on GitHub at github.com/sikhayph/RADIAN. Hardware suggestions and educational feedback are welcome there.',
  },
]

// ── Helpers ──────────────────────────────────────────────────────────────────

/** All categories present in the FAQ, in first-seen order. */
export function getFaqCategories(): FaqCategory[] {
  const seen: FaqCategory[] = []
  for (const item of faq) if (!seen.includes(item.category)) seen.push(item.category)
  return seen
}

/** FAQ items for one category. */
export function getFaqByCategory(category: FaqCategory): FaqItem[] {
  return faq.filter((item) => item.category === category)
}

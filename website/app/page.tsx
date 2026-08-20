import type { Metadata } from 'next'
import Hero from '../components/ui/Hero'
import ModeShowcase from '../components/ui/ModeShowcase'

export const metadata: Metadata = {
  title: 'RADIAN — Rotary Angular Display with Intuitive Angle Notation',
  description:
    'An ESP32-powered educational device that teaches abstract mathematics through physical rotation. Explore four interactive teaching modes — live in the browser.',
  openGraph: {
    title: 'RADIAN — Rotary Angular Display with Intuitive Angle Notation',
    description:
      'An ESP32-powered educational device that teaches abstract mathematics through physical rotation.',
    type: 'website',
  },
}

export default function Home() {
  return (
    <main>
      <Hero />
      <ModeShowcase />
    </main>
  )
}

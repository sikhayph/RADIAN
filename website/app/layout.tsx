import type { Metadata } from 'next'
import { Analytics } from '@vercel/analytics/next'
import './globals.css'
import Navbar from '../components/ui/Navbar'
import Footer from '../components/ui/Footer'
import { SITE_URL } from '../lib/site'

// metadataBase resolves relative OG image URLs. It reads from lib/site.ts, which
// prefers NEXT_PUBLIC_SITE_URL and falls back to the live Vercel URL.
export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title:        'RADIAN — Rotary Angular Display with Intuitive Angle Notation',
  description:  'An ESP32-powered educational device that teaches abstract mathematics through physical rotation. A Sikhay and Valiger collaboration.',
  openGraph: {
    title:       'RADIAN — Rotary Angular Display with Intuitive Angle Notation',
    description: 'An ESP32-powered educational device that teaches abstract mathematics through physical rotation. A Sikhay and Valiger collaboration.',
    type:        'website',
    siteName:    'RADIAN',
    locale:      'en_US',
  },
  twitter: {
    card:        'summary_large_image',
    title:       'RADIAN — Rotary Angular Display with Intuitive Angle Notation',
    description: 'An ESP32-powered educational device that teaches abstract mathematics through physical rotation. A Sikhay and Valiger collaboration.',
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>
        <Navbar />
        {children}
        <Footer />
        <Analytics />
      </body>
    </html>
  )
}
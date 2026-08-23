import type { Metadata } from 'next'
import './globals.css'
import Navbar from '../components/ui/Navbar'
import Footer from '../components/ui/Footer'

// metadataBase tells Next.js how to resolve relative OG image URLs at build
// time. Replace 'https://radian.app' with the real production domain once it
// is confirmed — or set NEXT_PUBLIC_SITE_URL in your environment and read it
// here via `new URL(process.env.NEXT_PUBLIC_SITE_URL!)`.
export const metadata: Metadata = {
  metadataBase: new URL('https://radian.app'),
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
      </body>
    </html>
  )
}
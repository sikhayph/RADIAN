// ─────────────────────────────────────────────────────────────────────────────
// components/ui/Reveal.tsx
// Scroll-triggered entrance animation — fades and slides content up as it
// enters the viewport via IntersectionObserver. Fires once, on first entry.
// ─────────────────────────────────────────────────────────────────────────────

'use client'

import { useEffect, useRef, useState, type ReactNode } from 'react'

interface RevealProps {
  children: ReactNode
  className?: string
  /** Tailwind delay-* utility class, e.g. "delay-150", for staggered groups */
  delayClass?: string
}

export default function Reveal({ children, className = '', delayClass = '' }: RevealProps) {
  const ref = useRef<HTMLDivElement>(null)
  const [visible, setVisible] = useState(false)

  useEffect(() => {
    const node = ref.current
    if (!node) return

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            setVisible(true)
            observer.unobserve(entry.target)
          }
        })
      },
      { threshold: 0.15, rootMargin: '0px 0px -10% 0px' }
    )

    observer.observe(node)
    return () => observer.disconnect()
  }, [])

  return (
    <div
      ref={ref}
      className={`transition-all duration-700 ease-premium ${delayClass} ${
        visible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'
      } ${className}`}
    >
      {children}
    </div>
  )
}

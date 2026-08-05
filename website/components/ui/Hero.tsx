// ─────────────────────────────────────────────────────────────────────────────
// components/ui/Hero.tsx
// Landing page hero — headline, subtext, CTA buttons, animated canvas preview
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

'use client'

import { useRef, useEffect, useState } from 'react'
import Link from 'next/link'

// ── Animated unit circle preview ──────────────────────────────────────────────

function UnitCirclePreview() {
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const angleRef  = useRef(0)
  const rafRef    = useRef<number>(0)

  useEffect(() => {
    const canvas = canvasRef.current
    if (!canvas) return
    const ctx = canvas.getContext('2d')
    if (!ctx) return

    const W = canvas.width
    const H = canvas.height
    const cx = W / 2
    const cy = H / 2
    const r  = Math.min(cx, cy) * 0.72

    function draw() {
      ctx!.clearRect(0, 0, W, H)

      const theta = angleRef.current
      const rad   = (theta * Math.PI) / 180

      // Grid lines at 30°
      ctx!.strokeStyle = 'rgba(255,255,255,0.05)'
      ctx!.lineWidth   = 1
      for (let i = 0; i < 6; i++) {
        const a = (i * 30 * Math.PI) / 180
        ctx!.beginPath()
        ctx!.moveTo(cx + r * Math.cos(a), cy - r * Math.sin(a))
        ctx!.lineTo(cx - r * Math.cos(a), cy + r * Math.sin(a))
        ctx!.stroke()
      }

      // Axes
      ctx!.strokeStyle = 'rgba(255,255,255,0.12)'
      ctx!.lineWidth   = 1
      ctx!.beginPath(); ctx!.moveTo(cx - r - 12, cy); ctx!.lineTo(cx + r + 12, cy); ctx!.stroke()
      ctx!.beginPath(); ctx!.moveTo(cx, cy - r - 12); ctx!.lineTo(cx, cy + r + 12); ctx!.stroke()

      // Unit circle
      ctx!.strokeStyle = 'rgba(255,255,255,0.2)'
      ctx!.lineWidth   = 1.5
      ctx!.beginPath()
      ctx!.arc(cx, cy, r, 0, Math.PI * 2)
      ctx!.stroke()

      // Swept arc fill
      ctx!.fillStyle = 'rgba(247,129,102,0.12)'
      ctx!.beginPath()
      ctx!.moveTo(cx, cy)
      ctx!.arc(cx, cy, r, 0, -rad, true)
      ctx!.closePath()
      ctx!.fill()

      // Swept arc border
      ctx!.strokeStyle = 'rgba(247,129,102,0.5)'
      ctx!.lineWidth   = 1.5
      ctx!.beginPath()
      ctx!.arc(cx, cy, r, 0, -rad, true)
      ctx!.stroke()

      // Dashed projection lines
      const tipX = cx + r * Math.cos(rad)
      const tipY = cy - r * Math.sin(rad)
      ctx!.setLineDash([5, 4])
      ctx!.strokeStyle = 'rgba(247,129,102,0.35)'
      ctx!.lineWidth   = 1
      ctx!.beginPath(); ctx!.moveTo(tipX, tipY); ctx!.lineTo(tipX, cy); ctx!.stroke()
      ctx!.beginPath(); ctx!.moveTo(tipX, tipY); ctx!.lineTo(cx, tipY); ctx!.stroke()
      ctx!.setLineDash([])

      // Arm
      ctx!.strokeStyle = '#F78166'
      ctx!.lineWidth   = 3.5
      ctx!.lineCap     = 'round'
      ctx!.beginPath()
      ctx!.moveTo(cx, cy)
      ctx!.lineTo(tipX, tipY)
      ctx!.stroke()

      // Tip glow
      ctx!.fillStyle = 'rgba(247,129,102,0.2)'
      ctx!.beginPath(); ctx!.arc(tipX, tipY, 10, 0, Math.PI * 2); ctx!.fill()
      ctx!.fillStyle = '#F78166'
      ctx!.beginPath(); ctx!.arc(tipX, tipY, 5,  0, Math.PI * 2); ctx!.fill()

      // Origin dot
      ctx!.fillStyle = 'rgba(255,255,255,0.5)'
      ctx!.beginPath(); ctx!.arc(cx, cy, 4, 0, Math.PI * 2); ctx!.fill()

      // Readout label
      const deg = theta.toFixed(1)
      const rdx = ((theta * Math.PI) / 180).toFixed(4)
      ctx!.fillStyle   = 'rgba(255,255,255,0.7)'
      ctx!.font        = '13px "JetBrains Mono", monospace'
      ctx!.textAlign   = 'left'
      ctx!.fillText(`${deg}°  /  ${rdx} rad`, 12, H - 14)

      // Advance angle slowly
      angleRef.current = (angleRef.current + 0.4) % 360
      rafRef.current   = requestAnimationFrame(draw)
    }

    rafRef.current = requestAnimationFrame(draw)
    return () => cancelAnimationFrame(rafRef.current)
  }, [])

  return (
    <canvas
      ref={canvasRef}
      width={400}
      height={400}
      className="rounded-2xl"
      style={{ border: '1px solid var(--border)' }}
    />
  )
}

// ── Hero ──────────────────────────────────────────────────────────────────────

export default function Hero() {
  const [mounted, setMounted] = useState(false)
  useEffect(() => setMounted(true), [])

  return (
    <section className="min-h-screen flex items-center pt-16">
      <div className="max-w-6xl mx-auto px-6 w-full">
        <div className="flex flex-col lg:flex-row items-center gap-16 py-20">

          {/* ── Left — text ─────────────────────────────────────────────────── */}
          <div className="flex-1 text-center lg:text-left">

            {/* Eyebrow */}
            <p
              className="text-sm font-mono tracking-widest mb-6 uppercase"
              style={{ color: 'var(--primary)' }}
            >
              A Sikhay and Valiger Collaboration
            </p>

            {/* Headline */}
            <h1
              className="text-5xl lg:text-7xl font-bold leading-tight mb-6"
              style={{ color: 'var(--text)' }}
            >
              Math you can{' '}
              <span style={{ color: 'var(--primary)' }}>feel</span>
              <br />
              not just{' '}
              <span style={{ color: 'var(--arm1, #F78166)' }}>see</span>
            </h1>

            {/* Subtext */}
            <p
              className="text-lg leading-relaxed mb-10 max-w-xl mx-auto lg:mx-0"
              style={{ color: 'var(--muted)' }}
            >
              RADIAN is an ESP32-powered classroom device that teaches
              trigonometry, vectors, matrices, and polygon angles through
              physical rotation — with real-time feedback on a companion app.
            </p>

            {/* CTA buttons */}
            <div className="flex gap-4 justify-center lg:justify-start flex-wrap">
              <Link
                href="/demo"
                className="px-8 py-3.5 rounded-xl font-semibold text-sm transition-opacity hover:opacity-85 no-underline"
                style={{
                  backgroundColor: 'var(--primary)',
                  color:           'var(--bg)',
                }}
              >
                Try the Demo
              </Link>
              <a
                href="https://github.com/sikhayph/RADIAN"
                target="_blank"
                rel="noopener noreferrer"
                className="px-8 py-3.5 rounded-xl font-semibold text-sm border transition-opacity hover:opacity-85 no-underline flex items-center gap-2"
                style={{
                  borderColor:     'var(--border)',
                  color:           'var(--text)',
                  backgroundColor: 'transparent',
                }}
              >
                <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z"/>
                </svg>
                View on GitHub
              </a>
            </div>

            {/* Stats row */}
            <div
              className="flex gap-8 mt-12 justify-center lg:justify-start flex-wrap"
            >
              {[
                { value: '4',    label: 'Teaching modes'   },
                { value: '20Hz', label: 'BLE update rate'  },
                { value: '0.1°', label: 'Encoder accuracy' },
              ].map((stat) => (
                <div key={stat.label}>
                  <p
                    className="text-2xl font-bold font-mono"
                    style={{ color: 'var(--text)' }}
                  >
                    {stat.value}
                  </p>
                  <p
                    className="text-xs mt-0.5"
                    style={{ color: 'var(--muted)' }}
                  >
                    {stat.label}
                  </p>
                </div>
              ))}
            </div>
          </div>

          {/* ── Right — animated canvas ──────────────────────────────────────── */}
          <div className="flex-shrink-0">
            {mounted && (
              <div className="relative">
                {/* Glow behind canvas */}
                <div
                  className="absolute inset-0 rounded-2xl blur-3xl opacity-20"
                  style={{ backgroundColor: 'var(--primary)' }}
                />
                <div className="relative">
                  <UnitCirclePreview />
                  {/* Mode label below canvas */}
                  <p
                    className="text-center text-xs font-mono mt-3"
                    style={{ color: 'var(--muted)' }}
                  >
                    Mode 1 — Degree / Radian · live preview
                  </p>
                </div>
              </div>
            )}
          </div>

        </div>
      </div>
    </section>
  )
}

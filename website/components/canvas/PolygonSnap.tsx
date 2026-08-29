// ─────────────────────────────────────────────────────────────────────────────
// components/canvas/PolygonSnap.tsx
// HTML5 Canvas port of Flutter PolygonSnapPainter
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────
// NOTE: Implementation begins at M4 once Flutter CustomPainter
// is stable and validated end-to-end with real hardware.
// ─────────────────────────────────────────────────────────────────────────────

'use client'

import { useRef, useEffect } from 'react'

interface Props {
  // Props will mirror the Flutter painter parameters
  // Add fields here once M4 implementation begins
  width?:  number
  height?: number
}

export default function PolygonSnap({ width = 400, height = 400 }: Props) {
  const canvasRef = useRef<HTMLCanvasElement>(null)

  useEffect(() => {
    const canvas = canvasRef.current
    if (!canvas) return
    const ctx = canvas.getContext('2d')
    if (!ctx) return

    // ── Placeholder render ─────────────────────────────────────────────────
    ctx.clearRect(0, 0, width, height)
    ctx.strokeStyle = 'var(--border)'
    ctx.lineWidth   = 1
    ctx.strokeRect(1, 1, width - 2, height - 2)

    ctx.fillStyle    = 'var(--muted)'
    ctx.font         = '14px Inter, sans-serif'
    ctx.textAlign    = 'center'
    ctx.textBaseline = 'middle'
    ctx.fillText('PolygonSnap — M4', width / 2, height / 2)
    // ── End placeholder ────────────────────────────────────────────────────
  }, [width, height])

  return (
    <canvas
      ref={canvasRef}
      width={width}
      height={height}
      className="rounded-lg"
    />
  )
}

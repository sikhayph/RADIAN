// ─────────────────────────────────────────────────────────────────────────────
// components/canvas/VectorDiagram.tsx
// HTML5 Canvas port of Flutter VectorAdditionPainter
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────
// Draws the Mode 2 vector addition canvas:
//  • Arm 1 and Arm 2 as unit vectors from the origin
//  • Resultant vector (Arm 1 + Arm 2) from the origin
//  • Dashed component projection lines for each arm
//  • Faint parallelogram outline completing the tail-to-tip construction
// ─────────────────────────────────────────────────────────────────────────────

'use client'

import { useRef, useEffect } from 'react'

interface Props {
  a1Deg:   number // Arm 1 angle, degrees
  a2Deg:   number // Arm 2 angle, degrees
  width?:  number
  height?: number
}

interface Point {
  x: number
  y: number
}

// ── Color helpers ────────────────────────────────────────────────────────────
// Canvas has no equivalent of Flutter's Color.withOpacity(), so CSS custom
// properties (read as hex strings via getComputedStyle) are converted to
// rgba() strings on demand.

function hexToRgba(hex: string, alpha: number): string {
  const clean = hex.trim().replace('#', '')
  const r = parseInt(clean.slice(0, 2), 16)
  const g = parseInt(clean.slice(2, 4), 16)
  const b = parseInt(clean.slice(4, 6), 16)
  return `rgba(${r}, ${g}, ${b}, ${alpha})`
}

function readVar(el: Element, name: string): string {
  return getComputedStyle(el).getPropertyValue(name).trim()
}

// ── Geometry helpers ─────────────────────────────────────────────────────────
// Canvas, like Flutter's Canvas, has +y pointing DOWN. Unit circle convention
// has +y pointing UP, so y is negated when projecting into canvas space.

function toRad(deg: number): number {
  return (deg * Math.PI) / 180
}

function unitVector(deg: number): Point {
  const rad = toRad(deg)
  return { x: Math.cos(rad), y: Math.sin(rad) }
}

function toCanvas(unit: Point, center: Point, scale: number): Point {
  return { x: center.x + unit.x * scale, y: center.y - unit.y * scale }
}

function drawArrowhead(ctx: CanvasRenderingContext2D, from: Point, to: Point, color: string) {
  const dx = to.x - from.x
  const dy = to.y - from.y
  const dist = Math.hypot(dx, dy)
  if (dist < 1e-6) return

  const ux = dx / dist
  const uy = dy / dist
  const nx = -uy
  const ny = ux
  const headLen = 10
  const headWidth = 6
  const baseX = to.x - ux * headLen
  const baseY = to.y - uy * headLen

  ctx.beginPath()
  ctx.moveTo(to.x, to.y)
  ctx.lineTo(baseX + nx * headWidth, baseY + ny * headWidth)
  ctx.lineTo(baseX - nx * headWidth, baseY - ny * headWidth)
  ctx.closePath()
  ctx.fillStyle = color
  ctx.fill()
}

function drawVector(ctx: CanvasRenderingContext2D, from: Point, to: Point, color: string) {
  ctx.beginPath()
  ctx.lineCap = 'round'
  ctx.lineWidth = 4
  ctx.strokeStyle = color
  ctx.moveTo(from.x, from.y)
  ctx.lineTo(to.x, to.y)
  ctx.stroke()
  drawArrowhead(ctx, from, to, color)
}

function drawDashedLine(
  ctx: CanvasRenderingContext2D,
  p1: Point,
  p2: Point,
  color: string,
  width = 1
) {
  ctx.save()
  ctx.lineCap = 'butt'
  ctx.lineWidth = width
  ctx.strokeStyle = color
  ctx.setLineDash([4, 4])
  ctx.beginPath()
  ctx.moveTo(p1.x, p1.y)
  ctx.lineTo(p2.x, p2.y)
  ctx.stroke()
  ctx.restore()
}

function drawProjection(ctx: CanvasRenderingContext2D, center: Point, tip: Point, color: string) {
  const dashColor = hexToRgba(color, 0.35)
  drawDashedLine(ctx, tip, { x: tip.x, y: center.y }, dashColor)
  drawDashedLine(ctx, tip, { x: center.x, y: tip.y }, dashColor)
}

function drawText(
  ctx: CanvasRenderingContext2D,
  text: string,
  position: Point,
  size: number,
  weight: number,
  color: string
) {
  ctx.save()
  ctx.font = `${weight} ${size}px Inter, sans-serif`
  ctx.fillStyle = color
  ctx.textAlign = 'center'
  ctx.textBaseline = 'middle'
  ctx.fillText(text, position.x, position.y)
  ctx.restore()
}

// ── Component ─────────────────────────────────────────────────────────────────

export default function VectorDiagram({ a1Deg, a2Deg, width = 400, height = 400 }: Props) {
  const canvasRef = useRef<HTMLCanvasElement>(null)

  useEffect(() => {
    const canvas = canvasRef.current
    if (!canvas) return
    const ctx = canvas.getContext('2d')
    if (!ctx) return

    const draw = () => {
      // Read theme colors fresh on every draw — data-theme can change on
      // <html> without re-triggering this effect (a1Deg/a2Deg unchanged).
      const arm1Color      = readVar(canvas, '--arm1')
      const arm2Color      = readVar(canvas, '--arm2')
      const resultantColor = readVar(canvas, '--resultant')
      const borderColor    = readVar(canvas, '--border')
      const mutedColor     = readVar(canvas, '--muted')
      const textColor      = readVar(canvas, '--text')

      const center: Point = { x: width / 2, y: height / 2 }
      // Resultant can reach 2x a unit vector (parallel arms) — scale so it
      // always fits inside the canvas with margin.
      const scale = ((Math.min(width, height) / 2) * 0.8) / 2

      const v1 = unitVector(a1Deg)
      const v2 = unitVector(a2Deg)
      const resultant: Point = { x: v1.x + v2.x, y: v1.y + v2.y }

      const p1 = toCanvas(v1, center, scale)
      const p2 = toCanvas(v2, center, scale)
      const pr = toCanvas(resultant, center, scale)

      ctx.clearRect(0, 0, width, height)

      // ── Grid — reference rings at |v| = 1 and |v| = 2 ──────────────────────
      ctx.save()
      ctx.strokeStyle = hexToRgba(mutedColor, 0.102) // ≈ 0x1A alpha in Flutter theme
      ctx.lineWidth = 0.8
      ctx.beginPath()
      ctx.arc(center.x, center.y, scale, 0, Math.PI * 2)
      ctx.stroke()
      ctx.beginPath()
      ctx.arc(center.x, center.y, scale * 2, 0, Math.PI * 2)
      ctx.stroke()
      ctx.restore()

      // ── Axes ────────────────────────────────────────────────────────────────
      ctx.save()
      ctx.strokeStyle = hexToRgba(borderColor, 0.4)
      ctx.lineWidth = 1
      ctx.lineCap = 'round'
      ctx.beginPath()
      ctx.moveTo(center.x - scale * 2.2, center.y)
      ctx.lineTo(center.x + scale * 2.2, center.y)
      ctx.moveTo(center.x, center.y - scale * 2.2)
      ctx.lineTo(center.x, center.y + scale * 2.2)
      ctx.stroke()
      ctx.restore()

      // ── Parallelogram — tail-to-tip construction ───────────────────────────
      const parallelogramColor = hexToRgba(resultantColor, 0.3)
      drawDashedLine(ctx, p1, pr, parallelogramColor)
      drawDashedLine(ctx, p2, pr, parallelogramColor)

      // ── Component projections ──────────────────────────────────────────────
      drawProjection(ctx, center, p1, arm1Color)
      drawProjection(ctx, center, p2, arm2Color)

      // ── Vectors ─────────────────────────────────────────────────────────────
      drawVector(ctx, center, p1, arm1Color)
      drawVector(ctx, center, p2, arm2Color)
      drawVector(ctx, center, pr, resultantColor)

      // ── Origin ──────────────────────────────────────────────────────────────
      ctx.beginPath()
      ctx.fillStyle = hexToRgba(textColor, 0.6)
      ctx.arc(center.x, center.y, 3, 0, Math.PI * 2)
      ctx.fill()

      // ── Labels ──────────────────────────────────────────────────────────────
      drawText(ctx, 'Arm 1', { x: p1.x, y: p1.y - 16 }, 10, 600, arm1Color)
      drawText(ctx, 'Arm 2', { x: p2.x, y: p2.y - 16 }, 10, 600, arm2Color)
      drawText(ctx, 'R',     { x: pr.x, y: pr.y - 16 }, 11, 700, resultantColor)
    }

    draw()

    // Re-draw when the theme switcher flips <html data-theme="...">.
    const observer = new MutationObserver(draw)
    observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ['data-theme'],
    })

    return () => observer.disconnect()
  }, [a1Deg, a2Deg, width, height])

  return (
    <canvas
      ref={canvasRef}
      width={width}
      height={height}
      className="rounded-lg"
    />
  )
}

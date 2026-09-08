// ─────────────────────────────────────────────────────────────────────────────
// components/calculator/controls.tsx
// Shared form controls + layout for the calculator panels. Matches the site's
// input language (rounded-xl, --border, focus:--primary) and keeps 44px targets.
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

'use client'

import { useId, type ReactNode } from 'react'

// ── Two-column panel layout: controls on the left, figure on the right ────────

export function CalcLayout({
  controls,
  figure,
}: {
  controls: ReactNode
  figure: ReactNode
}) {
  return (
    <div className="grid grid-cols-1 gap-8 lg:grid-cols-[1fr_minmax(0,420px)] lg:gap-12">
      <div className="flex flex-col gap-6">{controls}</div>
      <div className="flex flex-col items-center gap-3">{figure}</div>
    </div>
  )
}

// ── Figure card — wraps an inline SVG in the site's floating-card surface ─────

export function FigureCard({
  children,
  caption,
}: {
  children: ReactNode
  caption?: string
}) {
  return (
    <>
      <div className="w-full max-w-[420px] rounded-2xl border border-[var(--border)] bg-[var(--surface)] p-3">
        {children}
      </div>
      {caption && (
        <p className="text-center text-xs font-mono text-[var(--muted)]">{caption}</p>
      )}
    </>
  )
}

// ── Number field ─────────────────────────────────────────────────────────────

export function NumberField({
  label,
  value,
  onChange,
  step = 1,
  min,
  max,
  suffix,
}: {
  label: string
  value: number
  onChange: (n: number) => void
  step?: number
  min?: number
  max?: number
  suffix?: string
}) {
  const id = useId()
  return (
    <div>
      <label htmlFor={id} className="mb-1.5 block text-sm font-medium text-[var(--text)]">
        {label}
      </label>
      <div className="flex items-center gap-2">
        <input
          id={id}
          type="number"
          value={Number.isFinite(value) ? value : ''}
          step={step}
          min={min}
          max={max}
          onChange={(e) => {
            const n = parseFloat(e.target.value)
            onChange(Number.isNaN(n) ? 0 : n)
          }}
          className="min-h-[44px] w-full rounded-xl border border-[var(--border)] bg-[var(--bg)] px-4 py-2.5 text-sm text-[var(--text)] outline-none transition-colors duration-200 focus:border-[var(--primary)]"
        />
        {suffix && (
          <span className="flex-shrink-0 text-sm font-mono text-[var(--muted)]">
            {suffix}
          </span>
        )}
      </div>
    </div>
  )
}

// ── Range + number pair (used for polygon side count) ────────────────────────

export function RangeField({
  label,
  value,
  onChange,
  min,
  max,
  step = 1,
}: {
  label: string
  value: number
  onChange: (n: number) => void
  min: number
  max: number
  step?: number
}) {
  const id = useId()
  return (
    <div>
      <div className="mb-1.5 flex items-baseline justify-between">
        <label htmlFor={id} className="text-sm font-medium text-[var(--text)]">
          {label}
        </label>
        <span className="text-sm font-mono text-[var(--primary)]">{value}</span>
      </div>
      <input
        id={id}
        type="range"
        value={value}
        min={min}
        max={max}
        step={step}
        onChange={(e) => onChange(parseInt(e.target.value, 10))}
        className="h-11 w-full cursor-pointer accent-[var(--primary)]"
      />
    </div>
  )
}

// ── Segmented toggle (2 options) ─────────────────────────────────────────────

export function Segmented<T extends string>({
  label,
  options,
  value,
  onChange,
}: {
  label: string
  options: { value: T; label: string }[]
  value: T
  onChange: (v: T) => void
}) {
  return (
    <div>
      <span className="mb-1.5 block text-sm font-medium text-[var(--text)]">{label}</span>
      <div
        role="group"
        aria-label={label}
        className="inline-flex rounded-xl border border-[var(--border)] p-1"
      >
        {options.map((opt) => (
          <button
            key={opt.value}
            type="button"
            aria-pressed={value === opt.value}
            onClick={() => onChange(opt.value)}
            className={`min-h-[36px] rounded-lg px-4 text-sm font-medium transition-colors duration-200 ${
              value === opt.value
                ? 'bg-[color-mix(in_srgb,var(--primary)_15%,transparent)] text-[var(--text)]'
                : 'text-[var(--muted)] hover:text-[var(--text)]'
            }`}
          >
            {opt.label}
          </button>
        ))}
      </div>
    </div>
  )
}

// ── Read-out row ─────────────────────────────────────────────────────────────

export function Readout({
  items,
}: {
  items: { label: string; value: string; accent?: boolean }[]
}) {
  return (
    <dl className="grid grid-cols-2 gap-x-4 gap-y-3 rounded-2xl border border-[var(--border)] bg-[var(--surface)] p-5">
      {items.map((item) => (
        <div key={item.label}>
          <dt className="text-xs uppercase tracking-wide text-[var(--muted)]">
            {item.label}
          </dt>
          <dd
            className={`mt-0.5 text-lg font-bold font-mono ${
              item.accent ? 'text-[var(--primary)]' : 'text-[var(--text)]'
            }`}
          >
            {item.value}
          </dd>
        </div>
      ))}
    </dl>
  )
}

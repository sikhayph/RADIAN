// ─────────────────────────────────────────────────────────────────────────────
// components/ui/WaitlistForm.tsx
// Email capture for the v1-hardware waitlist. Posts to /api/waitlist.
//
// UX per docs/ui_spec.md + ui-ux-pro-max (Forms): visible label, inline error
// bound with aria-describedby, polite live region, 44px targets, honeypot.
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

'use client'

import { useId, useState, type FormEvent } from 'react'
import { isValidEmail } from '../../lib/waitlist/validate'

type Status = 'idle' | 'submitting' | 'subscribed' | 'already' | 'error'

export default function WaitlistForm() {
  const emailId = useId()
  const errorId = `${emailId}-error`

  const [email, setEmail] = useState('')
  const [company, setCompany] = useState('') // honeypot
  const [status, setStatus] = useState<Status>('idle')
  const [message, setMessage] = useState('')

  const isDone = status === 'subscribed' || status === 'already'
  const showError = status === 'error'

  async function onSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault()
    if (status === 'submitting') return

    if (!isValidEmail(email)) {
      setStatus('error')
      setMessage('Enter a valid email address.')
      return
    }

    setStatus('submitting')
    setMessage('')

    try {
      const res = await fetch('/api/waitlist', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, company }),
      })
      const data = (await res.json().catch(() => ({}))) as {
        status?: string
        error?: string
      }

      if (res.ok && data.status === 'already_subscribed') {
        setStatus('already')
        setMessage("You're already on the list — we'll be in touch.")
        return
      }
      if (res.ok || res.status === 201) {
        setStatus('subscribed')
        setMessage("You're on the list. We'll email you when v1 ships.")
        return
      }

      setStatus('error')
      setMessage(data.error ?? 'Something went wrong. Please try again.')
    } catch {
      setStatus('error')
      setMessage('Network error. Please check your connection and try again.')
    }
  }

  if (isDone) {
    return (
      <div
        className="mx-auto flex max-w-md items-center justify-center gap-3 rounded-xl border border-[var(--border)] bg-[var(--surface)] px-5 py-4 text-sm text-[var(--text)] motion-safe:transition-all motion-safe:duration-500"
        role="status"
      >
        <span
          aria-hidden="true"
          className="flex h-6 w-6 flex-shrink-0 items-center justify-center rounded-full bg-[color-mix(in_srgb,var(--secondary)_20%,transparent)] text-[var(--secondary)]"
        >
          <svg width="14" height="14" viewBox="0 0 12 12" fill="none">
            <path
              d="M2 6l3 3 5-5"
              stroke="currentColor"
              strokeWidth="1.75"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          </svg>
        </span>
        <span>{message}</span>
      </div>
    )
  }

  return (
    <form onSubmit={onSubmit} noValidate className="mx-auto max-w-md">
      <label
        htmlFor={emailId}
        className="mb-2 block text-left text-sm font-medium text-[var(--text)]"
      >
        Email address
      </label>

      <div className="flex flex-col gap-3 sm:flex-row">
        <input
          id={emailId}
          type="email"
          name="email"
          value={email}
          onChange={(e) => {
            setEmail(e.target.value)
            if (status === 'error') {
              setStatus('idle')
              setMessage('')
            }
          }}
          onBlur={() => {
            if (email && !isValidEmail(email)) {
              setStatus('error')
              setMessage('Enter a valid email address.')
            }
          }}
          required
          autoComplete="email"
          inputMode="email"
          placeholder="you@school.edu"
          aria-invalid={showError}
          aria-describedby={showError ? errorId : undefined}
          className="min-h-[44px] flex-1 rounded-xl border border-[var(--border)] bg-[var(--bg)] px-4 py-3 text-sm text-[var(--text)] outline-none transition-colors duration-200 placeholder:text-[var(--muted)] focus:border-[var(--primary)]"
        />

        {/* Honeypot — visually hidden, off the tab order, not announced. */}
        <input
          type="text"
          name="company"
          tabIndex={-1}
          autoComplete="off"
          aria-hidden="true"
          value={company}
          onChange={(e) => setCompany(e.target.value)}
          className="absolute left-[-9999px] h-0 w-0 opacity-0"
        />

        <button
          type="submit"
          disabled={status === 'submitting'}
          className="inline-flex min-h-[44px] items-center justify-center gap-2 rounded-xl bg-[var(--primary)] px-6 py-3 text-sm font-semibold text-[var(--bg)] transition-opacity duration-300 ease-premium hover:opacity-85 disabled:cursor-not-allowed disabled:opacity-60"
        >
          {status === 'submitting' ? (
            <>
              <span
                aria-hidden="true"
                className="h-4 w-4 animate-spin rounded-full border-2 border-[var(--bg)] border-t-transparent"
              />
              Joining…
            </>
          ) : (
            'Join the waitlist'
          )}
        </button>
      </div>

      {/* Live region is always present so SR users hear the message when it sets. */}
      <p
        id={errorId}
        role={showError ? 'alert' : undefined}
        aria-live="polite"
        className={`mt-2 min-h-[1.25rem] text-left text-sm ${
          showError ? 'text-[var(--arm1)]' : 'text-transparent'
        }`}
      >
        {showError ? message : ' '}
      </p>
    </form>
  )
}

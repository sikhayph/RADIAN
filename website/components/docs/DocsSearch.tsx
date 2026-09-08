// ─────────────────────────────────────────────────────────────────────────────
// components/docs/DocsSearch.tsx
// Client-side fuzzy search over the build-time docs index (public/search-index.json).
// Fuse.js for ranking; keyboard-navigable results that deep-link to /docs/<slug>#<anchor>.
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

'use client'

import { useEffect, useId, useMemo, useRef, useState } from 'react'
import { useRouter } from 'next/navigation'
import Fuse from 'fuse.js'

interface DocRecord {
  slug: string
  docTitle: string
  heading: string
  level: number
  anchor: string
  text: string
}

function hrefFor(r: DocRecord): string {
  return r.anchor ? `/docs/${r.slug}#${r.anchor}` : `/docs/${r.slug}`
}

export default function DocsSearch() {
  const router = useRouter()
  const inputId = useId()
  const listId = `${inputId}-results`

  const [records, setRecords] = useState<DocRecord[] | null>(null)
  const [query, setQuery] = useState('')
  const [activeIndex, setActiveIndex] = useState(0)
  const inputRef = useRef<HTMLInputElement>(null)

  // Load the index once.
  useEffect(() => {
    let cancelled = false
    fetch('/search-index.json')
      .then((res) => (res.ok ? res.json() : []))
      .then((data: DocRecord[]) => {
        if (!cancelled) setRecords(data)
      })
      .catch(() => {
        if (!cancelled) setRecords([])
      })
    return () => {
      cancelled = true
    }
  }, [])

  // "/" focuses the search box (unless already typing in a field).
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      const el = e.target as HTMLElement | null
      const typing = el && /^(INPUT|TEXTAREA|SELECT)$/.test(el.tagName)
      if (e.key === '/' && !typing) {
        e.preventDefault()
        inputRef.current?.focus()
      }
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [])

  const fuse = useMemo(
    () =>
      records
        ? new Fuse(records, {
            keys: [
              { name: 'heading', weight: 0.5 },
              { name: 'text', weight: 0.3 },
              { name: 'docTitle', weight: 0.2 },
            ],
            threshold: 0.4,
            ignoreLocation: true,
            minMatchCharLength: 2,
          })
        : null,
    [records],
  )

  const results = useMemo(() => {
    const q = query.trim()
    if (!fuse || q.length < 2) return []
    return fuse.search(q, { limit: 8 }).map((r) => r.item)
  }, [fuse, query])

  useEffect(() => setActiveIndex(0), [query])

  const open = query.trim().length >= 2

  function onKeyDown(e: React.KeyboardEvent<HTMLInputElement>) {
    if (e.key === 'Escape') {
      setQuery('')
      return
    }
    if (!open || results.length === 0) return
    if (e.key === 'ArrowDown') {
      e.preventDefault()
      setActiveIndex((i) => (i + 1) % results.length)
    } else if (e.key === 'ArrowUp') {
      e.preventDefault()
      setActiveIndex((i) => (i - 1 + results.length) % results.length)
    } else if (e.key === 'Enter') {
      e.preventDefault()
      const r = results[activeIndex]
      if (r) {
        router.push(hrefFor(r))
        setQuery('')
      }
    }
  }

  return (
    <div className="mx-auto mb-14 max-w-xl">
      <label htmlFor={inputId} className="sr-only">
        Search the documentation
      </label>
      <div className="relative">
        <span
          aria-hidden="true"
          className="pointer-events-none absolute left-4 top-1/2 -translate-y-1/2 text-[var(--muted)]"
        >
          <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
            <circle cx="7" cy="7" r="5" stroke="currentColor" strokeWidth="1.5" />
            <path d="M11 11l3 3" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
          </svg>
        </span>
        <input
          id={inputId}
          ref={inputRef}
          type="search"
          role="combobox"
          aria-expanded={open}
          aria-controls={listId}
          aria-autocomplete="list"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          onKeyDown={onKeyDown}
          placeholder={
            records === null ? 'Loading search…' : 'Search docs — try “notify interval”'
          }
          disabled={records === null}
          className="min-h-[48px] w-full rounded-xl border border-[var(--border)] bg-[var(--surface)] pl-11 pr-4 py-3 text-sm text-[var(--text)] outline-none transition-colors duration-200 placeholder:text-[var(--muted)] focus:border-[var(--primary)]"
        />
      </div>

      {/* Live region — result count for screen readers. */}
      <p className="sr-only" aria-live="polite">
        {open ? `${results.length} result${results.length === 1 ? '' : 's'}` : ''}
      </p>

      {open && (
        <ul
          id={listId}
          role="listbox"
          className="mt-3 flex flex-col gap-2"
        >
          {results.length === 0 ? (
            <li className="rounded-xl border border-[var(--border)] bg-[var(--surface)] px-4 py-6 text-center text-sm text-[var(--muted)]">
              No matches for “{query.trim()}”. Try a term from the docs — a field name,
              a heading, or a component.
            </li>
          ) : (
            results.map((r, i) => (
              <li key={`${r.slug}-${r.anchor}-${i}`} role="option" aria-selected={i === activeIndex}>
                <a
                  href={hrefFor(r)}
                  onClick={() => setQuery('')}
                  onMouseEnter={() => setActiveIndex(i)}
                  className={`block rounded-xl border px-4 py-3 no-underline transition-colors duration-150 ${
                    i === activeIndex
                      ? 'border-[var(--primary)] bg-[color-mix(in_srgb,var(--primary)_8%,transparent)]'
                      : 'border-[var(--border)] bg-[var(--surface)]'
                  }`}
                >
                  <span className="flex items-center gap-2 text-xs font-mono text-[var(--muted)]">
                    {r.docTitle}
                    <span aria-hidden="true">›</span>
                  </span>
                  <span className="mt-0.5 block text-sm font-semibold text-[var(--text)]">
                    {r.heading}
                  </span>
                  {r.text && (
                    <span className="mt-1 block text-xs leading-relaxed text-[var(--muted)] line-clamp-2">
                      {r.text}
                    </span>
                  )}
                </a>
              </li>
            ))
          )}
        </ul>
      )}
    </div>
  )
}

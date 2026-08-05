// ─────────────────────────────────────────────────────────────────────────────
// components/ui/Navbar.tsx
// Navigation bar — logo, links, theme switcher
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

'use client'

import { useState, useEffect } from 'react'
import Link from 'next/link'

// ── Theme types ───────────────────────────────────────────────────────────────

type Theme = 'obsidian' | 'chalk' | 'sikhay'

const themes: { value: Theme; label: string; dot: string }[] = [
  { value: 'obsidian', label: 'Obsidian', dot: '#0D1117' },
  { value: 'chalk',    label: 'Chalk',    dot: '#FAFAFA' },
  { value: 'sikhay',   label: 'Sikhay',   dot: '#0A0A0A' },
]

// ── Nav links ─────────────────────────────────────────────────────────────────

const links = [
  { href: '/',       label: 'Home'    },
  { href: '/demo',   label: 'Demo'    },
  { href: '/docs',   label: 'Docs'    },
  { href: '/about',  label: 'About'   },
]

// ── Component ─────────────────────────────────────────────────────────────────

export default function Navbar() {
  const [theme,       setTheme]       = useState<Theme>('obsidian')
  const [menuOpen,    setMenuOpen]    = useState(false)
  const [themeOpen,   setThemeOpen]   = useState(false)
  const [scrolled,    setScrolled]    = useState(false)

  // Apply theme to <html> data-theme attribute
  useEffect(() => {
    document.documentElement.setAttribute('data-theme', theme)
  }, [theme])

  // Collapse nav background on scroll
  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 8)
    window.addEventListener('scroll', onScroll)
    return () => window.removeEventListener('scroll', onScroll)
  }, [])

  // Close dropdowns on outside click
  useEffect(() => {
    const close = () => { setThemeOpen(false); setMenuOpen(false) }
    document.addEventListener('click', close)
    return () => document.removeEventListener('click', close)
  }, [])

  return (
    <nav
      className="fixed top-0 left-0 right-0 z-50 transition-all duration-200"
      style={{
        backgroundColor: scrolled
          ? 'var(--surface)'
          : 'transparent',
        borderBottom: scrolled
          ? '1px solid var(--border)'
          : '1px solid transparent',
      }}
    >
      <div className="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between">

        {/* ── Logo ────────────────────────────────────────────────────────── */}
        <Link href="/" className="flex items-center gap-3 no-underline">
          {/* Wordmark */}
          <span
            className="text-xl font-bold tracking-tight"
            style={{ color: 'var(--text)' }}
          >
            RADIAN
          </span>
          {/* Pill badge */}
          <span
            className="text-xs font-mono px-2 py-0.5 rounded-full border"
            style={{
              color:           'var(--primary)',
              borderColor:     'var(--primary)',
              backgroundColor: 'transparent',
            }}
          >
            v0.1
          </span>
        </Link>

        {/* ── Desktop links ────────────────────────────────────────────────── */}
        <div className="hidden md:flex items-center gap-8">
          {links.map((link) => (
            <Link
              key={link.href}
              href={link.href}
              className="text-sm font-medium transition-opacity hover:opacity-60"
              style={{ color: 'var(--text)', textDecoration: 'none' }}
            >
              {link.label}
            </Link>
          ))}
        </div>

        {/* ── Right side ───────────────────────────────────────────────────── */}
        <div className="flex items-center gap-3">

          {/* Theme switcher */}
          <div
            className="relative"
            onClick={(e) => e.stopPropagation()}
          >
            <button
              onClick={() => setThemeOpen(!themeOpen)}
              className="flex items-center gap-2 px-3 py-1.5 rounded-lg border text-sm transition-opacity hover:opacity-80"
              style={{
                borderColor:     'var(--border)',
                backgroundColor: 'var(--surface)',
                color:           'var(--text)',
              }}
            >
              {/* Current theme dot */}
              <span
                className="w-3 h-3 rounded-full border inline-block"
                style={{
                  backgroundColor: themes.find(t => t.value === theme)?.dot,
                  borderColor:     'var(--border)',
                }}
              />
              <span className="hidden sm:inline">
                {themes.find(t => t.value === theme)?.label}
              </span>
              <svg
                width="12" height="12" viewBox="0 0 12 12" fill="none"
                style={{ color: 'var(--muted)' }}
              >
                <path d="M2 4l4 4 4-4" stroke="currentColor"
                  strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
              </svg>
            </button>

            {/* Dropdown */}
            {themeOpen && (
              <div
                className="absolute right-0 mt-2 w-40 rounded-xl border shadow-xl overflow-hidden z-50"
                style={{
                  backgroundColor: 'var(--surface)',
                  borderColor:     'var(--border)',
                }}
              >
                {themes.map((t) => (
                  <button
                    key={t.value}
                    onClick={() => { setTheme(t.value); setThemeOpen(false) }}
                    className="w-full flex items-center gap-3 px-4 py-3 text-sm text-left transition-opacity hover:opacity-70"
                    style={{
                      color:           'var(--text)',
                      backgroundColor: theme === t.value
                        ? 'var(--primary)22'
                        : 'transparent',
                    }}
                  >
                    <span
                      className="w-3 h-3 rounded-full border flex-shrink-0"
                      style={{
                        backgroundColor: t.dot,
                        borderColor:     'var(--border)',
                      }}
                    />
                    {t.label}
                    {theme === t.value && (
                      <svg
                        className="ml-auto" width="12" height="12"
                        viewBox="0 0 12 12" fill="none"
                        style={{ color: 'var(--primary)' }}
                      >
                        <path d="M2 6l3 3 5-5" stroke="currentColor"
                          strokeWidth="1.5" strokeLinecap="round"
                          strokeLinejoin="round"/>
                      </svg>
                    )}
                  </button>
                ))}
              </div>
            )}
          </div>

          {/* GitHub link */}
          <a
            href="https://github.com/sikhayph/RADIAN"
            target="_blank"
            rel="noopener noreferrer"
            className="hidden sm:flex items-center gap-2 px-3 py-1.5 rounded-lg border text-sm transition-opacity hover:opacity-80"
            style={{
              borderColor:     'var(--border)',
              backgroundColor: 'var(--surface)',
              color:           'var(--text)',
              textDecoration:  'none',
            }}
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
              <path d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z"/>
            </svg>
            GitHub
          </a>

          {/* Mobile menu toggle */}
          <button
            className="md:hidden p-2 rounded-lg"
            style={{ color: 'var(--text)' }}
            onClick={(e) => { e.stopPropagation(); setMenuOpen(!menuOpen) }}
          >
            <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
              {menuOpen ? (
                <path d="M4 4l12 12M16 4L4 16" stroke="currentColor"
                  strokeWidth="1.5" strokeLinecap="round"/>
              ) : (
                <path d="M3 5h14M3 10h14M3 15h14" stroke="currentColor"
                  strokeWidth="1.5" strokeLinecap="round"/>
              )}
            </svg>
          </button>
        </div>
      </div>

      {/* ── Mobile menu ──────────────────────────────────────────────────────── */}
      {menuOpen && (
        <div
          className="md:hidden border-t px-6 py-4 flex flex-col gap-4"
          style={{
            backgroundColor: 'var(--surface)',
            borderColor:     'var(--border)',
          }}
          onClick={(e) => e.stopPropagation()}
        >
          {links.map((link) => (
            <Link
              key={link.href}
              href={link.href}
              className="text-sm font-medium"
              style={{ color: 'var(--text)', textDecoration: 'none' }}
              onClick={() => setMenuOpen(false)}
            >
              {link.label}
            </Link>
          ))}
          <a
            href="https://github.com/sikhayph/RADIAN"
            target="_blank"
            rel="noopener noreferrer"
            className="text-sm font-medium"
            style={{ color: 'var(--primary)', textDecoration: 'none' }}
          >
            GitHub →
          </a>
        </div>
      )}
    </nav>
  )
}

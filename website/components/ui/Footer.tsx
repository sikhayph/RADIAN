// ─────────────────────────────────────────────────────────────────────────────
// components/ui/Footer.tsx
// Site footer — copyright, primary links, GitHub, Sikhay branding
// Sikhay and Valiger Collaboration
//
// Styled per docs/ui_spec.md (floating-card system), not Navbar's glass
// treatment: rounded-2xl + border + solid surface, matching the card
// language used across ModeShowcase and app_theme.dart's cardTheme.
// ─────────────────────────────────────────────────────────────────────────────

import Link from 'next/link'

const links = [
  { href: '/about', label: 'About' },
  { href: '/demo',  label: 'Demo'  },
  { href: '/docs',  label: 'Docs'  },
]

export default function Footer() {
  const year = new Date().getFullYear()

  return (
    <footer className="px-6 pb-6">
      <div className="max-w-6xl mx-auto rounded-2xl border border-[var(--border)] bg-[var(--surface)] px-6 py-8">
        <div className="flex flex-col sm:flex-row items-center sm:items-start justify-between gap-6">

          {/* ── Brand ─────────────────────────────────────────────────────── */}
          <div className="flex flex-col items-center sm:items-start gap-1">
            <span className="text-lg font-bold tracking-tight text-[var(--text)]">
              RADIAN
            </span>
            <span className="text-xs text-[var(--muted)]">
              Built by Sikhay &amp; Valiger
            </span>
          </div>

          {/* ── Links ─────────────────────────────────────────────────────── */}
          <div className="flex items-center gap-6">
            {links.map((link) => (
              <Link
                key={link.href}
                href={link.href}
                className="text-sm font-medium text-[var(--text)] no-underline transition-opacity duration-300 ease-premium hover:opacity-60"
              >
                {link.label}
              </Link>
            ))}
            <a
              href="https://github.com/sikhayph/RADIAN"
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center gap-2 text-sm font-medium text-[var(--text)] no-underline transition-opacity duration-300 ease-premium hover:opacity-60"
            >
              <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                <path d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z"/>
              </svg>
              GitHub
            </a>
          </div>
        </div>

        {/* ── Divider + copyright ───────────────────────────────────────── */}
        <div className="mt-6 pt-6 border-t border-[var(--border)] text-center sm:text-left">
          <p className="text-xs text-[var(--muted)]">
            © {year} Sikhay Research, Development and Prototyping and Valiger. All rights reserved.
          </p>
        </div>
      </div>
    </footer>
  )
}

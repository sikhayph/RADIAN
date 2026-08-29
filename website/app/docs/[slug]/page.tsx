// ─────────────────────────────────────────────────────────────────────────────
// app/docs/[slug]/page.tsx
// Individual documentation page — statically generated for all four docs.
// Static Server Component (no 'use client').
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import type { Metadata } from 'next'
import Link from 'next/link'
import { notFound } from 'next/navigation'
import { getAllSlugs, getDocBySlug } from '../../../lib/docs'

// ── Static generation ─────────────────────────────────────────────────────────

export function generateStaticParams() {
  return getAllSlugs().map((slug) => ({ slug }))
}

// ── Per-page metadata ─────────────────────────────────────────────────────────

export async function generateMetadata({
  params,
}: {
  params: { slug: string }
}): Promise<Metadata> {
  const doc = await getDocBySlug(params.slug)
  if (!doc) {
    return {
      title:       'Not Found | RADIAN Docs',
      description: 'This documentation page does not exist.',
    }
  }

  return {
    title:       `${doc.title} | RADIAN`,
    description: doc.description,
    openGraph: {
      title:       `${doc.title} | RADIAN`,
      description: doc.description,
      type:        'article',
    },
  }
}

// ── Page component ────────────────────────────────────────────────────────────

export default async function DocPage({
  params,
}: {
  params: { slug: string }
}) {
  const doc = await getDocBySlug(params.slug)
  if (!doc) notFound()

  return (
    <main className="min-h-screen pt-28 pb-24">
      <div className="max-w-3xl mx-auto px-6">

        {/* ── Back navigation ───────────────────────────────────────────────── */}
        <Link
          href="/docs"
          className="inline-flex items-center gap-1.5 text-sm font-mono text-[var(--muted)] hover:text-[var(--primary)] transition-colors duration-200 no-underline mb-10 group"
        >
          <span className="group-hover:-translate-x-0.5 transition-transform duration-200">←</span>
          All docs
        </Link>

        {/* ── Rendered markdown ─────────────────────────────────────────────── */}
        <article
          className="prose prose-invert prose-obsidian max-w-none"
          dangerouslySetInnerHTML={{ __html: doc.contentHtml }}
        />

        {/* ── Footer back link ──────────────────────────────────────────────── */}
        <div className="mt-16 pt-8 border-t border-[var(--border)]">
          <Link
            href="/docs"
            className="inline-flex items-center gap-1.5 text-sm font-mono text-[var(--muted)] hover:text-[var(--primary)] transition-colors duration-200 no-underline group"
          >
            <span className="group-hover:-translate-x-0.5 transition-transform duration-200">←</span>
            Back to documentation
          </Link>
        </div>

      </div>
    </main>
  )
}
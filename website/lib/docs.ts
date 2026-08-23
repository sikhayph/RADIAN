// ─────────────────────────────────────────────────────────────────────────────
// lib/docs.ts
// Server-side helper — reads, parses, and converts the docs/ markdown files.
// All functions are server-only (no 'use client'). Invoked only from Server
// Components and generateStaticParams / generateMetadata.
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import fs   from 'fs'
import path from 'path'
import matter from 'gray-matter'
import { unified } from 'unified'
import remarkParse from 'remark-parse'
import remarkGfm from 'remark-gfm'
import remarkRehype from 'remark-rehype'
import rehypeSanitize from 'rehype-sanitize'
import rehypeStringify from 'rehype-stringify'

// docs/ lives one level above website/ in the repo root
const DOCS_DIR = path.join(process.cwd(), '..', 'docs')

// ── Slug ↔ filename map ───────────────────────────────────────────────────────

const SLUG_TO_FILE: Record<string, string> = {
  'ble-contract':    'ble_contract.md',
  'architecture':    'architecture.md',
  'hardware-pinout': 'hardware_pinout.md',
  'ui-spec':         'ui_spec.md',
}

// ── Types ─────────────────────────────────────────────────────────────────────

export interface DocMeta {
  slug:        string
  title:       string
  description: string
}

export interface DocContent extends DocMeta {
  contentHtml: string
}

// ── Internal helpers ──────────────────────────────────────────────────────────

/**
 * Extracts the H1 title and a short description from the top of a markdown
 * document body (after gray-matter strips any YAML frontmatter).
 *
 * Strategy:
 *  - Title  → first line that starts with `# `
 *  - Description → up to 3 non-empty, non-separator lines immediately after
 *    the title, with markdown formatting stripped (bold markers, blockquote
 *    `>`, backticks, inline links). Joined with " | ".
 */
function extractMeta(content: string): { title: string; description: string } {
  const lines = content.split('\n').map((l) => l.trim())

  let title = 'RADIAN Documentation'
  let titleFound = false
  const descParts: string[] = []

  for (const line of lines) {
    if (!line) continue

    if (!titleFound) {
      if (line.startsWith('# ')) {
        title = line.slice(2).trim()
        titleFound = true
      }
      continue
    }

    // We are past the title — gather description lines
    if (line === '---') {
      // A horizontal rule that follows content means we're done
      if (descParts.length > 0) break
      continue // leading --- before any content: skip
    }

    if (line.startsWith('##') || line.startsWith('```')) break // next section or code block

    const cleaned = line
      .replace(/^>\s*/, '')                        // blockquote marker
      .replace(/\*\*/g, '')                         // bold **…**
      .replace(/`/g, '')                            // inline code
      .replace(/\[([^\]]+)\]\([^)]+\)/g, '$1')     // [text](url) → text
      .trim()

    if (cleaned) {
      descParts.push(cleaned)
      if (descParts.length >= 3) break
    }
  }

  let description = descParts.join(' | ')
  if (description.length > 150) description = description.slice(0, 147) + '...'

  return { title, description }
}

// ── Public API ────────────────────────────────────────────────────────────────

/** Returns metadata for all four docs — used to render the hub index cards. */
export function getAllDocMeta(): DocMeta[] {
  return Object.entries(SLUG_TO_FILE).map(([slug, fileName]) => {
    const raw = fs.readFileSync(path.join(DOCS_DIR, fileName), 'utf-8')
    const { content } = matter(raw)
    const { title, description } = extractMeta(content)
    return { slug, title, description }
  })
}

/** Returns the four valid slug strings — used by generateStaticParams. */
export function getAllSlugs(): string[] {
  return Object.keys(SLUG_TO_FILE)
}

/**
 * Reads, parses, and converts one doc to HTML.
 * Returns null for unknown slugs (caller should invoke notFound()).
 */
export async function getDocBySlug(slug: string): Promise<DocContent | null> {
  const fileName = SLUG_TO_FILE[slug]
  if (!fileName) return null

  const raw = fs.readFileSync(path.join(DOCS_DIR, fileName), 'utf-8')
  const { content } = matter(raw)               // strips YAML frontmatter (empty here, that's fine)
  const { title, description } = extractMeta(content)

  // unified pipeline: parse markdown (with GFM) → convert to hast
  // → sanitize HTML (default GitHub schema) → stringify
  // allowDangerousHtml:true lets raw HTML blocks pass into hast so rehype-sanitize
  // can explicitly strip them (raw nodes fall through the sanitizer's switch).
  const processed = await unified()
    .use(remarkParse)
    .use(remarkGfm)
    .use(remarkRehype, { allowDangerousHtml: true })
    .use(rehypeSanitize)
    .use(rehypeStringify)
    .process(content)

  return { slug, title, description, contentHtml: String(processed) }
}

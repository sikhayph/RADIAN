// ─────────────────────────────────────────────────────────────────────────────
// scripts/build-docs-index.mjs
// Build-time step: walk the repo docs/*.md, split them by heading, and emit a
// flat JSON search index consumed by components/docs/DocsSearch.tsx (Fuse.js).
//
// Runs automatically before `next build` via the "prebuild" npm script, and can
// be run directly (`node scripts/build-docs-index.mjs`) to refresh it in dev.
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import matter from 'gray-matter'
import GithubSlugger from 'github-slugger'
import slugMap from '../lib/docs-map.json' with { type: 'json' }

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const DOCS_DIR = path.resolve(__dirname, '..', '..', 'docs')
const OUT_FILE = path.resolve(__dirname, '..', 'public', 'search-index.json')

const MAX_SNIPPET = 300

/** Strip inline markdown so snippets read as plain text. */
function stripInline(line) {
  return line
    .replace(/`([^`]+)`/g, '$1')
    .replace(/\*\*([^*]+)\*\*/g, '$1')
    .replace(/\*([^*]+)\*/g, '$1')
    .replace(/\[([^\]]+)\]\([^)]+\)/g, '$1')
    .replace(/^>\s?/, '')
    .replace(/^[-*+]\s+/, '')
    .replace(/^\|/, '')
    .replace(/\|/g, ' ')
    .trim()
}

function indexDoc(slug, fileName) {
  const raw = fs.readFileSync(path.join(DOCS_DIR, fileName), 'utf-8')
  const { content } = matter(raw)
  const lines = content.split('\n')

  // One slugger per doc — matches rehype-slug's per-file dedupe behaviour
  // (repeat headings get "-1", "-2" … suffixes), so anchors line up with
  // what lib/docs.ts renders.
  const slugger = new GithubSlugger()

  const records = []
  let docTitle = slug
  let current = null
  let inFence = false

  const flush = () => {
    if (!current) return
    const text = current.buf.join(' ').replace(/\s+/g, ' ').trim().slice(0, MAX_SNIPPET)
    records.push({
      slug,
      docTitle,
      heading: current.heading,
      level: current.level,
      anchor: current.anchor,
      text,
    })
  }

  for (const rawLine of lines) {
    const line = rawLine.trimEnd()

    if (line.trim().startsWith('```')) {
      inFence = !inFence
      continue
    }
    if (inFence) continue

    const h = /^(#{1,3})\s+(.*)$/.exec(line)
    if (h) {
      flush()
      const level = h[1].length
      const heading = stripInline(h[2])
      if (level === 1 && docTitle === slug) docTitle = heading
      current = { heading, level, anchor: slugger.slug(heading), buf: [] }
      continue
    }

    if (!line.trim() || line.trim() === '---') continue
    if (/^[-|\s:]+$/.test(line.trim())) continue // table rule row

    const clean = stripInline(line)
    if (clean && current) current.buf.push(clean)
    else if (clean && !current) {
      // preamble before the first heading — attach to a synthetic intro record
      current = { heading: docTitle, level: 1, anchor: '', buf: [clean] }
    }
  }
  flush()

  return records
}

function main() {
  if (!fs.existsSync(DOCS_DIR)) {
    console.error(`[docs-index] docs directory not found: ${DOCS_DIR}`)
    process.exit(1)
  }

  const all = []
  for (const [slug, fileName] of Object.entries(slugMap)) {
    const full = path.join(DOCS_DIR, fileName)
    if (!fs.existsSync(full)) {
      console.error(`[docs-index] missing doc file: ${full}`)
      process.exit(1)
    }
    all.push(...indexDoc(slug, fileName))
  }

  fs.mkdirSync(path.dirname(OUT_FILE), { recursive: true })
  fs.writeFileSync(OUT_FILE, JSON.stringify(all))
  const kb = (fs.statSync(OUT_FILE).size / 1024).toFixed(1)
  console.log(`[docs-index] wrote ${all.length} records → public/search-index.json (${kb} KB)`)
}

main()

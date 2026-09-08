// ─────────────────────────────────────────────────────────────────────────────
// lib/site.ts
// Canonical site origin. Set NEXT_PUBLIC_SITE_URL in the environment (Vercel
// project settings) to override the default once a custom domain is live.
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

const DEFAULT_SITE_URL = 'https://radian-alpha.vercel.app'

function resolve(): string {
  const raw = process.env.NEXT_PUBLIC_SITE_URL?.trim()
  if (!raw) return DEFAULT_SITE_URL
  // Tolerate a value with or without protocol / trailing slash.
  const withProto = /^https?:\/\//.test(raw) ? raw : `https://${raw}`
  return withProto.replace(/\/+$/, '')
}

export const SITE_URL = resolve()

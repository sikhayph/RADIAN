// ─────────────────────────────────────────────────────────────────────────────
// app/sitemap.ts
// Generated sitemap — static pages + every docs slug. Next.js serves this at
// /sitemap.xml (MetadataRoute.Sitemap).
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import type { MetadataRoute } from 'next'
import { SITE_URL } from '../lib/site'
import { getAllSlugs } from '../lib/docs'

export default function sitemap(): MetadataRoute.Sitemap {
  const now = new Date()

  const staticRoutes: {
    path: string
    priority: number
    changeFrequency: MetadataRoute.Sitemap[number]['changeFrequency']
  }[] = [
    { path: '', priority: 1, changeFrequency: 'monthly' },
    { path: '/demo', priority: 0.8, changeFrequency: 'monthly' },
    { path: '/calculator', priority: 0.8, changeFrequency: 'monthly' },
    { path: '/docs', priority: 0.7, changeFrequency: 'weekly' },
    { path: '/about', priority: 0.5, changeFrequency: 'monthly' },
  ]

  const staticEntries: MetadataRoute.Sitemap = staticRoutes.map((r) => ({
    url: `${SITE_URL}${r.path}`,
    lastModified: now,
    changeFrequency: r.changeFrequency,
    priority: r.priority,
  }))

  const docEntries: MetadataRoute.Sitemap = getAllSlugs().map((slug) => ({
    url: `${SITE_URL}/docs/${slug}`,
    lastModified: now,
    changeFrequency: 'weekly',
    priority: 0.6,
  }))

  return [...staticEntries, ...docEntries]
}

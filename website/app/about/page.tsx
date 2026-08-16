// ─────────────────────────────────────────────────────────────────────────────
// app/about/page.tsx
// Static About page — origin story, teams, three-track structure, contact
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import type { Metadata } from 'next'
import Reveal from '../../components/ui/Reveal'

export const metadata: Metadata = {
  title: 'About | RADIAN',
  description:
    'The story behind RADIAN — a Sikhay and Valiger collaboration that began as ANGGULO at the Regional Mathematics Fair 2025 and evolved into an ESP32-powered math teaching device.',
  openGraph: {
    title: 'About | RADIAN',
    description:
      'The story behind RADIAN — a Sikhay and Valiger collaboration that began as ANGGULO at the Regional Mathematics Fair 2025.',
    type: 'website',
  },
}

// ── Three-track data ──────────────────────────────────────────────────────────

const tracks = [
  {
    label:      'Firmware',
    badge:      'FW',
    desc:       'ESP32 C++ — reads a rotary encoder, computes angles, and broadcasts live BLE notifications at 20 Hz via a GATT service.',
    badgeText:  'text-[var(--primary)]',
    badgeBg:    'bg-[color-mix(in_srgb,var(--primary)_15%,transparent)]',
    delayClass: 'delay-0',
  },
  {
    label:      'App',
    badge:      'APP',
    desc:       'Flutter companion app — BLE client that connects to the device, visualizes each teaching mode in real time, and handles mode switching.',
    badgeText:  'text-[var(--arm1)]',
    badgeBg:    'bg-[color-mix(in_srgb,var(--arm1)_15%,transparent)]',
    delayClass: 'delay-100',
  },
  {
    label:      'Website',
    badge:      'WEB',
    desc:       'Next.js static site — public-facing presence, interactive browser demos, documentation, and project overview.',
    badgeText:  'text-[var(--arm2)]',
    badgeBg:    'bg-[color-mix(in_srgb,var(--arm2)_15%,transparent)]',
    delayClass: 'delay-200',
  },
]

// ── Page ─────────────────────────────────────────────────────────────────────

export default function AboutPage() {
  return (
    <main className="min-h-screen pt-16">

      {/* ── Hero / intro ──────────────────────────────────────────────────── */}
      <section className="py-[120px]">
        <div className="max-w-6xl mx-auto px-6 text-center">

          <Reveal>
            <p className="text-sm font-mono tracking-widest mb-6 uppercase text-[var(--primary)]">
              A Sikhay and Valiger Collaboration
            </p>
          </Reveal>

          <Reveal delayClass="delay-100">
            <h1 className="text-5xl lg:text-6xl font-bold leading-tight mb-6 bg-clip-text text-transparent bg-[linear-gradient(90deg,var(--primary),var(--arm1))]">
              Built to make math
              <br />
              something you feel
            </h1>
          </Reveal>

          <Reveal delayClass="delay-200">
            <p className="text-lg leading-relaxed max-w-2xl mx-auto text-[var(--muted)]">
              RADIAN is a physical-rotation teaching device that bridges the gap between abstract
              mathematical concepts and hands-on understanding. It is the result of two teams
              combining hardware intuition with software craftsmanship.
            </p>
          </Reveal>

        </div>
      </section>

      {/* ── Origin story ──────────────────────────────────────────────────── */}
      <section className="py-[120px] border-t border-[var(--border)]">
        <div className="max-w-6xl mx-auto px-6">

          <Reveal className="mb-12">
            <p className="text-sm font-mono tracking-widest mb-3 uppercase text-[var(--primary)]">
              Where It Started
            </p>
            <h2 className="text-3xl lg:text-4xl font-bold text-[var(--text)]">
              From ANGGULO to RADIAN
            </h2>
          </Reveal>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-start">

            <Reveal delayClass="delay-100">
              <p className="text-base leading-relaxed text-[var(--muted)] mb-6">
                RADIAN did not start as RADIAN. It began as{' '}
                <span className="text-[var(--text)] font-semibold">ANGGULO</span> — a
                physical-rotation device built specifically for the{' '}
                <span className="text-[var(--text)] font-semibold">
                  Regional Mathematics Fair 2025
                </span>
                . ANGGULO used the same core hardware concept: a dial that students physically
                rotate to explore angular relationships.
              </p>
              <p className="text-base leading-relaxed text-[var(--muted)]">
                The project placed{' '}
                <span className="text-[var(--text)] font-semibold">second</span> at the fair.
                That result was validation enough to keep going — not to archive it as a
                competition entry, but to evolve it into something more complete. The hardware
                stayed. The scope expanded. The name changed to RADIAN.
              </p>
            </Reveal>

            <Reveal delayClass="delay-200">
              <div className="rounded-2xl p-6 border border-[var(--border)] bg-[var(--surface)]">
                <p className="text-xs font-mono tracking-widest uppercase text-[var(--primary)] mb-4">
                  Timeline
                </p>
                <div className="space-y-5">
                  {[
                    {
                      year:  '2025',
                      label: 'ANGGULO',
                      note:  'Regional Mathematics Fair — 2nd place',
                    },
                    {
                      year:  '2025+',
                      label: 'Renamed to RADIAN',
                      note:  'Scope expanded to firmware, app, and website',
                    },
                    {
                      year:  'Now',
                      label: 'Active development',
                      note:  'ESP32 BLE + Flutter + Next.js — three parallel tracks',
                    },
                  ].map((item) => (
                    <div key={item.year} className="flex gap-4">
                      <span className="text-xs font-mono text-[var(--primary)] w-14 flex-shrink-0 pt-0.5">
                        {item.year}
                      </span>
                      <div>
                        <p className="text-sm font-semibold text-[var(--text)]">{item.label}</p>
                        <p className="text-xs text-[var(--muted)] mt-0.5">{item.note}</p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </Reveal>

          </div>
        </div>
      </section>

      {/* ── Sikhay and Valiger ────────────────────────────────────────────── */}
      <section className="py-[120px] border-t border-[var(--border)]">
        <div className="max-w-6xl mx-auto px-6">

          <Reveal className="text-center mb-12">
            <p className="text-sm font-mono tracking-widest mb-3 uppercase text-[var(--primary)]">
              The People Behind It
            </p>
            <h2 className="text-3xl lg:text-4xl font-bold text-[var(--text)]">
              Sikhay and Valiger
            </h2>
          </Reveal>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">

            <Reveal delayClass="delay-0" className="h-full">
              <div className="h-full rounded-2xl p-6 border border-[var(--border)] bg-[var(--surface)] transition-all duration-500 ease-premium hover:-translate-y-1 hover:border-[var(--primary)] hover:shadow-[0_0_40px_-8px_var(--primary)]">
                <p className="text-xs font-mono tracking-widest uppercase text-[var(--primary)] mb-3">
                  Sikhay
                </p>
                <h3 className="text-xl font-semibold text-[var(--text)] mb-3">
                  Hardware and education context
                </h3>
                <p className="text-sm leading-relaxed text-[var(--muted)]">
                  Sikhay brings the hardware and education-context perspective — grounding the
                  project in how math is actually taught and where physical tools create the most
                  meaningful learning impact. Their work on ANGGULO gave RADIAN its physical
                  foundation.
                </p>
              </div>
            </Reveal>

            <Reveal delayClass="delay-100" className="h-full">
              <div className="h-full rounded-2xl p-6 border border-[var(--border)] bg-[var(--surface)] transition-all duration-500 ease-premium hover:-translate-y-1 hover:border-[var(--primary)] hover:shadow-[0_0_40px_-8px_var(--primary)]">
                <p className="text-xs font-mono tracking-widest uppercase text-[var(--arm1)] mb-3">
                  Valiger
                </p>
                <h3 className="text-xl font-semibold text-[var(--text)] mb-3">
                  Software and engineering
                </h3>
                <p className="text-sm leading-relaxed text-[var(--muted)]">
                  Valiger drives the software and engineering side — firmware architecture, BLE
                  protocol design, the Flutter companion app, and this website. Their focus is on
                  making the hardware&apos;s output precise, accessible, and well-documented.
                </p>
              </div>
            </Reveal>

          </div>
        </div>
      </section>

      {/* ── Three parallel tracks ─────────────────────────────────────────── */}
      <section className="py-[120px] border-t border-[var(--border)]">
        <div className="max-w-6xl mx-auto px-6">

          <Reveal className="text-center mb-12">
            <p className="text-sm font-mono tracking-widest mb-3 uppercase text-[var(--primary)]">
              How It&apos;s Built
            </p>
            <h2 className="text-3xl lg:text-4xl font-bold text-[var(--text)]">
              Three parallel tracks
            </h2>
          </Reveal>

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-6">
            {tracks.map((track) => (
              <Reveal key={track.label} delayClass={track.delayClass} className="h-full">
                <div className="h-full rounded-2xl p-6 border border-[var(--border)] bg-[var(--surface)] transition-all duration-500 ease-premium hover:-translate-y-1 hover:border-[var(--primary)] hover:shadow-[0_0_40px_-8px_var(--primary)]">
                  <div className="flex items-center gap-3 mb-3">
                    <span
                      className={`px-2 py-0.5 rounded-md text-xs font-bold font-mono flex-shrink-0 ${track.badgeBg} ${track.badgeText}`}
                    >
                      {track.badge}
                    </span>
                    <h3 className="text-lg font-semibold text-[var(--text)]">
                      {track.label}
                    </h3>
                  </div>
                  <p className="text-sm leading-relaxed text-[var(--muted)]">
                    {track.desc}
                  </p>
                </div>
              </Reveal>
            ))}
          </div>

        </div>
      </section>

      {/* ── Contact ───────────────────────────────────────────────────────── */}
      <section className="py-[120px] border-t border-[var(--border)]">
        <div className="max-w-6xl mx-auto px-6 text-center">

          <Reveal>
            <p className="text-sm font-mono tracking-widest mb-3 uppercase text-[var(--primary)]">
              Get Involved
            </p>
          </Reveal>

          <Reveal delayClass="delay-100">
            <h2 className="text-3xl lg:text-4xl font-bold mb-4 text-[var(--text)]">
              Interested in collaborating?
            </h2>
          </Reveal>

          <Reveal delayClass="delay-200">
            <p className="text-base leading-relaxed mb-8 max-w-xl mx-auto text-[var(--muted)]">
              RADIAN is open source and actively developed. Whether you have hardware suggestions,
              educational feedback, or want to contribute to the firmware, app, or website —
              reach out via GitHub.
            </p>
          </Reveal>

          <Reveal delayClass="delay-300">
            <a
              href="https://github.com/sikhayph/RADIAN"
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-2 px-8 py-3.5 rounded-xl font-semibold text-sm border no-underline border-[var(--border)] text-[var(--text)] bg-transparent transition-opacity duration-300 ease-premium hover:opacity-85"
            >
              <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z" />
              </svg>
              Reach out via GitHub
            </a>
          </Reveal>

        </div>
      </section>

    </main>
  )
}

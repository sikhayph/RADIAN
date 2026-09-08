// ─────────────────────────────────────────────────────────────────────────────
// components/ui/WaitlistSection.tsx
// Homepage section — one idea: the v1 hardware is coming, join the waitlist.
// Sits below ModeShowcase on the landing page.
// Sikhay and Valiger Collaboration
// ─────────────────────────────────────────────────────────────────────────────

import Reveal from './Reveal'
import WaitlistForm from './WaitlistForm'

export default function WaitlistSection() {
  return (
    <section className="py-[120px] border-t border-[var(--border)]">
      <div className="max-w-6xl mx-auto px-6 text-center">
        <Reveal>
          <p className="text-sm font-mono tracking-widest mb-3 uppercase text-[var(--primary)]">
            RADIAN v1
          </p>
        </Reveal>

        <Reveal delayClass="delay-100">
          <h2 className="text-3xl lg:text-4xl font-bold mb-4 text-[var(--text)]">
            Be first when the hardware ships
          </h2>
        </Reveal>

        <Reveal delayClass="delay-200">
          <p className="text-base leading-relaxed mb-8 max-w-xl mx-auto text-[var(--muted)]">
            The interactive canvas demos and classroom units are available with the
            v1 hardware release. Leave your email and we&apos;ll let you know the
            moment it&apos;s ready — no newsletter, just the one announcement.
          </p>
        </Reveal>

        <Reveal delayClass="delay-300">
          <WaitlistForm />
        </Reveal>
      </div>
    </section>
  )
}

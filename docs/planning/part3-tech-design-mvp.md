# Technical Design Document: Radian MVP

**Status:** Draft — proposed design, awaiting your review before Part 4 build
**Built from:** Part 2 PRD (complete) + fixed constraints from Part 1's research request
**Important caveat:** Part 1 was a *research request*, not completed research — it contains no findings, no cited competitor data, and no verified cost figures. This document does not pretend otherwise. Where I state something as fact, it's cited. Where I'm making an engineering call because the PRD left it open, it's labeled as a **Decision**. Where I genuinely don't know and you need to find out, it's labeled **Open Question**.

---

## 1. Fixed Constraints (from Part 1 / PRD, not up for debate here)

- Microcontroller: ESP32 (fixed)
- Companion app: Flutter (fixed)
- Device-to-app sync: BLE (fixed)
- Hardware base: existing ANGGULO dual-arm rotary encoder prototype (fixed — reuse, don't redesign)
- Budget: ~₱4,000 estimate, not a hard ceiling (PRD)
- Timeline: Q4 2026 demo (PRD)
- Scope: unit circle only, one classroom, no accounts (PRD)

---

## 2. Device Architecture

### 2.1 What's verified vs. what's a decision

I did not re-research ESP32 component selection from scratch, because your device already exists (ANGGULO) and the PRD says to build on it, not rebuild it. What I *can* verify is general ESP32 cost context, so your budget line isn't a guess pulled from nowhere:

- Bare ESP32 dev boards (ESP32-WROOM-32 based "DevKit V1" boards, the most common variant with the widest tutorial/library support) typically run **roughly $4–5 retail**, with bulk/AliExpress pricing lower.<cite index="9-1">The dual-core 240 MHz processor with WiFi, Bluetooth, and plenty of GPIO pins typically costs under five dollars, and it's the board most tutorials and examples are written for</cite> (ComponentIndex, dated March 2026). A separate source similarly found boards in the **$3.89–$7.99** range depending on seller and extras.<cite index="5-1">Prices on AliExpress ranged from $3.50 to $7.99 across three units purchased from different sellers, all functioning identically after flashing</cite>
- Smaller/cheaper variants (ESP32-C3) run **~$2–4**, but drop dual-core performance and some GPIO — **not recommended** for Radian, since a dual-arm encoder + OLED + BLE workload benefits from dual-core headroom.

**This is background cost context only.** It does not tell us what ANGGULO's actual BOM (encoders, OLED model, power system, enclosure) costs today — I have no verified figure for that, and I'm not going to invent one. **Open Question:** what is ANGGULO's current actual per-unit BOM cost? You likely already know this from having built it — if not, that's the first number to pin down before locking the ₱4,000 estimate.

### 2.2 Design Decisions

- **Decision:** Keep ANGGULO's existing mechanical/electronic architecture unchanged for the MVP. The PRD explicitly scopes Radian as ANGGULO-based, and the IPOPHL filing-consistency question (see §6) means changing the physical mechanism now is risky before that's resolved.
- **Decision:** Firmware should expose angle/position data over BLE using a single custom GATT service with one or two characteristics (e.g., `angle_notify` for live position, `device_status` for connection/battery state), using BLE **notify** (not read-polling) so the Flutter app receives push updates as the arm moves. This is a standard BLE pattern for live sensor mirroring and doesn't require new research to justify — it's the default approach for this exact use case (continuous small-payload streaming to a subscribed client).
- **Decision:** Angle data payload should be small and simple (e.g., 2–4 bytes: angle in degrees or radians as a scaled integer, plus a sequence number for dropped-packet detection) rather than JSON-over-BLE, to keep latency low and firmware simple.

### 2.3 Open Questions (device)

- Current ANGGULO BOM cost (see above)
- Whether the OLED on ANGGULO is still needed once the phone becomes the primary display surface, or whether it's kept as a teacher-facing readout — **PRD doesn't say**, worth deciding since it affects firmware scope
- Battery/power behavior during a live classroom demo (continuous BLE broadcast draws more power than idle) — no runtime target has been set

---

## 3. Flutter App Architecture

### 3.1 BLE library choice

I checked current (2026) guidance on Flutter BLE libraries rather than relying on older training knowledge, since this ecosystem changes:

- **flutter_blue_plus** is the actively maintained successor to the now-abandoned `flutter_blue`. <cite index="12-1">flutter_blue_plus has broader iOS support, Android 12+ support, MTU negotiation, and active bug fixes that flutter_blue never received, while the original flutter_blue is deprecated and unmaintained as of 2026</cite>
- Comparing it to the main alternative: <cite index="11-1">between flutter_blue_plus and flutter_reactive_ble, flutter_blue_plus has stronger community adoption and more active maintenance, though both offer similar feature sets</cite>
- A third source frames the tradeoff similarly: <cite index="14-1">flutter_blue_plus hides most of the platform-specific BLE pain while giving full control over scanning, connecting, and exchanging data, and is the most commonly recommended package for this kind of central-role BLE app</cite>, with `flutter_reactive_ble` as a reasonable alternative for teams that prefer a stream-composition style.

**Decision:** Use **flutter_blue_plus**. It's the better-supported default choice for a small team on a Q4 deadline, and the sourced comparisons above consistently favor it for this kind of straightforward central/scan-connect-subscribe use case.

### 3.2 App structure

**Decision (screen flow, per PRD's defined MVP scope):**
1. **Connect/Pairing screen** — scan for Radian device, connect over BLE
2. **Live Sync/Demo screen** — subscribes to the `angle_notify` characteristic, renders the unit circle visualization updating in real time
3. **Quiz screen** — short interactive quiz, launched from the demo screen
4. **Results screen** — shows quiz outcome

**Decision (state management):** Given a 2nd-year solo/small-team build on a tight timeline, use Flutter's built-in `Provider` or `Riverpod` (either is fine; Riverpod is more current best practice but has a slightly steeper learning curve) rather than introducing BLoC or a heavier architecture. This is a scope call, not a researched benchmark — for an app this size (4 screens, one BLE stream, one quiz), the state management choice is low-stakes engineering, not something that needs deep research.

**Decision (offline/online behavior):** Per PRD, the app's core loop *requires* an active BLE connection to the device — there's no meaningful "offline mode" for the live-sync screen in MVP scope (this matches the PRD's explicit deferral of offline mode to v2). The quiz screen, however, has no reason to require BLE once launched, so it should not break if BLE disconnects mid-quiz.

### 3.3 BLE sync latency

The PRD flagged this as an unresolved target ("*specific target not yet defined*"). I don't have a verified benchmark specific to your firmware/payload, so I won't invent a number like "50ms." What I can say generally: BLE notify-based updates for small payloads (a few bytes) typically feel "live" to a human observer well within the range of typical BLE connection intervals, which are commonly configured between roughly 15ms–100ms depending on power/latency tradeoffs — but the *actual* number depends on your specific connection parameters, phone hardware, and firmware polling rate.

**Open Question, needs a decision from you or an empirical test:** Set a concrete target (e.g., "visually imperceptible lag during arm rotation, tested in a real classroom-distance BLE connection") and **test it empirically** with the actual ANGGULO hardware once BLE notify is wired up, rather than trusting an unverified spec number.

---

## 4. Website Architecture

The PRD left this fully open. Given the MVP explicitly does **not** require live device sync on the website (that's deferred to v2 — "*Website launches as a standalone app-mirror first*"), this significantly narrows the real decision:

**Decision:** Build the website as a **static, standalone site** (no backend, no database, no accounts) that reimplements the same unit-circle visualization and quiz logic as the Flutter app, using plain HTML/CSS/JS or a lightweight framework (e.g., a simple React or Svelte build) — whichever your team is more comfortable shipping fast in, since there's no functional requirement forcing a specific framework. No BLE-in-browser is needed since Web Bluetooth support is inconsistent across browsers and out of scope per PRD anyway.

**Why this resolves cleanly:** because there's no live sync requirement in MVP, there's no backend, no real-time channel (WebSocket/SSE), and no data-sync question to solve yet. Those become real architecture decisions only when v2 adds live device↔website sync, teacher accounts, or analytics — at which point this document should be revisited.

**Open Question:** Hosting platform (Vercel, Netlify, GitHub Pages, Firebase Hosting are all reasonable free-tier options for a static site) — no strong technical reason to pick one over another for MVP scope; pick based on what your team already has an account/familiarity with.

---

## 5. Security, Privacy, Accessibility

The PRD flagged all three as undefined. Given the actual MVP scope (no accounts, no student data collection, single classroom demo), the real surface area is small:

- **Privacy:** Decision — since there are no accounts and no personal data collected (quiz results aren't tied to identifiable students in MVP scope per PRD), there's minimal privacy surface right now. This should be revisited the moment v2 adds teacher accounts or student analytics, since that's when actual student data handling begins.
- **Security:** Decision — BLE pairing should not use "Just Works" with no confirmation if avoidable, to reduce the chance of an unrelated phone accidentally connecting mid-demo; a simple confirmation step (e.g., matching a code shown on the OLED, if kept) is a reasonable low-effort safeguard. This is a general BLE hygiene practice, not a researched requirement — flag as something to actually implement, not skip.
- **Accessibility:** Open Question — the PRD's Quality Standards section explicitly says "ignoring basic accessibility on the app and website" is unacceptable, but no concrete accessibility target (WCAG level, screen reader support, colorblind-safe palette for the unit circle visualization) has been set. Given "playful, colorful" is the stated design vibe, colorblind-safe color choices for the unit circle visualization are worth deciding now rather than retrofitting later.

---

## 6. IP / IPOPHL Filing Consideration

The PRD flagged this as unresolved: **whether Radian's use of the ANGGULO mechanism needs to stay consistent with what's already filed, or is free to evolve independently.**

I have **not** run a patent/prior-art search — that requires a proper IPOPHL database search, which is outside what I can verify here, and I won't claim "no prior art exists" as if it's confirmed (the PRD already correctly flags this as unverified).

**This is the single highest-priority open question in the whole document**, because §2.2's decision to keep ANGGULO's architecture unchanged is only safe if it's *also* what the filing requires. If the filing is narrow/specific about the mechanism and Radian deviates even slightly, that could be a problem; if the filing is broad, you likely have more freedom than assumed. **Recommend resolving this with Ms. De Asis or whoever is handling the filing before writing firmware that assumes either answer.**

---

## 7. Summary Table — What's Resolved vs. Still Open

| Area | Status |
|---|---|
| Device hardware base | Resolved — reuse ANGGULO as-is (Decision) |
| BLE data contract | Resolved — GATT notify, small payload (Decision) |
| Flutter BLE library | Resolved — flutter_blue_plus (sourced) |
| App screen flow / state mgmt | Resolved (Decision) |
| Website stack | Resolved — static site, no backend needed for MVP (Decision) |
| BLE sync latency target | **Open — needs empirical test + a number you set** |
| ANGGULO current BOM cost | **Open — you likely know this, not yet in these docs** |
| IPOPHL filing scope vs. Radian design freedom | **Open — highest priority, resolve before Part 4 build starts** |
| Accessibility target (WCAG level, color palette) | **Open** |
| Website hosting platform | Open, low-stakes |

---

*Document created: 2026-08-09*
*Sources for cited claims: ComponentIndex (Mar 2026), AliExpress cost breakdowns, BLE Flutter Course (Apr 2026), Bluetooth Developer Academy (Feb 2026), freeCodeCamp BLE handbook — all fetched live during this session, not from training memory.*
*Everything not cited above is either an explicit design decision made to unblock Part 4, or an explicitly flagged open question — not a researched or verified fact.*

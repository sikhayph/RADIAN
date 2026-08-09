# Product Requirements

*Extracted from Part 2 PRD — see `docs/PRD-Radian-MVP.md` for full document.*

## Primary User Story (exact text)

> "A math teacher is explaining the unit circle, and mid-lesson notices students are lost — they can't visualize how the angle sweeps around the circle relate to sine/cosine values. The teacher pulls out Radian and demonstrates the concept physically on the device. Students then pull out their phones, open the Radian app, and interact with the same concept themselves — synced live with what's happening on the device — before taking a short interactive quiz to check their understanding."

## Must-Have Features (P0, exact list)

1. **Device-Side Unit Circle Demo** — teacher manipulates the physical dual-arm mechanism to demonstrate the unit circle in real time
   - Success criteria: device accurately tracks/displays angle position; transmits real-time angle/position data over BLE
2. **Flutter App — Unit Circle Module with Live BLE Sync** — app mirrors the device's demo live on the student's phone
   - Success criteria: pairs over BLE; visualization updates in real time; sync latency feels "live" (no numeric target set yet)
3. **In-App Interactive Quiz** — short quiz testing understanding, accessible from the same session as the live demo
   - Success criteria: quiz completable within the app session; students see results
4. **Companion Website (App-Parity, Standalone)** — mirrors app's module and quiz, no live BLE sync required in MVP
   - Success criteria: standalone interactive module matching app content; same quiz hosted

## Nice-to-Have Features

*None defined — all additional scope explicitly deferred to v2.*

## NOT in MVP (exact list, deferred to v2)

- Additional subjects/concepts (torque, trig identities, etc.)
- Full real-time website ↔ device sync
- Teacher accounts / class management
- Student progress tracking / analytics dashboard
- Multiplayer / classroom-wide quiz leaderboard
- Offline mode
- Content authoring tools

## Success Metrics

| Metric | Target | Measure |
|---|---|---|
| Teacher/student feedback score | Not yet defined | Post-demo survey or verbal feedback |
| Quiz completion rate | Not yet defined | % of students completing quiz after demo |
| BLE sync success rate | No dropouts/lag during live demo | Observed during demo session |

## UI/UX Requirements

**Design vibe:** Playful, colorful.

**Visual principles:**
1. Bright, energetic colors that keep student attention
2. Simple, approachable visuals that don't compete with the math concept for attention
3. Visual consistency across device, app, and website

**Key screens:**
1. App — Live Sync/Demo Screen
2. App — Quiz Screen
3. Website — Module Page
4. Website — Quiz Page

## Timeline & Constraints

- **Target demo:** Q4 2026
- **Development budget:** ~₱4,000 estimate (not a hard ceiling), leveraging existing ANGGULO hardware rather than building new hardware from scratch
- **Scope:** One classroom, one teacher demo — not built for scale at this stage

## Definition of Done for MVP (from PRD)

- [ ] Device reliably demonstrates the unit circle concept via the dual-arm mechanism
- [ ] App pairs with device over BLE, mirrors demo live with no perceptible dropouts/lag
- [ ] App's in-app quiz is functional and gives students results
- [ ] Website hosts a standalone version of the same module and quiz
- [ ] One complete demo run-through (device → app → quiz) tested end-to-end
- [ ] Basic feedback collection method in place for the actual demo

# Product Requirements Document: Radian MVP

## Product Overview

**App Name:** Radian
**Tagline:** A hands-on way for teachers to make hard concepts click.
**Launch Goal:** A working prototype demo
**Target Launch:** Q4 2026

## Who It's For

### Primary User: The High-School Teacher
A high-school math or science teacher who regularly has to explain abstract concepts (like the unit circle) to a room of students who can't quite visualize what's happening. They've already taught the lesson through normal means (board, slides, textbook) but can see some students are still lost.

**Their Current Pain:**
- Lack of visualization tools for abstract math/physics concepts
- No easy way to re-explain a concept hands-on once the initial lesson hasn't landed
- Limited options beyond static diagrams or whiteboard sketches mid-class

**What They Need:**
- A physical, hands-on tool they can pull out mid-lesson to re-demonstrate a concept
- A simple way to hand the same concept off to students individually (via their phones)
- Something that reinforces understanding without requiring a full re-teach

### Secondary User: The Student
High-school students following along in class, comfortable using their own phones. They watch the teacher's live demo, then interact with the same concept themselves through the Radian app and take a short quiz to check their understanding.

### Example User Story
"A math teacher is explaining the unit circle, and mid-lesson notices students are lost — they can't visualize how the angle sweeps around the circle relate to sine/cosine values. The teacher pulls out Radian and demonstrates the concept physically on the device. Students then pull out their phones, open the Radian app, and interact with the same concept themselves — synced live with what's happening on the device — before taking a short interactive quiz to check their understanding."

## The Problem We're Solving

Teachers of abstract subjects like trigonometry often run into a wall: a concept like the unit circle is inherently spatial and dynamic, but most classroom tools (whiteboards, static slides, textbook diagrams) are flat and fixed. When a lesson doesn't land, teachers rarely have a good hands-on fallback mid-class — re-explaining verbally or re-drawing the same diagram often doesn't fix the visualization gap.

Radian gives teachers a physical, manipulable device to re-demonstrate the concept in the moment, and immediately extends that demonstration to each student's own phone so they can interact with it individually and test their understanding right away.

*Note: We have not conducted a competitor landscape review as part of this PRD process. Any claims about how existing tools (physical manipulatives, classroom software, etc.) fall short would need to be researched separately before being stated as fact — this section reflects the problem as you've described it, not a verified market gap.*

## User Journey

### Discovery → First Use → Success

1. **Discovery Phase**
   - How they find us: *Open question — not yet defined (likely school/community demo, MATHusay or Sikhay network, or a competition/showcase given the Q4 2026 target)*
   - What catches their attention: The physical device itself and its live sync with students' phones
   - Decision trigger: Seeing the unit circle demo work smoothly in a real classroom moment

2. **Onboarding (First 5 Minutes)**
   - Land on: Teacher operates the physical Radian device directly (no app setup required to start the demo)
   - First action: Teacher manipulates the dual-arm mechanism to show the unit circle concept
   - Quick win: Students immediately see the concept respond to physical manipulation

3. **Core Usage Loop**
   - Trigger: Teacher notices students are lost on a concept mid-lesson
   - Action: Teacher demos on Radian; students open the app and follow along via live BLE sync
   - Reward: Students interact with the same concept on their own phone
   - Investment: Students complete the in-app quiz to confirm understanding

4. **Success Moment**
   - "Aha!" moment: When a student's phone view updates live in sync with the teacher's physical manipulation of the device
   - Share trigger: *Open question — not yet defined*

## MVP Features

### Must Have for Launch

#### 1. Device-Side Unit Circle Demo
- **What:** The physical Radian device (built on the existing ANGGULO dual-arm encoder prototype) lets the teacher manipulate an arm/angle to demonstrate the unit circle concept in real time.
- **User Story:** As a teacher, I want to physically manipulate the device to show how angle relates to the unit circle, so that students can see the concept in motion instead of a static diagram.
- **Success Criteria:**
  - [ ] Device accurately tracks and displays angle position via the dual-arm mechanism
  - [ ] Device transmits real-time angle/position data over BLE
- **Priority:** P0 (Critical)

#### 2. Flutter App — Unit Circle Module with Live BLE Sync
- **What:** A companion Flutter app that connects to the Radian device over BLE and mirrors the device's unit circle demonstration live on the student's phone.
- **User Story:** As a student, I want to see the teacher's device demo reflected live on my own phone, so that I can follow along individually and explore it myself.
- **Success Criteria:**
  - [ ] App successfully pairs with the Radian device over BLE
  - [ ] App displays the unit circle visualization updating in real time as the device is manipulated
  - [ ] Sync latency is low enough to feel "live" during a classroom demo (*specific target not yet defined — flag for Part 3*)
- **Priority:** P0 (Critical)

#### 3. In-App Interactive Quiz
- **What:** A short interactive quiz within the Flutter app testing understanding of the unit circle concept just demonstrated.
- **User Story:** As a student, I want to test my understanding right after the demo, so that I know if the concept actually clicked.
- **Success Criteria:**
  - [ ] Quiz is accessible from within the same app session as the live demo
  - [ ] Students can complete the quiz and see their results
- **Priority:** P0 (Critical)

#### 4. Companion Website (App-Parity, Standalone)
- **What:** A website that mirrors the app's unit circle module and quiz content, usable independently of the physical device (no live BLE sync required for MVP).
- **User Story:** As a student or teacher, I want to access the same interactive unit circle module and quiz from a browser, so that I'm not limited to only using the mobile app.
- **Success Criteria:**
  - [ ] Website hosts a standalone interactive unit circle module matching the app's content
  - [ ] Website hosts the same quiz as the app
- **Priority:** P0 (Critical)

### Nice to Have (If Time Allows)
- *None currently defined — all additional scope has been explicitly deferred to v2 (see below).*

### NOT in MVP (Saving for Later)
- **Additional subjects/concepts** (e.g., torque, trigonometric identities): Will add after the unit circle demo is proven
- **Full real-time website ↔ device sync**: Website launches as a standalone app-mirror first; live device sync added later
- **Teacher accounts / class management** (rosters, saved sessions, per-class analytics): Will add after initial demo validates the core concept
- **Student progress tracking / analytics dashboard**: Will add after initial demo validates the core concept
- **Multiplayer / classroom-wide quiz leaderboard**: Will add after initial demo validates the core concept
- **Offline mode** (app/website without BLE or internet): Will add after initial demo validates the core concept
- **Content authoring tools** (teachers building their own modules): Will add after initial demo validates the core concept

*Why we're waiting: Keeps the MVP focused on proving one strong example (the unit circle) end-to-end — device, app, and website — before expanding subject coverage or adding classroom-management features.*

## How We'll Know It's Working

### Demo Success Metrics
| Metric | Target | Measure |
|--------|--------|---------|
| Teacher/student feedback score | *Not yet defined* | Post-demo survey or verbal feedback |
| Quiz completion rate | *Not yet defined* | % of students who complete the quiz after the demo |
| BLE sync success rate | No dropouts/lag during live demo | Observed during the demo session |

*Specific numeric targets for feedback score and completion rate haven't been set yet — flagged here as open items rather than invented numbers.*

## Look & Feel

**Design Vibe:** Playful, colorful

**Visual Principles:**
1. Bright, energetic colors that keep student attention during the demo
2. Simple, approachable visuals that don't compete with the underlying math concept for attention
3. Consistency in visual language between the physical device, app, and website so it reads as one product

**Key Screens/Pages:**
1. **App — Live Sync/Demo Screen**: Displays the unit circle visualization mirroring the device in real time
2. **App — Quiz Screen**: Interactive quiz testing understanding of the unit circle
3. **Website — Module Page**: Standalone version of the unit circle interactive module
4. **Website — Quiz Page**: Standalone version of the same quiz

### Simple Wireframe
```
[App: Live Sync/Demo Screen]
┌─────────────────────────┐
│   Radian [BLE Status]   │
├─────────────────────────┤
│                         │
│   [Unit Circle Visual]  │
│   (mirrors device live) │
│                         │
├─────────────────────────┤
│      [Take Quiz →]      │
└─────────────────────────┘
```

## Technical Considerations

**Platform:** ESP32 device (hardware, fixed) + Flutter app (fixed) + website (stack open)
**Sync:** BLE between device and app (live); website is standalone, no live device sync in MVP
**Responsive:** Website should be usable on both desktop and mobile browsers (*specific responsive requirements not yet defined*)
**Performance:** BLE sync should feel "live" with no perceptible dropouts/lag during the demo (*specific latency target not yet defined — for Part 3*)
**Accessibility:** *Not yet defined — recommend addressing in Part 3*
**Security/Privacy:** *Not yet defined — no student/teacher accounts in MVP scope, which reduces immediate data-privacy surface area, but this should still be confirmed in Part 3*
**Scalability:** Not a current concern at demo stage — single device, single classroom use case

## Quality Standards

**What This App Will NOT Accept:**
- Placeholder content in production ("Lorem ipsum", sample images)
- Broken features — everything listed works or isn't included
- Skipping testing of the BLE live-sync path before the demo
- Ignoring basic accessibility on the app and website

*These standards will be enforced by the AI coding assistant during Part 3/4.*

## Budget & Constraints

**Development Budget:** ~₱4,000 (estimate, not a hard ceiling), leveraging the existing ANGGULO-based hardware prototype as the base rather than building new hardware from scratch
**Monthly Operating:** *Not yet estimated*
**Timeline:** Demo target — Q4 2026
**Team:** Sikhay Research and Prototyping (co-founder: Enrique; prior ANGGULO collaboration with Maravilla and coach Ms. De Asis — team composition for Radian specifically not yet confirmed)

## Open Questions & Assumptions

- **Website tech stack** — intentionally left open, to be resolved in Part 3 (Technical Design Document)
- **ANGGULO utility model filing consistency** — unresolved: it's not yet confirmed whether Radian's dual-arm mechanism needs to stay consistent with what's already filed for ANGGULO, or whether it's free to evolve independently. This should be clarified before Part 3 locks in hardware architecture decisions.
- **No prior art/competing patents identified** — per your team's current understanding. This has not been independently verified (no patent database search was conducted as part of this PRD process) and should not be treated as confirmed.
- **Discovery/distribution channel** for the demo (school, competition, showcase) — not yet defined
- **Specific numeric targets** for feedback score and quiz completion rate — not yet defined
- **BLE sync latency target** — not yet defined
- **Accessibility, security/privacy, and responsive design requirements** — not yet defined, flagged for Part 3

## Launch Strategy (Brief)

**Soft Launch:** *Not yet defined*
**Target Users:** One classroom / one teacher demo, per current scope
**Feedback Plan:** Post-demo feedback from teacher and students (method not yet defined — survey, verbal, etc.)
**Iteration Cycle:** *Not yet defined*

## Definition of Done for MVP

The MVP is ready to demo when:
- [ ] Device reliably demonstrates the unit circle concept via the dual-arm mechanism
- [ ] App pairs with the device over BLE and mirrors the demo live with no perceptible dropouts/lag
- [ ] App's in-app quiz is functional and gives students results
- [ ] Website hosts a standalone version of the same module and quiz
- [ ] One complete demo run-through (device → app → quiz) has been tested end-to-end
- [ ] Basic feedback collection method is in place for the actual demo

## Next Steps

After this PRD is approved:
1. Resolve open questions (website stack, ANGGULO filing consistency, sync latency target)
2. Create Technical Design Document (Part 3)
3. Set up development environment
4. Build MVP with AI assistance
5. Run the demo

---
*Document created: 2026-08-07*
*Status: Draft — Ready for Technical Design*
*Note: This PRD was built from the requester's direct input during this session. No external market, competitor, or technical research was conducted or cited as part of generating this document — the Part 1 file provided was a research request/prompt, not completed findings. Any figures or claims not attributed to the requester in this document should be treated as open/unverified.*

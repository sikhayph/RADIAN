# RADIAN — Session Handoff Document
> **Date:** August 11, 2026  
> **Prepared by:** Henry Gabriel Buban — Sikhay  
> **For:** Next Claude Code session  
> **Repository:** https://github.com/sikhayph/RADIAN  
> **Website worktree:** C:\Users\Henry Gabriel\Downloads\radian-website-wt

---

## Current Branch States

| Branch | State | Notes |
|---|---|---|
| `main` | Stable | README, SETUP.md, CONTRIBUTING.md |
| `dev` | Up to date | All app screens merged August 11 |
| `feature/app-ble-manager` | Active | All 4 modes complete + packet_provider fix |
| `feature/website-landing` | Active | Premium UI upgrade done |
| `feature/firmware-mode1-degrad` | Merged to dev | Firmware v0.1 complete |

---

## What Is Complete

### Firmware (`firmware/`)
All files written, build passing (PlatformIO). Not yet flashed — no ESP32 hardware.

```
firmware/
├── include/config.h              — all constants, BLE UUIDs, pin definitions
├── src/
│   ├── main.cpp                  — setup() + 20Hz loop
│   ├── ble/
│   │   ├── BLEService.cpp        — NimBLE GATT server, JSON notify
│   │   └── BLEService.h
│   ├── modes/
│   │   ├── ModeManager.cpp       — mode switching, payload builder
│   │   ├── ModeManager.h
│   │   ├── Mode1_DegRad.cpp      — degree/radian compute
│   │   ├── Mode1_DegRad.h
│   │   ├── Mode2_VectorAdd.cpp   — vector addition compute
│   │   ├── Mode2_VectorAdd.h
│   │   ├── Mode3_RotMatrix.cpp   — rotation matrix compute
│   │   ├── Mode3_RotMatrix.h
│   │   ├── Mode4_PolygonSnap.cpp — polygon snap compute
│   │   └── Mode4_PolygonSnap.h
│   └── sensors/
│       ├── EncoderA.cpp          — AS5600 arm 1 (0x36)
│       ├── EncoderA.h
│       ├── EncoderB.cpp          — AS5600 arm 2 (0x37)
│       └── EncoderB.h
└── platformio.ini
```

**BLE payload (locked v1.0):**
```json
{
  "mode": 1, "a1": 47.3, "a2": 112.8,
  "val": { "rad": 0.825, "rx": 0.682, "ry": 0.731,
           "rmag": 1.41, "rang": 80.05,
           "snap": 6, "int": 120.0, "ext": 60.0 },
  "ts": 1720863600
}
```

---

### Flutter App (`app/`)
All screens and painters complete on `feature/app-ble-manager`.

```
app/lib/
├── main.dart                          — 7 routes, no placeholders
├── app_theme.dart                     — 3 ThemeData (Obsidian, Chalk, Sikhay)
│                                        + RadianCanvasTheme extension
├── ble/
│   ├── ble_manager.dart               — BLE scan, connect, notify stream
│   └── radian_packet.dart             — JSON → RadianPacket model
├── providers/
│   ├── scan_provider.dart             — scanResultsProvider, bleStateProvider, ScanNotifier
│   ├── packet_provider.dart           — lastPacketProvider (StreamProvider)
│   ├── theme_provider.dart            — themeProvider (StateProvider)
│   └── providers.dart                 — barrel export
├── screens/
│   ├── scan_screen.dart               — BLE discovery, auto-scan, connect
│   ├── home_screen.dart               — mode grid, live readout, responsive
│   ├── settings_screen.dart           — theme picker, nickname, disconnect
│   ├── mode1_screen.dart              — unit circle visualizer
│   ├── mode2_screen.dart              — vector addition visualizer
│   ├── mode3_screen.dart              — rotation matrix visualizer
│   └── mode4_screen.dart              — polygon snap visualizer
└── widgets/painters/
    ├── unit_circle_painter.dart        — unit circle, arc, projections, glow
    ├── vector_diagram_painter.dart     — two vectors, resultant, parallelogram
    ├── rotation_matrix_painter.dart    — original+transformed vector, ghost trail
    └── polygon_painter.dart           — N-gon, central angle wedge, interior arcs
```

**pubspec.yaml dependencies:**
```yaml
flutter_blue_plus: ^1.31.0
riverpod: ^2.5.1
flutter_riverpod: ^2.5.1
go_router: ^13.2.0
fl_chart: ^0.68.0
hive_flutter: ^1.1.0
```

**Routes in main.dart:**
```dart
/           → ScanScreen
/home       → HomeScreen
/mode/1     → Mode1Screen
/mode/2     → Mode2Screen
/mode/3     → Mode3Screen
/mode/4     → Mode4Screen
/settings   → SettingsScreen
```

---

### Website (`website/` — on feature/website-landing)

**Tech stack:** Next.js 14.2.5, TypeScript, Tailwind CSS, Framer Motion

```
website/
├── app/
│   ├── layout.tsx          — root layout, Navbar, metadata
│   ├── page.tsx            — Hero + ModeShowcase
│   ├── globals.css         — CSS custom properties for all 3 themes
│   └── (docs/, demo/, about/ — being built by agents tonight)
├── components/
│   ├── ui/
│   │   ├── Navbar.tsx      — glassmorphism on scroll, theme switcher, mobile menu
│   │   ├── Hero.tsx        — animated unit circle, gradient headline, CTA, stats
│   │   ├── ModeShowcase.tsx — 4 mode cards, border-glow on hover
│   │   └── Reveal.tsx      — scroll-triggered Intersection Observer animation
│   └── canvas/
│       ├── UnitCircle.tsx  — M4 stub (animated preview in Hero is separate)
│       ├── VectorDiagram.tsx — stub
│       ├── RotationMatrix.tsx — stub
│       └── PolygonSnap.tsx — stub
├── package.json
├── next.config.js          — NOTE: .ts renamed to .js for Next.js 14 compat
├── tailwind.config.ts
└── postcss.config.js
```

**Color tokens (globals.css):**
```css
:root {
  --bg: #0D1117;  --surface: #161B22;  --border: #30363D;
  --primary: #58A6FF;  --secondary: #3DCFB8;
  --arm1: #F78166;  --arm2: #7EE787;  --resultant: #E3B341;
  --text: #E6EDF3;  --muted: #8B949E;
}
[data-theme="chalk"] { /* light theme */ }
[data-theme="sikhay"] { /* branded dark */ }
```

**Premium upgrades done August 11:**
- Scroll-triggered entrance animations via `Reveal.tsx` (Intersection Observer)
- Glassmorphism Navbar — backdrop-filter blur after 8px scroll
- Gradient headline text — var(--primary) to var(--arm1)
- Mode card border-glow on hover — var(--primary) box-shadow
- Section spacing minimum 120px
- All transitions use `cubic-bezier(0.4, 0, 0.2, 1)`

---

### Claude Code Agents (`.claude/agents/`)

10 specialist agents installed:

| Agent | Model | Scope |
|---|---|---|
| orchestrator | claude-opus-4-6 | Planning and delegation |
| firmware-engineer | claude-sonnet-4-6 | firmware/ only |
| app-engineer | claude-sonnet-4-6 | app/ only |
| ui-designer | claude-sonnet-4-6 | website/components/ui/ |
| frontend-engineer | claude-sonnet-4-6 | website/components/canvas/ |
| backend-engineer | claude-sonnet-4-6 | website/app/ routes + SSG |
| tech-writer | claude-haiku-4-5 | docs/ + reports |
| code-reviewer | claude-sonnet-4-6 | Read-only, pre-merge |
| qa-tester | claude-sonnet-4-6 | firmware/test/ + app/test/ |
| security-auditor | claude-sonnet-4-6 | Read-only, security audit |

---

### Planning Documents (`docs/planning/`)

| File | Contents |
|---|---|
| `part1-deepresearch.md` | Market research, competitor analysis |
| `part2-prd-mvp.md` | Product requirements, MVP scope |
| `part3-tech-design-mvp.md` | Technical design decisions |
| `part5-dev-prompts.md` | Implementation phases |
| `CLAUDE.md` (repo root) | Agent memory — read by every agent at startup |

---

## What Is Pending

### Immediate (next session)

| Task | Agent | Command |
|---|---|---|
| Website docs hub + dynamic pages | backend-engineer | In progress tonight |
| Website About + Demo pages | backend-engineer | In progress tonight |
| Merge feature/app-ble-manager → dev | Manual | `git merge feature/app-ble-manager --allow-unrelated-histories` |
| Valiger pull dev | Valiger | Tell them to pull |

### Soon

| Task | Agent | Notes |
|---|---|---|
| Website canvas ports (VectorDiagram etc.) | frontend-engineer | Port Flutter painters to HTML5 Canvas |
| Website Footer | ui-designer | Copyright, links, branding |
| Vercel deployment | Manual | After landing page complete |
| Premium UI pass on app | app-engineer | Screen transitions, BLE dot animation |
| flutter analyze | Valiger | No Flutter SDK on Sikhay machine |

### Blocked

| Task | Blocker |
|---|---|
| Flash firmware to ESP32 | No hardware |
| End-to-end BLE validation (M4) | No hardware |
| Pilot build APK (M5) | Awaiting M4 |

---

## How to Start Next Session

### Option A — Continue backend work

```powershell
# Terminal 1 — website backend
cd "C:\Users\Henry Gabriel\Downloads\radian-website-wt"
claude
# Then: @backend-engineer Continue building the docs and about pages
```

### Option B — Parallel three-terminal session

```powershell
# Terminal 1 — app track
cd "C:\Users\Henry Gabriel\Downloads\radian"
git checkout feature/app-ble-manager
claude
# @app-engineer Run final check — list all screens and painters, confirm all 4 modes complete

# Terminal 2 — website backend
cd "C:\Users\Henry Gabriel\Downloads\radian-website-wt"
claude
# @backend-engineer Continue from last session — finish docs and about pages

# Terminal 3 — website canvas
cd "C:\Users\Henry Gabriel\Downloads\radian-website-wt"
claude
# @frontend-engineer Implement VectorDiagram.tsx in website/components/canvas/
# as a port of app/lib/widgets/painters/vector_diagram_painter.dart
```

### Save at end of every session

```powershell
# App track
cd "C:\Users\Henry Gabriel\Downloads\radian"
git add .
git commit -m "your commit message"
git push origin feature/app-ble-manager

# Website track
cd "C:\Users\Henry Gabriel\Downloads\radian-website-wt"
git add .
git commit -m "your commit message"
git push origin feature/website-landing
```

---

## Key Technical Decisions (Do Not Change Without Review)

| Decision | Rationale |
|---|---|
| ESP32 over Arduino Nano | BLE required |
| NimBLE over default BLE | 30% lower RAM |
| Riverpod over Provider | Better async stream support |
| JSON BLE payload over binary | Easier debugging, within 100-byte limit at 20Hz |
| Static Next.js over SSR | No backend needed, free Vercel hosting |
| RadianCanvasTheme extension | Single source of truth for canvas colors across all themes |
| `--allow-unrelated-histories` flag | Required due to force push rewriting history |

---

## Critical Files — Never Modify Without Both Leads

- `docs/ble_contract.md` — BLE payload spec
- `app/lib/ble/radian_packet.dart` — mirrors ble_contract.md exactly
- `CLAUDE.md` — agent memory, changes affect all agents

---

## PAT Warning

The GitHub PAT is embedded in the remote URL in plaintext. Rotate it and switch to SSH before the next session:

```powershell
ssh-keygen -t ed25519 -C "sikhayprs@gmail.com"
cat ~/.ssh/id_ed25519.pub
# Add to GitHub → Settings → SSH keys
git remote set-url origin git@github.com:sikhayph/RADIAN.git
```

---

## Pending PDF Reports (Due Friday)

- Accomplishment_Report_RADIAN_July16.docx → PDF
- Accomplishment_Report_RADIAN_July21.docx → PDF
- Accomplishment_Report_RADIAN_July26.docx → PDF
- Accomplishment_Report_RADIAN_Aug9.docx → PDF
- Accomplishment_Report_RADIAN_Aug11.docx → PDF

---

*Sikhay Research, Development and Prototyping — Internal*  
*© 2026 All rights reserved*

# RADIAN Software
### Rotary · Angular · Display · Intuitive · Angle · Notation

**A co-development by Sikhay Research, Development and Prototyping and Valiger**

> *July 2026 — Internal · For the use of Sikhay and Valiger only*

---

## Table of Contents

1. [Project Description](#1-project-description)
   - [Overview](#overview)
   - [Problem Statement](#problem-statement)
   - [Target Users](#target-users)
   - [Scope of Software Deliverables](#scope-of-software-deliverables)
   - [Teaching Modes](#teaching-modes)
   - [Expansion Backlog](#expansion-backlog-post-initial-release)
2. [Technical Requirements & Stack](#2-technical-requirements--stack)
   - [Firmware — ESP32](#firmware--esp32)
   - [BLE Data Contract](#ble-data-contract)
   - [Mobile Companion App](#mobile-companion-app)
   - [App Screen Architecture](#app-screen-architecture)
   - [Website](#website)
   - [Repository Structure](#repository-structure)
   - [Branching Strategy](#branching-strategy)
   - [Development Environment Requirements](#development-environment-requirements)
3. [GitHub Collaboration Documents](#3-github-collaboration-documents)
   - [CONTRIBUTING.md](#contributingmd)
   - [docs/ble_contract.md](#docsble_contractmd)
   - [Bug Report Template](#bug-report-issue-template)
   - [Feature Request Template](#feature-request-issue-template)
   - [Flutter CI Workflow](#ci-workflow-githubworkflowsflutter_ciyml)
   - [LICENSE](#license)
   - [.gitignore](#gitignore)
4. [Milestone Plan](#4-milestone-plan)

---

## 1. Project Description

### Overview

The **RADIAN Software Suite** is the digital backbone of the Rotary Angular Display with Intuitive Angle Notation (RADIAN) — a co-developed educational hardware device produced by Sikhay Research, Development and Prototyping in collaboration with Valiger. The suite comprises three tightly coupled components:

1. **Firmware** running on the ESP32 microcontroller embedded in the RADIAN device
2. **A cross-platform mobile companion application** that communicates with the device over Bluetooth Low Energy (BLE)
3. **A public-facing website** that mirrors the companion app's design language, serves as the product landing page, and expands into a web-based interactive demo once the app reaches a stable release

The mobile app and the website are not independent products — the website is built on top of the app's design system, data structures, and visual language. Any update to the app's UI/UX is reflected on the website. They share the same color themes, typography, and canvas aesthetics defined in `app/lib/app_theme.dart` and `docs/ui_spec.md`.

The hardware instructs; the software amplifies; the website sells.

---

### Problem Statement

Secondary and early tertiary mathematics instruction in the Philippines relies predominantly on two tools that sit at opposite ends of the engagement spectrum: static physical manipulatives (protractors, printed charts, physical models) and free on-screen software (GeoGebra, Desmos, PhET). Physical tools have no feedback loop — a student can hold a protractor to 45° and never know if they are correct. Software tools have no physical grounding — students engage with pixels, not with real rotation.

Neither pole provides what the other lacks: **physical grounding with real-time corrective feedback, connected to a live data source the teacher can monitor.** RADIAN closes this gap. The software layer is what makes that closure possible — it is the feedback, the visualization, the quiz engine, and the teacher dashboard that the hardware alone cannot carry.

---

### Target Users

- Secondary students (Grades 7–12) learning trigonometry, linear algebra, geometry, and introductory calculus
- Early tertiary students in STEM foundation courses encountering radians, vectors, and rotation matrices for the first time
- Mathematics and science teachers conducting hands-on demonstrations or structured lab activities
- School administrators evaluating and procuring educational technology for DepEd K-12 alignment

---

### Scope of Software Deliverables

**In scope for this collaboration:**

| Deliverable | Description |
|---|---|
| ESP32 Firmware | Angle sensing, mode logic, BLE data broadcasting, on-device OLED rendering |
| Mobile Companion App | BLE connection management, live visualization, lesson modes, quiz engine |
| Website | Product landing page, interactive demo, documentation — built on app design system |
| BLE Data Contract | Shared message protocol joining firmware and app — single source of truth |
| Repository Governance | Branch strategy, contribution rules, CI workflow |

**Explicitly out of scope for this phase:**
- School management system integration
- Cloud data storage and backend API infrastructure
- Multi-tenant teacher dashboard (planned post-pilot)

---

### Teaching Modes

Four teaching modes are committed for initial release. Each maps to a distinct curriculum strand and drives a distinct visualization on both the companion app and the website demo.

#### Mode 1 — Degree / Radian Conversion
The device reads the primary arm's angle and displays it simultaneously in degrees and its radian equivalent. The companion app and website render a full animated unit circle with the arm position, the arc length swept, and the `(cos θ, sin θ)` coordinate highlighted at the tip.

#### Mode 2 — Vector Addition
Both arms are read independently, each treated as a vector with unit magnitude and direction equal to its angle. The firmware computes the resultant vector and broadcasts the component breakdown. The app and website display an animated vector diagram showing both arms, their components, and the resultant tail-to-tip.

#### Mode 3 — Rotation Matrix
The primary arm's angle θ defines a 2×2 rotation matrix **R(θ)**. The firmware applies **R** to the secondary arm's position vector and broadcasts the transformed coordinates. The app and website render the before/after transformation live.

#### Mode 4 — Polygon / Central Angle Snap
The user selects a polygon order N (3–12) via the device buttons. The arm snaps to the nearest multiple of 360°/N and displays interior, central, and exterior angle values for that N-gon. The app and website render the full regular polygon inscribed in a circle with the current vertex highlighted.

---

### Expansion Backlog (Post-Initial Release)

- **Quiz mode** — teacher-issued angle targets, student arm-matching, scored response logging
- **Teacher dashboard** — BLE-aggregated per-student accuracy and response-time data during class
- **Wave-trace mode** — real-time sin/cos curve traced as the student sweeps the arm
- **Cartesian grid plate support** — slope, y-intercept, and linear function mode
- **Edge slider integration** — live parameter adjustment for function graphing
- **Multi-device BLE management** — teacher app managing multiple student RADIAN units
- **Website interactive demo** — browser-based simulation of all four modes without hardware

---

## 2. Technical Requirements & Stack

### Firmware — ESP32

| Property | Value |
|---|---|
| **Platform** | ESP32-WROOM-32 DevKit V1 |
| **Framework** | Arduino framework via PlatformIO (VSCode extension) |
| **Language** | C++ (Arduino dialect) |
| **Sensors** | AS5600 magnetic rotary encoder ×2 via TCA9548A I²C mux (0x36 / 0x37) |
| **Display** | SSD1306/SH1106 OLED 0.96″ — I²C |
| **BLE Library** | NimBLE-Arduino (preferred for lower memory footprint) |
| **Key Libraries** | `Wire.h`, AS5600 library, Adafruit_SSD1306, ArduinoJson |

---

### BLE Data Contract

> ⚠️ **The BLE contract is the single most critical shared deliverable.** Firmware and app must agree on it before parallel development begins. It must not be changed unilaterally by either track.

```
Service UUID:    4A2B-RADIAN-0001  (custom 128-bit)
Characteristic:  ANGLE_DATA  (notify, read)
Notify interval: ~50 ms (20 Hz)
Encoding:        JSON string, UTF-8, ≤ 100 bytes
```

**Payload structure:**

```json
{
  "mode": 1,
  "a1": 47.3,
  "a2": 112.8,
  "val": {
    "rad":  0.825,
    "rx":   0.682,
    "ry":   0.731,
    "rmag": 1.41,
    "rang": 80.05,
    "snap": 6,
    "int":  120.0,
    "ext":  60.0
  },
  "ts": 1720863600
}
```

See [`docs/ble_contract.md`](./docs/ble_contract.md) for the full field reference and change process.

---

### Mobile Companion App

| Property | Value |
|---|---|
| **Framework** | Flutter 3.x (Dart) |
| **Target Platforms** | Android 8.0+ (primary), iOS 13+ (secondary) |
| **BLE Library** | `flutter_blue_plus` |
| **State Management** | Riverpod |
| **Visualization** | `fl_chart` + custom `CustomPainter` (unit circle, vector diagram, polygon) |
| **Navigation** | `go_router` |
| **Local Storage** | Hive |
| **Min SDK** | Android API 26 / iOS 13 |

---

### Website

The RADIAN website is not a separate codebase — it is a web front-end built on the same design system as the companion app. It shares the same color tokens, typography, and canvas visualization logic. When the app is updated, the website is updated in lockstep.

**Purpose:**
- Product landing page for institutional buyers (schools, DepEd divisions, LGUs)
- Interactive browser-based demo of all four teaching modes — no hardware required
- Documentation hub linking to all `docs/` files in this repository
- Download / procurement contact page

**Tech Stack:**

| Property | Value |
|---|---|
| **Framework** | Next.js 14 (App Router) |
| **Language** | TypeScript |
| **Styling** | Tailwind CSS — tokens mirror `app_theme.dart` color palettes |
| **Visualization** | React + HTML5 Canvas (`<canvas>`) — ports the Flutter CustomPainter logic to the browser |
| **Animation** | Framer Motion — arm sweep, arc fill, vector animations |
| **Deployment** | Vercel |
| **Domain** | TBD — planned under `sikhay.ph` or `radian.sikhay.ph` |
| **CMS** | None for v1 — static content, MDX for documentation pages |

**Shared with the app:**
- Color palette — Obsidian, Chalk, and Sikhay themes defined once in `docs/ui_spec.md`, implemented in both Tailwind and Flutter
- Canvas logic — the four mode visualizers are ported from `CustomPainter` to HTML5 Canvas so the website demo behaves identically to the app
- Typography — Inter and JetBrains Mono used in both codebases

**Website folder** (to be scaffolded at M4, after app visualizers are stable):

```
website/
├── app/                    # Next.js App Router
│   ├── page.tsx            # Landing page
│   ├── demo/
│   │   └── page.tsx        # Interactive four-mode demo
│   └── docs/
│       └── page.tsx        # Documentation hub
├── components/
│   ├── canvas/             # HTML5 Canvas visualizers (ports of Flutter painters)
│   │   ├── UnitCircle.tsx
│   │   ├── VectorDiagram.tsx
│   │   ├── RotationMatrix.tsx
│   │   └── PolygonSnap.tsx
│   └── ui/                 # Shared UI components
├── styles/
│   └── globals.css         # Tailwind config with RADIAN color tokens
├── public/
└── next.config.ts
```

> **Development dependency:** The website's canvas visualizers depend on the app's `CustomPainter` implementations being stable. Website development begins at **M4** — after all four app visualizers pass end-to-end hardware validation.

---

### App Screen Architecture

| Screen | Description |
|---|---|
| Scan & Connect | Discover RADIAN devices by BLE name/UUID, connect with single tap |
| Home / Mode | Mirrors active mode from device; allows mode switch from app |
| Mode 1 Visualizer | Animated unit circle, sweeping arc, cos/sin panel, degree↔radian display |
| Mode 2 Visualizer | Two-vector diagram, component breakdown, resultant vector |
| Mode 3 Visualizer | 2×2 rotation matrix display, before/after vector, animated arc |
| Mode 4 Visualizer | Inscribed regular polygon, highlighted vertex, angle panel |
| Settings | Device nickname, unit preference, theme, connection management |

---

### Repository Structure

```
radian/
├── firmware/                   # ESP32 PlatformIO project
│   ├── src/
│   │   ├── main.cpp
│   │   ├── ble/
│   │   ├── modes/
│   │   └── sensors/
│   ├── include/
│   │   └── config.h
│   ├── test/
│   └── platformio.ini
├── app/                        # Flutter companion application
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app_theme.dart
│   │   ├── ble/
│   │   │   ├── ble_manager.dart
│   │   │   └── radian_packet.dart
│   │   ├── screens/
│   │   ├── widgets/
│   │   │   └── painters/
│   │   ├── models/
│   │   └── providers/
│   └── pubspec.yaml
├── website/                    # Next.js website (scaffolded at M4)
│   ├── app/
│   ├── components/
│   │   └── canvas/
│   └── styles/
├── docs/
│   ├── ble_contract.md
│   ├── architecture.md
│   ├── hardware_pinout.md
│   └── ui_spec.md
├── .github/
│   ├── ISSUE_TEMPLATE/
│   └── workflows/
├── README.md
├── CONTRIBUTING.md
└── LICENSE
```

---

### Branching Strategy

| Branch | Rule |
|---|---|
| `main` | Stable, production-ready only — no direct push; PR + review required |
| `dev` | Integration branch — all feature branches merge here first; weekly sync to `main` |
| `feature/firmware-*` | Firmware feature branches |
| `feature/app-*` | App feature branches |
| `feature/website-*` | Website feature branches (active from M4) |
| `fix/*` | Hotfix branches off `main` |
| `docs/*` | Documentation-only changes |

---

### Development Environment Requirements

**Firmware track (Sikhay):**
- Visual Studio Code + PlatformIO IDE extension
- Python 3.x (PlatformIO dependency)
- USB driver: CP210x or CH340
- Git 2.x

**App track (Valiger):**
- Flutter SDK 3.x (stable channel)
- Android Studio or VSCode with Flutter/Dart extensions
- Android SDK API 26+
- Physical Android device — BLE cannot be tested on emulators
- Git 2.x

**Website track (TBD — M4):**
- Node.js 20+
- npm or pnpm
- VSCode with ESLint + Prettier extensions
- Git 2.x

---

## 3. GitHub Collaboration Documents

> Copy each block below into the corresponding file in the repository.

---

### CONTRIBUTING.md

See [`CONTRIBUTING.md`](./CONTRIBUTING.md) in the root of this repository.

---

### docs/ble_contract.md

See [`docs/ble_contract.md`](./docs/ble_contract.md).

---

### Bug Report Issue Template

*Saved as `.github/ISSUE_TEMPLATE/bug_report.md`*

```markdown
---
name: Bug Report
about: Something is broken in firmware, app, or website
labels: bug
---

## Track
- [ ] Firmware (ESP32)
- [ ] App (Flutter)
- [ ] Website (Next.js)
- [ ] BLE connection

## Description

## Steps to reproduce
1.
2.
3.

## Expected behaviour

## Actual behaviour

## Environment
- Board / device / browser:
- Firmware / App / Website version:
- Mode when bug occurred:

## Screenshots / serial logs
```

---

### Feature Request Issue Template

*Saved as `.github/ISSUE_TEMPLATE/feature_request.md`*

```markdown
---
name: Feature Request
about: Propose a new feature or enhancement
labels: enhancement
---

## Track
- [ ] Firmware
- [ ] App
- [ ] Website
- [ ] BLE contract change (requires dual approval)

## Problem this solves

## Proposed solution

## Alternatives considered

## Teaching mode affected
- [ ] Mode 1 — Degree/Radian
- [ ] Mode 2 — Vector Addition
- [ ] Mode 3 — Rotation Matrix
- [ ] Mode 4 — Polygon Snap
- [ ] New mode
- [ ] General / cross-cutting

## Additional context
```

---

### CI Workflow (`.github/workflows/flutter_ci.yml`)

```yaml
name: Flutter CI

on:
  push:
    branches: [ dev, main ]
    paths: [ 'app/**' ]
  pull_request:
    branches: [ dev, main ]
    paths: [ 'app/**' ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: stable

      - name: Install dependencies
        working-directory: app
        run: flutter pub get

      - name: Analyze
        working-directory: app
        run: flutter analyze

      - name: Run tests
        working-directory: app
        run: flutter test

      - name: Build APK (debug)
        working-directory: app
        run: flutter build apk --debug
```

---

### LICENSE

```
Copyright (c) 2026 Sikhay Research, Development and Prototyping
                   and Valiger

All rights reserved.

This software and associated documentation files (the "Software") are
the proprietary and confidential property of Sikhay Research,
Development and Prototyping and Valiger. No part of the Software may
be reproduced, distributed, modified, or used in any form or by any
means without the prior written permission of both parties.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY ARISING FROM THE USE OF THE SOFTWARE.
```

---

### .gitignore

```gitignore
# PlatformIO
.pio/
firmware/.pio/

# Flutter
app/.dart_tool/
app/build/
app/.flutter-plugins
app/.flutter-plugins-dependencies

# Next.js
website/.next/
website/node_modules/
website/.env.local

# IDE
.vscode/settings.json
.idea/
*.swp

# OS
.DS_Store
Thumbs.db
```

---

## 4. Milestone Plan

> The BLE contract lock at **M1** is the hard synchronization gate between the firmware and app tracks. Website development begins at **M4** — after app visualizers pass end-to-end hardware validation.

| Gate | Timeline | Deliverable |
|---|---|---|
| **M0** | Week 1 | Repository setup, branch structure, development environments — all tracks |
| **M1** | Week 2 | BLE contract v1.0 locked — **unlocks parallel firmware and app dev** |
| **M2** | Week 3–4 | Firmware: Modes 1 & 2 broadcasting · App: BLE scanner + mock Mode 1 visualizer |
| **M3** | Week 5–6 | Firmware: Modes 3 & 4 complete · App: all four visualizers on mock data |
| **M4** | Week 7 | Full integration: app connects to real hardware, all four modes validated · **Website scaffold begins** |
| **M5** | Week 8 | Pilot build: APK to pilot teacher, firmware flashed · Website landing page live on Vercel |
| **M6** | Post-pilot | Website interactive demo — all four modes in browser, no hardware required |

---

<div align="center">

**Sikhay Research, Development and Prototyping and Valiger**
*Internal — Proprietary and Confidential*
*© 2026 All rights reserved*

</div>

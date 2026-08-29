# RADIAN UI/UX Specification

> **Version:** 1.0  
> **Status:** Locked for v1 — changes require both leads  
> **Sikhay and Valiger Collaboration**  
> **Date:** July 17, 2026

---

## Table of Contents

1. [Layout System](#1-layout-system)
2. [Color Themes](#2-color-themes)
3. [Typography](#3-typography)
4. [Canvas Design — Per Mode](#4-canvas-design--per-mode)
5. [Component Guidelines](#5-component-guidelines)
6. [Accessibility](#6-accessibility)

---

## 1. Layout System

RADIAN uses a **responsive two-panel layout** that adapts to screen width. The physical device is primarily used in a classroom — on a desk in front of a student (portrait phone) or projected on a display during a teacher demonstration (landscape tablet or widescreen).

### Breakpoints

| Screen Width | Layout | Use Case |
|---|---|---|
| < 600px | Single panel, stacked | Phone portrait — student personal use |
| 600–900px | Side-by-side | Phone landscape / small tablet |
| > 900px | Full two-panel with persistent sidebar | Tablet / widescreen / teacher demo |

### Implementation

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 900) {
      return WideLayout();     // persistent sidebar + full canvas
    } else if (constraints.maxWidth > 600) {
      return MediumLayout();   // side-by-side, no persistent sidebar
    } else {
      return NarrowLayout();   // stacked, full-width canvas
    }
  },
)
```

### Panel Anatomy — Widescreen (> 900px)

```
┌─────────────────────────────────────────────────────────┐
│  AppBar — RADIAN · Mode Name · BLE status badge         │
├──────────────────┬──────────────────────────────────────┤
│  LEFT PANEL      │  RIGHT PANEL                         │
│  (fixed 300px)   │  (flexible)                          │
│                  │                                       │
│  BLE badge       │  ┌─────────────────────────────────┐ │
│  ─────────────   │  │                                 │ │
│  Mode selector   │  │        CANVAS                   │ │
│  [1][2][3][4]    │  │                                 │ │
│  ─────────────   │  │   (unit circle / vector /       │ │
│  Arm 1: 47.3°    │  │    matrix / polygon)            │ │
│  Arm 2: 112.8°   │  │                                 │ │
│  rad: 0.825      │  └─────────────────────────────────┘ │
│  ─────────────   │                                       │
│  cos θ: 0.682    │  Degree readout · Radian readout      │
│  sin θ: 0.731    │                                       │
└──────────────────┴──────────────────────────────────────┘
```

### Left Panel Contents (Widescreen)
- BLE connection status and signal strength
- Mode selector — all four modes always visible as tappable tiles
- Live angle readout badges — Arm 1, Arm 2, computed value
- Polygon N stepper (Mode 4 only, shown contextually)

### Right Panel Contents (Widescreen)
- Full visualizer canvas — fills available space
- Angle value bar below the canvas (degree and radian, large monospace type)

---

## 2. Color Themes

Three themes are defined in `app/lib/app_theme.dart`. Access canvas-specific colors via:

```dart
final canvas = Theme.of(context).extension<RadianCanvasTheme>()!;
```

### Theme 1 — Obsidian (Default Dark)

| Role | Color | Hex |
|---|---|---|
| Background | Deep navy-black | `#0D1117` |
| Surface / panels | Dark slate | `#161B22` |
| Border / divider | Subtle gray | `#30363D` |
| Primary accent | Electric blue | `#58A6FF` |
| Secondary accent | Soft teal | `#3DCFB8` |
| Arm 1 | Vivid orange | `#F78166` |
| Arm 2 | Lime green | `#7EE787` |
| Resultant vector | Gold | `#E3B341` |
| Text primary | Off-white | `#E6EDF3` |
| Text muted | Cool gray | `#8B949E` |

**When to use:** Default. Best for extended classroom sessions and low-light environments.

### Theme 2 — Chalk (Light / Classroom)

| Role | Color | Hex |
|---|---|---|
| Background | Warm white | `#FAFAFA` |
| Surface / panels | Light gray | `#F0F2F5` |
| Border / divider | Medium gray | `#D0D7DE` |
| Primary accent | Deep blue | `#0969DA` |
| Secondary accent | Dark teal | `#1A7F64` |
| Arm 1 | Red-orange | `#CF222E` |
| Arm 2 | Forest green | `#116329` |
| Resultant vector | Dark gold | `#9A6700` |
| Text primary | Near-black | `#1F2328` |
| Text muted | Medium gray | `#656D76` |

**When to use:** Projected displays, bright classrooms, printable screenshots.

### Theme 3 — Sikhay (Branded Dark)

| Role | Color | Hex |
|---|---|---|
| Background | Rich black | `#0A0A0A` |
| Surface / panels | Dark charcoal | `#141414` |
| Border / divider | Dark gray | `#2A2A2A` |
| Arm 1 | Bright white | `#FFFFFF` |
| Arm 2 | Light gray | `#AAAAAA` |
| Resultant vector | Off-white | `#E0E0E0` |
| Text primary | White | `#FFFFFF` |
| Text muted | Gray | `#888888` |

**When to use:** Product demos, pitch presentations, investor showcases.

---

## 3. Typography

| Role | Font | Size | Weight | Notes |
|---|---|---|---|---|
| Mode name | Inter | 18px | SemiBold | AppBar and mode tile labels |
| Live angle readout | JetBrains Mono | 32px | Bold | Numbers that update rapidly — fixed-width prevents layout jump |
| Canvas labels | Inter | 12px | Regular | Angle tick labels, axis labels |
| Matrix values | JetBrains Mono | 14px | Medium | 2×2 matrix in Mode 3 |
| Body / settings | Inter | 14px | Regular | All prose, settings labels |
| Section headers | Inter | 16px | Medium | Left panel section dividers |

### Font Loading

Add to `pubspec.yaml`:

```yaml
flutter:
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Medium.ttf   weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf weight: 600
    - family: JetBrainsMono
      fonts:
        - asset: assets/fonts/JetBrainsMono-Regular.ttf
        - asset: assets/fonts/JetBrainsMono-Medium.ttf  weight: 500
        - asset: assets/fonts/JetBrainsMono-Bold.ttf    weight: 700
```

> Download Inter from https://rsms.me/inter and JetBrains Mono from https://www.jetbrains.com/lp/mono — both are open source.

---

## 4. Canvas Design — Per Mode

### Global Canvas Rules

- Canvas fills the right panel on widescreen or the lower 60% on mobile portrait
- Origin point always marked with a small filled circle — never implied
- All arms rendered as thick rounded lines (`strokeWidth: 4.0`) with an arrowhead at the tip
- Angle arc drawn from 0° to current angle — filled with arm color at 20% opacity
- Grid lines at 30° intervals — 10% opacity, never distracting
- Labels never overlap the arm — positioned at arc midpoint, offset outward by 16px
- All arm movements eased with `200ms` curve — `Curves.easeOut`
- Canvas redraws triggered by BLE notify stream, not a fixed timer

---

### Mode 1 — Unit Circle Canvas

**Layout:**
```
         sin θ ↑
                │
   ─────────────O─────────────  cos θ →
               ╱│
         arm  ╱ │
             ╱  │
    (cos θ, sin θ)
```

**Elements:**
- Full unit circle at radius = 80% of min(width, height) / 2
- Cardinal labels outside the ring: `0`, `π/2`, `π`, `3π/2`
- Tick marks at 30°, 45°, 60° and their radian equivalents
- Arm from origin to (cos θ, sin θ) — color: Arm 1
- Dotted projection lines from arm tip to x-axis (cos) and y-axis (sin)
- Coordinate labels at projection endpoints — `cos θ = 0.682`, `sin θ = 0.731`
- Bottom bar: `47.3°` and `0.825 rad` in large JetBrains Mono type

---

### Mode 2 — Vector Addition Canvas

**Elements:**
- Arm 1 from origin — color: Arm 1
- Arm 2 from origin — color: Arm 2
- Resultant vector drawn tail-to-tip (arm 1 tip → arm 2 tip) — color: Resultant
- Dashed component lines projected to x and y axes for each arm
- Faint parallelogram outline connecting all four tips
- Bottom bar: `|R| = 1.41   ∠ = 80.05°`

---

### Mode 3 — Rotation Matrix Canvas

**Elements:**
- 2×2 rotation matrix displayed top-left in JetBrains Mono, values updating live:
  ```
  R(θ) = [ cos θ  -sin θ ]
          [ sin θ   cos θ ]
  ```
- Original arm 2 vector in muted color
- Transformed arm 2 vector in bright color
- Arc drawn between original and transformed showing rotation angle θ
- Optional ghost trail (last 5 positions at decreasing opacity) — toggled in Settings

---

### Mode 4 — Polygon / Central Angle Canvas

**Elements:**
- Regular N-gon centered on canvas, inscribed in a faint circle
- Current vertex highlighted with filled dot + subtle glow
- All interior angles shown as small arcs at each vertex
- Central angle arc drawn from center to current vertex
- N stepper (+/−) in top-right corner of canvas
- Bottom bar three-column layout:
  ```
  Interior: 120°    Exterior: 60°    Central: 60°
  ```
- Polygon label centered above canvas: `Regular Hexagon (N = 6)`

---

## 5. Component Guidelines

### BLE Status Badge
- Connected: filled green dot + device name
- Scanning: pulsing gray dot + "Scanning..."
- Disconnected: empty red dot + "Not connected"
- Always visible in AppBar trailing position

### Mode Selector Tiles
- Four tiles always visible on widescreen left panel
- On mobile: bottom navigation bar with four icons
- Active mode: filled background using primary color
- Inactive: surface color with muted label

### Angle Readout Badge
- Large JetBrains Mono type — 32px bold
- Degree and radian shown simultaneously, separated by a divider
- Updates at 20Hz — smooth, no flicker

### Settings Screen
- Theme selector: three preview tiles (Obsidian / Chalk / Sikhay)
- Unit preference toggle: Degrees / Radians
- Ghost trail toggle (Mode 3 only)
- Device nickname field
- Disconnect button

---

## 6. Accessibility

- All color pairs meet WCAG AA contrast ratio (4.5:1 minimum for text)
- Arm colors are distinct under deuteranopia — Arm 1 (orange/red) and Arm 2 (blue/green) are distinguishable
- Buzzer and haptic feedback serve as non-visual angle confirmation
- Canvas labels use minimum 12px — never smaller
- Touch targets minimum 48×48dp on all interactive elements

---

<div align="center">

**Sikhay Research, Development and Prototyping and Valiger**  
*Internal — Proprietary and Confidential · © 2026 All rights reserved*

</div>

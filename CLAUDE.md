# MEMORY.md — Radian (Artifact-First Memory)

*This file is the source of truth for "where are we right now." Update it after every meaningful milestone. Do not let it go stale.*

## 🏗️ Active Phase & Goal

**Phase:** 1 — BLE Data Contract & Firmware
**Goal:** Confirm/implement the ESP32 GATT service (`angle_notify`, `device_status`) on the existing ANGGULO hardware and verify reliable BLE notify behavior.
**Blocked by:** None yet identified — but flag if the IPOPHL filing-scope question (see AGENTS.md) needs resolving before any hardware-level changes are made.

## ✅ Completed

- [x] Part 1 — Research request drafted
- [x] Part 2 — PRD completed
- [x] Part 3 — Technical Design Document completed
- [x] Part 4 — Agent config files instantiated

## 🔜 Up Next

1. Confirm ANGGULO's current firmware/BLE state (does it already broadcast angle data, or does this need to be built from scratch?)
2. Define the exact byte layout for the `angle_notify` payload (scaled angle format, sequence number size)
3. Set up Flutter project skeleton with `flutter_blue_plus`

## 🧠 Decisions Log (append, don't rewrite history)

- **2026-08-09** — BLE library: `flutter_blue_plus` chosen over `flutter_reactive_ble` (better maintenance/community per Tech Design §3.1)
- **2026-08-09** — Website: static site, no backend, no live device sync in MVP (Tech Design §4)
- **2026-08-09** — Keep ANGGULO hardware/mechanism unchanged for MVP (Tech Design §2.2) — **contingent on IPOPHL filing question being resolved**

## ⚠️ Open Risks / Watch List

- IPOPHL filing scope unresolved — could affect what hardware changes are actually safe to make
- No numeric BLE latency target set — plan to test empirically in Phase 1/2, not assume a number
- Timeline is Q4 2026 for a full demo across device + app + website — track pace against phases above

# Contributing to RADIAN

This repository is a closed collaboration between **Sikhay Research, Development and Prototyping** and **Valiger**. External contributions are not accepted at this stage.

---

## Track Ownership

| Track | Owner | Scope |
|---|---|---|
| Firmware | Sikhay | ESP32, PlatformIO, sensors, BLE broadcast, mode compute |
| App | Valiger | Flutter, BLE receive, visualizations, UI/UX |
| BLE Contract | Both | Shared sign-off required for any change |
| Docs | Both | Either track may update — notify the other |

> Each track owns its folder entirely. Sikhay does not touch `app/`. Valiger does not touch `firmware/`. The only shared files are `docs/ble_contract.md` and `app/lib/ble/radian_packet.dart`.

---

## Branch Naming

```
feature/firmware-<short-description>    ← Sikhay
feature/app-<short-description>         ← Valiger
fix/<short-description>                 ← Either track
docs/<short-description>                ← Either track
```

**Examples:**
```
feature/firmware-mode2-vector
feature/app-mode1-unitcircle-painter
fix/encoder-zero-offset
docs/update-ble-contract
```

---

## Commit Message Format

```
<type>(<scope>): <short summary in present tense, lowercase>

Types : feat | fix | docs | refactor | test | chore
Scopes: firmware | app | ble | docs | repo

Examples:
  feat(firmware): add Mode 2 vector resultant computation
  feat(app): implement unit circle CustomPainter for Mode 1
  fix(firmware): correct encoder zero-offset calibration
  fix(app): resolve BLE disconnect crash on Android 12
  docs(ble): clarify ts field as millis() not epoch
  chore(repo): add flutter_ci workflow
```

---

## Pull Request Rules

- All PRs target `dev` — never `main` directly
- Minimum **1 reviewer approval** required before merge
- BLE contract changes (`docs/ble_contract.md` or `app/lib/ble/radian_packet.dart`) require **both leads** to approve
- Include a short test note in the PR description:
  - Firmware: what you tested, on what board, serial monitor output
  - App: what you tested, on what device and Android version

---

## BLE Contract Change Process

The BLE contract is the single most critical shared file. It must never be changed unilaterally.

1. Open a GitHub issue tagged `ble-contract` describing the proposed change
2. Both firmware lead (Sikhay) and app lead (Valiger) comment approval on the issue
3. One person opens a PR that updates **both**:
   - `docs/ble_contract.md`
   - `app/lib/ble/radian_packet.dart`
4. Both leads approve the PR before merge
5. The other track updates their code to match within the same sprint

---

## Weekly Sync

Every Sunday, both leads:

1. Open a PR from `dev` → `main`
2. Both review and approve
3. Merge using squash merge
4. Both pull `main` locally and verify build passes

```powershell
git checkout main
git pull origin main
git checkout dev
git merge main
git push origin dev
```

---

## Development Environment

### Firmware (Sikhay)
- VS Code + PlatformIO IDE extension
- Python 3.x (PlatformIO dependency)
- USB driver: CP210x or CH340 (depends on ESP32 board variant)
- Git 2.x

### App (Valiger)
- Flutter SDK 3.x (stable channel)
- Android Studio or VS Code with Flutter/Dart extensions
- Android SDK API 26+
- Physical Android device — BLE cannot be tested on emulators
- Git 2.x

---

## Questions

Open a GitHub issue tagged `question` and tag the relevant lead. Do not message privately for technical decisions — keep all decisions in the repo so there is a record.

---

<div align="center">

**Sikhay Research, Development and Prototyping and Valiger**  
*Internal — Proprietary and Confidential · © 2026 All rights reserved*

</div>
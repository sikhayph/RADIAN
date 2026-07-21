# M0 — Repository Setup, Branch Structure & Development Environments

> **Milestone 0 · Week 1**
> This document must be completed and agreed upon by both tracks — Sikhay (firmware) and Valiger (app) — before any development code is written. It serves as the ground truth for how this repository is organized and operated.

---

## Table of Contents

1. [Repository Initialization](#1-repository-initialization)
2. [Branch Structure](#2-branch-structure)
3. [Folder Scaffolding](#3-folder-scaffolding)
4. [Development Environment — Firmware Track (Sikhay)](#4-development-environment--firmware-track-sikhay)
5. [Development Environment — App Track (Valiger)](#5-development-environment--app-track-valiger)
6. [Shared Tools — Both Tracks](#6-shared-tools--both-tracks)
7. [First-Commit Checklist](#7-first-commit-checklist)
8. [M0 Sign-Off](#8-m0-sign-off)

---

## 1. Repository Initialization

### Create the repository

1. Go to the **Sikhay GitHub organization** (`github.com/gpjffei0fefi` or the org account).
2. Click **New repository**.
3. Fill in:

| Field | Value |
|---|---|
| **Repository name** | `radian` |
| **Visibility** | Private |
| **Initialize with README** | ✅ Yes |
| **Add .gitignore** | None (we supply our own — see Section 3) |
| **License** | None (proprietary — see `LICENSE` in README) |

4. Click **Create repository**.
5. Invite Valiger's GitHub account as a **collaborator** with `Write` access:
   `Settings → Collaborators → Add people`

### Clone locally

**Firmware lead (Sikhay):**
```bash
git clone https://github.com/<org>/radian.git
cd radian
```

**App lead (Valiger):**
```bash
git clone https://github.com/<org>/radian.git
cd radian
```

---

## 2. Branch Structure

### Create all branches from `main`

Run the following once, from the firmware lead's machine, immediately after the repo is created:

```bash
# Make sure you're on main and up to date
git checkout main
git pull origin main

# Create the integration branch
git checkout -b dev
git push -u origin dev

# Create initial feature branches
git checkout dev

git checkout -b feature/firmware-mode1-degrad
git push -u origin feature/firmware-mode1-degrad
git checkout dev

git checkout -b feature/firmware-ble-service
git push -u origin feature/firmware-ble-service
git checkout dev

git checkout -b feature/app-ble-manager
git push -u origin feature/app-ble-manager
git checkout dev

git checkout -b feature/app-mode1-unitcircle
git push -u origin feature/app-mode1-unitcircle
git checkout dev

git checkout -b docs/ble-contract
git push -u origin docs/ble-contract
git checkout dev

echo "All M0 branches created."
```

### Branch map

```
main  ◄─── protected (PR + review only)
 │
 └── dev  ◄─── integration (all features land here first)
      │
      ├── feature/firmware-mode1-degrad       ← Sikhay
      ├── feature/firmware-ble-service        ← Sikhay
      ├── feature/firmware-mode2-vector       ← Sikhay (created at M2)
      ├── feature/firmware-mode3-rotmatrix    ← Sikhay (created at M3)
      ├── feature/firmware-mode4-polygonsnap  ← Sikhay (created at M3)
      │
      ├── feature/app-ble-manager             ← Valiger
      ├── feature/app-mode1-unitcircle        ← Valiger
      ├── feature/app-mode2-vector            ← Valiger (created at M2)
      ├── feature/app-mode3-rotmatrix         ← Valiger (created at M3)
      ├── feature/app-mode4-polygon           ← Valiger (created at M3)
      │
      └── docs/ble-contract                   ← Both leads (M1 gate)
```

### Branch protection rules

Set these on GitHub under `Settings → Branches → Add branch protection rule`:

**For `main`:**

| Rule | Setting |
|---|---|
| Branch name pattern | `main` |
| Require a pull request before merging | ✅ |
| Required approvals | `1` |
| Dismiss stale reviews on new commits | ✅ |
| Require status checks to pass | ✅ (Flutter CI, once active) |
| Do not allow bypassing the above settings | ✅ |

**For `dev`:**

| Rule | Setting |
|---|---|
| Branch name pattern | `dev` |
| Require a pull request before merging | ✅ |
| Required approvals | `1` |
| Do not allow force pushes | ✅ |

---

## 3. Folder Scaffolding

After creating branches, scaffold the folder structure from `dev`. This creates empty placeholder files so GitHub tracks the directories.

```bash
git checkout dev

# ── firmware ──────────────────────────────────────────
mkdir -p firmware/src/ble
mkdir -p firmware/src/modes
mkdir -p firmware/src/sensors
mkdir -p firmware/include
mkdir -p firmware/test

touch firmware/src/main.cpp
touch firmware/src/ble/BLEService.cpp
touch firmware/src/ble/BLEService.h
touch firmware/src/modes/ModeManager.cpp
touch firmware/src/modes/Mode1_DegRad.cpp
touch firmware/src/modes/Mode2_VectorAdd.cpp
touch firmware/src/modes/Mode3_RotMatrix.cpp
touch firmware/src/modes/Mode4_PolygonSnap.cpp
touch firmware/src/sensors/EncoderA.cpp
touch firmware/src/sensors/EncoderB.cpp
touch firmware/platformio.ini

# ── app ───────────────────────────────────────────────
mkdir -p app/lib/ble
mkdir -p app/lib/screens
mkdir -p app/lib/widgets/painters
mkdir -p app/lib/models
mkdir -p app/lib/providers

touch app/lib/main.dart
touch app/lib/ble/ble_manager.dart
touch app/lib/ble/radian_packet.dart
touch app/pubspec.yaml

# ── docs ──────────────────────────────────────────────
mkdir -p docs

touch docs/ble_contract.md
touch docs/hardware_pinout.md
touch docs/architecture.md

# ── github ────────────────────────────────────────────
mkdir -p .github/ISSUE_TEMPLATE
mkdir -p .github/workflows

touch .github/ISSUE_TEMPLATE/bug_report.md
touch .github/ISSUE_TEMPLATE/feature_request.md
touch .github/workflows/flutter_ci.yml

# ── root ──────────────────────────────────────────────
touch CONTRIBUTING.md
touch LICENSE

# commit scaffold
git add .
git commit -m "chore(repo): M0 folder scaffold — all tracks"
git push origin dev

echo "Scaffold pushed to dev."
```

### platformio.ini starter

Paste this into `firmware/platformio.ini`:

```ini
[env:esp32dev]
platform  = espressif32
board     = esp32dev
framework = arduino

lib_deps =
    adafruit/Adafruit SSD1306 @ ^2.5.7
    adafruit/Adafruit GFX Library @ ^1.11.5
    bblanchon/ArduinoJson @ ^7.0.0
    h2zero/NimBLE-Arduino @ ^1.4.2
    ; AS5600 library — add once confirmed (e.g., robtillaart/AS5600)

monitor_speed = 115200
upload_speed  = 921600
build_flags   = -DCORE_DEBUG_LEVEL=0
```

### pubspec.yaml starter

Paste this into `app/pubspec.yaml`:

```yaml
name: radian_app
description: RADIAN companion application — Sikhay × Valiger
version: 0.1.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_blue_plus: ^1.31.0
  riverpod: ^2.5.1
  flutter_riverpod: ^2.5.1
  go_router: ^13.2.0
  fl_chart: ^0.68.0
  hive_flutter: ^1.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
```

### .gitignore

Paste this into `.gitignore` at the repo root:

```gitignore
# ── PlatformIO ────────────────────────────
.pio/
.pioenvs/
firmware/.pioenvs/
firmware/.pio/

# ── Flutter ───────────────────────────────
app/.dart_tool/
app/build/
app/.flutter-plugins
app/.flutter-plugins-dependencies
app/pubspec.lock

# ── IDE ───────────────────────────────────
.vscode/settings.json
.idea/
*.swp
*.swo

# ── OS ────────────────────────────────────
.DS_Store
Thumbs.db
```

---

## 4. Development Environment — Firmware Track (Sikhay)

### Required installs

| Tool | Version | Install |
|---|---|---|
| Git | 2.x | https://git-scm.com |
| Python | 3.8+ | https://python.org (needed by PlatformIO) |
| Visual Studio Code | Latest | https://code.visualstudio.com |
| PlatformIO IDE (VSCode extension) | Latest | VSCode Extensions → search `PlatformIO IDE` |
| CP210x / CH340 USB driver | — | Depends on ESP32 board variant — install before first flash |

### VSCode extensions (firmware)

Install all of the following in VSCode (`Ctrl+Shift+X`):

```
PlatformIO IDE          (platformio.platformio-ide)
C/C++                   (ms-vscode.cpptools)
GitLens                 (eamodio.gitlens)
GitHub Pull Requests    (github.vscode-pull-request-github)
```

### Verify setup

```bash
# After installing PlatformIO, verify CLI is available
pio --version
# Expected: PlatformIO Core, version 6.x.x

# Build the firmware project (will fail on empty files — expected at M0)
cd firmware
pio run
```

### First flash test (hardware-on-desk check)

Once `platformio.ini` is set up and the board is connected:

```bash
cd firmware
pio run --target upload
pio device monitor --baud 115200
```

If you see output on the serial monitor, the toolchain is working.

---

## 5. Development Environment — App Track (Valiger)

### Required installs

| Tool | Version | Install |
|---|---|---|
| Git | 2.x | https://git-scm.com |
| Flutter SDK | 3.x stable | https://flutter.dev/docs/get-started/install |
| Android Studio | Latest | https://developer.android.com/studio |
| Android SDK | API 26+ | Via Android Studio SDK Manager |
| VSCode (optional) | Latest | + Flutter + Dart extensions |

### Flutter install verification

```bash
flutter doctor
```

All items should be green before development starts. Expected output:

```
[✓] Flutter (Channel stable, 3.x.x)
[✓] Android toolchain
[✓] Android Studio
[✓] Connected device  ← physical device plugged in
[✓] Network resources
```

> ⚠️ BLE cannot be tested on an Android emulator. A **physical Android device** (API 26+) is required from day one. Enable **Developer Options → USB Debugging** on the device.

### VSCode extensions (app)

```
Flutter                 (dart-code.flutter)
Dart                    (dart-code.dart-code)
GitLens                 (eamodio.gitlens)
GitHub Pull Requests    (github.vscode-pull-request-github)
```

### Verify setup

```bash
cd app
flutter pub get
flutter analyze
flutter run          # launches on connected physical device
```

---

## 6. Shared Tools — Both Tracks

### Git configuration (run once per machine)

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
git config --global core.autocrlf input      # prevents CRLF issues cross-platform
git config --global pull.rebase false        # merge, not rebase on pull
```

### GitHub authentication

Use a **Personal Access Token (PAT)** or **SSH key** — password authentication is no longer supported by GitHub.

**SSH setup (recommended):**

```bash
ssh-keygen -t ed25519 -C "your@email.com"
cat ~/.ssh/id_ed25519.pub
# Paste the output into GitHub → Settings → SSH and GPG keys → New SSH key

# Test connection
ssh -T git@github.com
# Expected: Hi <username>! You've successfully authenticated.

# Update remote to SSH
git remote set-url origin git@github.com:<org>/radian.git
```

### Commit message convention

Both tracks use the same format. This is enforced by code review, not tooling (no commit linter at M0).

```
<type>(<scope>): <short summary in present tense, lowercase>

Types : feat | fix | docs | refactor | test | chore
Scopes: firmware | app | ble | docs | repo

Examples:
  feat(firmware): add AS5600 dual-encoder I2C mux support
  feat(app): implement unit circle CustomPainter for Mode 1
  fix(firmware): correct encoder zero-offset calibration
  docs(ble): add ts field clarification to contract
  chore(repo): add flutter_ci workflow
```

### Weekly sync ritual (starting Week 2)

Every Sunday, both leads:

1. Open a PR from `dev` → `main`.
2. Both review and approve.
3. Merge (squash merge preferred to keep `main` history clean).
4. Both pull `main` locally and verify build passes.

```bash
git checkout main
git pull origin main
git checkout dev
git merge main        # keep dev in sync
git push origin dev
```

---

## 7. First-Commit Checklist

Complete all items before closing M0. Check off as done.

**Repository**
- [ ] Repo created as private under Sikhay organization
- [ ] Valiger collaborator added with Write access
- [ ] `main` branch protection rules set
- [ ] `dev` branch protection rules set
- [ ] All M0 branches created and pushed

**Firmware track (Sikhay)**
- [ ] VSCode + PlatformIO installed and `pio --version` returns output
- [ ] USB driver installed, ESP32 detected by OS
- [ ] `firmware/platformio.ini` committed to `dev`
- [ ] `pio run` completes without toolchain errors (empty source is fine)
- [ ] Serial monitor connects to board at 115200 baud

**App track (Valiger)**
- [ ] Flutter SDK installed, `flutter doctor` all green
- [ ] Physical Android device connected, USB debugging enabled
- [ ] `app/pubspec.yaml` committed to `dev`
- [ ] `flutter pub get` completes without errors
- [ ] `flutter run` launches on physical device

**Shared**
- [ ] `.gitignore` committed to `dev`
- [ ] `CONTRIBUTING.md` populated (copy from README)
- [ ] `LICENSE` populated
- [ ] Both leads have SSH auth working (`ssh -T git@github.com` succeeds)
- [ ] Both leads have cloned the repo and can push to their respective feature branches
- [ ] `docs/ble_contract.md` stub committed to `docs/ble-contract` branch — ready for M1

---

## 8. M0 Sign-Off

Once every item in Section 7 is checked, both leads confirm below by committing a change to this file on `dev` replacing the placeholder with their name and date.

```markdown
| Role            | Name | GitHub Handle | Sign-off Date |
|-----------------|------|---------------|---------------|
| Firmware Lead   | Henry Gabriel Buban (Sikhay) | @sikhayprs-gif| July 21, 2026 |
| App Lead        | Rica Marie Victorio (Valiger)| @Valiger      | July 21, 2026 |
```

**M0 is closed when both sign-offs are committed to `dev` and this file is merged to `main`.**

> M1 begins immediately after — the next deliverable is `docs/ble_contract.md` v1.0, locked with dual approval.

---

<div align="center">

**Sikhay Research, Development and Prototyping × Valiger**
*Internal — Proprietary and Confidential · © 2026 All rights reserved*

</div>

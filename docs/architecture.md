# RADIAN System Architecture

> **Version:** 1.0  
> **Sikhay and Valiger Collaboration**  
> **Date:** July 17, 2026

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Firmware Architecture](#2-firmware-architecture)
3. [BLE Communication Layer](#3-ble-communication-layer)
4. [App Architecture](#4-app-architecture)
5. [Data Flow — End to End](#5-data-flow--end-to-end)
6. [Error Handling](#6-error-handling)

---

## 1. System Overview

RADIAN is a two-component system: an ESP32-based hardware device and a Flutter mobile companion application. They communicate exclusively over Bluetooth Low Energy (BLE). Neither component depends on the internet, a backend server, or cloud storage — the entire system operates offline, peer-to-peer between the device and the phone.

```
┌─────────────────────────┐         BLE (GATT)        ┌──────────────────────────┐
│     RADIAN Device       │ ────── notify/read ──────► │   Companion App          │
│     (ESP32-WROOM-32)    │                             │   (Flutter / Android)    │
│                         │                             │                          │
│  AS5600 encoder ──►     │                             │  ble_manager.dart        │
│  ModeManager    ──►     │                             │  radian_packet.dart      │
│  BLEService     ──►     │  JSON payload @ 20Hz        │  Riverpod providers      │
│  OLED display           │                             │  CustomPainter canvas    │
└─────────────────────────┘                             └──────────────────────────┘
```

---

## 2. Firmware Architecture

### Layer Model

```
┌─────────────────────────────────────┐
│           main.cpp                  │  ← Entry point, 20Hz loop
├─────────────────────────────────────┤
│           ModeManager               │  ← Active mode, payload builder
├────────────┬────────────────────────┤
│ Mode1      │ Mode2   │ Mode3 │ Mode4 │  ← Compute layer (pure math)
├────────────┴────────────────────────┤
│           BLEService                │  ← Radio layer (NimBLE, JSON)
├─────────────────────────────────────┤
│      EncoderA      │   EncoderB     │  ← Sensor layer (I2C, AS5600)
└─────────────────────────────────────┘
```

### Loop Execution — 50ms (20Hz)

```
loop()
  │
  ├── EncoderA.readAngle()        → float a1 (0.0–359.9°)
  ├── EncoderB.readAngle()        → float a2 (0.0–359.9°, or 0.0 if not connected)
  ├── ModeManager.compute(a1, a2) → ComputedPayload
  └── BLEService.notify(payload)  → JSON string over BLE notify
```

### Mode Compute Layer

Each mode is a stateless class with a single `compute()` method. No mode holds state — all state lives in `ModeManager`.

| Class | Input | Output |
|---|---|---|
| `Mode1_DegRad` | `float degrees` | radians, cos, sin |
| `Mode2_VectorAdd` | `float a1, a2` | resultant magnitude, angle, components |
| `Mode3_RotMatrix` | `float theta, a2` | rotation matrix, transformed vector |
| `Mode4_PolygonSnap` | `float degrees, int n` | snapped angle, interior, exterior, central |

### ModeManager

Owns the active mode integer and polygon N. On each tick, routes `a1` and `a2` to the correct mode class and packages the result into a `ComputedPayload` struct that `BLEService` serializes.

---

## 3. BLE Communication Layer

### Protocol

```
Device role:  GATT Server (Peripheral)
App role:     GATT Client (Central)

Service UUID:    4a2b0001-0000-1000-8000-00805f9b34fb
Characteristic:  4a2b0002-0000-1000-8000-00805f9b34fb
Properties:      Notify + Read
Notify interval: 50ms (20Hz)
Payload:         JSON string, UTF-8, ≤ 100 bytes
```

### Connection Lifecycle

```
Device powers on
  │
  └── BLEService.begin()
        ├── NimBLEDevice::init("RADIAN")
        ├── Create GATT service + characteristic
        └── Start advertising

App opens
  │
  └── BLEManager.startScan()
        ├── Filter by service UUID 4a2b0001...
        ├── Display found devices
        └── User taps connect

Connection established
  │
  ├── Device: onConnect() → _connected = true
  ├── App: onConnected() → subscribe to notify
  └── Data flows at 20Hz until disconnect

Disconnect
  │
  ├── Device: onDisconnect() → restart advertising
  └── App: onDisconnected() → show reconnect UI
```

### Payload Structure

See `docs/ble_contract.md` for the full field reference. Summary:

```json
{
  "mode": 1,
  "a1": 47.3,
  "a2": 0.0,
  "val": { "rad": 0.825, "rx": 0.682, "ry": 0.731 },
  "ts": 1720863600
}
```

---

## 4. App Architecture

### Layer Model

```
┌─────────────────────────────────────┐
│         Screens (UI layer)          │  ← go_router, screen widgets
├─────────────────────────────────────┤
│      Painters (Canvas layer)        │  ← CustomPainter per mode
├─────────────────────────────────────┤
│      Providers (State layer)        │  ← Riverpod, derived state
├─────────────────────────────────────┤
│      RadianPacket (Model layer)     │  ← Typed BLE payload model
├─────────────────────────────────────┤
│      BLEManager (Data layer)        │  ← flutter_blue_plus, raw stream
└─────────────────────────────────────┘
```

### State Flow

```
BLEManager
  │  raw BLE notify bytes
  ▼
radian_packet.dart (RadianPacket.fromJson)
  │  typed RadianPacket object
  ▼
Riverpod StreamProvider<RadianPacket>
  │  reactive state
  ▼
Screen widgets (ref.watch)
  │  rebuild on change
  ▼
CustomPainter (canvas.drawX)
  │  visual output
  ▼
User sees live visualization
```

### Routing — go_router

```
/                   → ScanScreen
/connect/:deviceId  → ConnectingScreen
/home               → HomeScreen (mode selector + live readout)
/mode/1             → Mode1Screen (unit circle)
/mode/2             → Mode2Screen (vector addition)
/mode/3             → Mode3Screen (rotation matrix)
/mode/4             → Mode4Screen (polygon snap)
/settings           → SettingsScreen
```

### Key Files

| File | Role |
|---|---|
| `lib/main.dart` | App entry, MaterialApp, router, theme provider |
| `lib/app_theme.dart` | Three ThemeData objects + RadianCanvasTheme extension |
| `lib/ble/ble_manager.dart` | BLE scan, connect, notify stream |
| `lib/ble/radian_packet.dart` | JSON → typed Dart model |
| `lib/providers/` | Riverpod providers for packet stream, theme, mode |
| `lib/screens/` | One file per route |
| `lib/widgets/painters/` | One CustomPainter per mode |

---

## 5. Data Flow — End to End

```
Physical rotation of arm
        │
        ▼
AS5600 encoder reads raw 12-bit value (0–4095)
        │
        ▼  (raw / 4096.0) × 360.0
float angle in degrees (0.0–359.9)
        │
        ▼
ModeManager.compute(a1, a2)
        │
        ▼
ComputedPayload struct populated
        │
        ▼
ArduinoJson serializes to JSON string (≤ 100 bytes)
        │
        ▼
NimBLE notify characteristic → BLE radio
        │
        ▼  (over-the-air, ~50ms)
flutter_blue_plus onValueReceived stream
        │
        ▼
RadianPacket.fromJson(jsonString)
        │
        ▼
Riverpod StreamProvider emits new packet
        │
        ▼
Screen widget rebuilds (ref.watch)
        │
        ▼
CustomPainter.paint() called with new data
        │
        ▼
Canvas redraws — student sees live visualization
```

**Total latency:** encoder read → canvas redraw is approximately 50–80ms under normal BLE conditions. This feels instantaneous to a student.

---

## 6. Error Handling

| Scenario | Firmware Behavior | App Behavior |
|---|---|---|
| Encoder not connected | Returns 0.0°, logs to serial | Shows 0.0° — no crash |
| EncoderB not found | Returns 0.0° for a2 | Single-arm mode, a2 fields ignored |
| BLE client disconnects | Restarts advertising automatically | Shows reconnect UI, retries |
| JSON payload > 100 bytes | Will not occur by design | Packet dropped, previous state held |
| Mode out of range (not 1–4) | Clamped by ModeManager | Ignored, previous mode held |
| Polygon N out of range | Clamped to 3–12 by clampN() | N stepper bounded in UI |

---

<div align="center">

**Sikhay Research, Development and Prototyping and Valiger**  
*Internal — Proprietary and Confidential · © 2026 All rights reserved*

</div>

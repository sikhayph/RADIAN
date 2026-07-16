# BLE Contract — RADIAN

**Version:** 1.0 | **Status:** Locked for v1 — changes require dual approval
**Authors:** Henry Gabriel Buban (Sikhay) × Valiger Lead
**Date:** July 13, 2026

---

## Service

| Property        | Value                               |
|-----------------|-------------------------------------|
| Service UUID    | `4A2B-RADIAN-0001` (custom 128-bit) |
| Characteristic  | `ANGLE_DATA`                        |
| Properties      | Notify, Read                        |
| Notify interval | ~50 ms (20 Hz)                      |
| Encoding        | JSON string, UTF-8, ≤ 100 bytes     |

---

## Payload

```json
{
  "mode": 1,
  "a1":   47.3,
  "a2":   112.8,
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

---

## Field Definitions

| Field     | Type  | Description                              |
|-----------|-------|------------------------------------------|
| mode      | int   | Active mode (1–4)                        |
| a1        | float | Arm 1 angle, degrees, 0–359.9           |
| a2        | float | Arm 2 angle; 0.0 if single-arm mode     |
| val.rad   | float | Mode 1: radian equivalent of a1         |
| val.rx    | float | Mode 1/3: cos(a1)                       |
| val.ry    | float | Mode 1/3: sin(a1)                       |
| val.rmag  | float | Mode 2: resultant vector magnitude      |
| val.rang  | float | Mode 2: resultant angle, degrees        |
| val.snap  | int   | Mode 4: selected polygon N              |
| val.int   | float | Mode 4: interior angle of N-gon         |
| val.ext   | float | Mode 4: exterior angle of N-gon         |
| ts        | long  | ESP32 millis() at time of reading        |

---

## Change Process

1. Open a GitHub issue tagged `ble-contract`.
2. Both firmware lead and app lead comment approval.
3. PR updates this file AND `app/lib/ble/radian_packet.dart` in the same commit.
4. No merge without both approvals.

---

## Sign-Off

> This contract is locked once both leads sign off below.
> To sign off — open a PR from `docs/ble-contract` → `dev` and approve it.

| Role          | Name                         | GitHub Handle       | Sign-off |
|---------------|------------------------------|---------------------|----------|
| Firmware Lead | Henry Gabriel Buban (Sikhay) | @sikhayprs-gif      | ⬜        |
| App Lead      | (Valiger lead)               | @valiger            | ⬜        |

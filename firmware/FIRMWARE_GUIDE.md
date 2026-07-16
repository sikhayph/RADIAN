# RADIAN Firmware — Full Folder Guide & Code

> **Track:** Sikhay (Henry Gabriel Buban)
> **Branch:** `feature/firmware-mode1-degrad` → `feature/firmware-ble-service`
> **Last updated:** July 16, 2026

---

## Folder Structure

```
firmware/
├── src/
│   ├── main.cpp                    ← Entry point, setup() and loop()
│   ├── ble/
│   │   ├── BLEService.h            ← BLE class declaration
│   │   └── BLEService.cpp          ← BLE init, notify, broadcast
│   ├── modes/
│   │   ├── ModeManager.h           ← Mode switching logic declaration
│   │   ├── ModeManager.cpp         ← Mode switching logic
│   │   ├── Mode1_DegRad.h          ← Mode 1 struct + class declaration
│   │   ├── Mode1_DegRad.cpp        ← Degree/radian compute
│   │   ├── Mode2_VectorAdd.h       ← Mode 2 struct + class declaration
│   │   ├── Mode2_VectorAdd.cpp     ← Vector addition compute
│   │   ├── Mode3_RotMatrix.h       ← Mode 3 struct + class declaration
│   │   ├── Mode3_RotMatrix.cpp     ← Rotation matrix compute
│   │   ├── Mode4_PolygonSnap.h     ← Mode 4 struct + class declaration
│   │   └── Mode4_PolygonSnap.cpp   ← Polygon snap compute
│   └── sensors/
│       ├── EncoderA.h              ← Arm 1 encoder declaration
│       ├── EncoderA.cpp            ← Arm 1 AS5600 reader (0x36)
│       ├── EncoderB.h              ← Arm 2 encoder declaration
│       └── EncoderB.cpp            ← Arm 2 AS5600 reader (0x37)
├── include/                        ← Shared constants and config
│   └── config.h                    ← Pin definitions, BLE UUIDs, constants
├── test/                           ← Unit tests (PlatformIO test runner)
│   └── test_modes.cpp              ← Math verification tests
└── platformio.ini                  ← PlatformIO project config
```

---

## File Execution Flow

```
main.cpp
  │
  ├── setup()
  │     ├── Wire.begin()           ← I2C for encoders
  │     ├── EncoderA.begin()       ← Arm 1 sensor init
  │     ├── EncoderB.begin()       ← Arm 2 sensor init
  │     ├── BLEService.begin()     ← BLE stack init + advertise
  │     └── ModeManager.begin()    ← Set default mode to 1
  │
  └── loop()  [every 50ms = 20Hz]
        ├── EncoderA.readAngle()   ← Get arm 1 angle
        ├── EncoderB.readAngle()   ← Get arm 2 angle
        ├── ModeManager.compute()  ← Run active mode math
        └── BLEService.notify()    ← Broadcast JSON payload
```

---

## `include/config.h`

```cpp
#pragma once

// ── I2C ──────────────────────────────────────────────
#define I2C_SDA         21
#define I2C_SCL         22

// ── AS5600 Encoder Addresses ─────────────────────────
#define ENCODER_A_ADDR  0x36    // Arm 1
#define ENCODER_B_ADDR  0x37    // Arm 2 (via TCA9548A mux)

// ── AS5600 Registers ─────────────────────────────────
#define RAW_ANGLE_H     0x0C
#define RAW_ANGLE_L     0x0D

// ── BLE ──────────────────────────────────────────────
#define BLE_DEVICE_NAME     "RADIAN"
#define BLE_SERVICE_UUID    "4a2b0001-0000-1000-8000-00805f9b34fb"
#define BLE_CHAR_UUID       "4a2b0002-0000-1000-8000-00805f9b34fb"

// ── Timing ───────────────────────────────────────────
#define LOOP_INTERVAL_MS    50      // 20Hz

// ── Modes ────────────────────────────────────────────
#define MODE_DEGRAD         1
#define MODE_VECTOR         2
#define MODE_ROTMATRIX      3
#define MODE_POLYGON        4
#define MODE_DEFAULT        MODE_DEGRAD

// ── Math ─────────────────────────────────────────────
#define DEG_TO_RAD_FACTOR   0.017453292519943f
#define RAD_TO_DEG_FACTOR   57.29577951308232f
```

---

## `firmware/platformio.ini`

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

monitor_speed = 115200
upload_speed  = 921600
build_flags   = -DCORE_DEBUG_LEVEL=0
```

---

## `firmware/src/sensors/EncoderA.h`

```cpp
#pragma once
#include <Arduino.h>

class EncoderA {
public:
    void  begin();
    float readAngle();      // returns 0.0 – 359.9 degrees
    bool  isConnected();

private:
    bool  _connected = false;
};
```

---

## `firmware/src/sensors/EncoderA.cpp`

```cpp
#include "EncoderA.h"
#include "../../include/config.h"
#include <Wire.h>

void EncoderA::begin() {
    Wire.begin(I2C_SDA, I2C_SCL);
    Wire.beginTransmission(ENCODER_A_ADDR);
    _connected = (Wire.endTransmission() == 0);

    if (_connected) {
        Serial.println("[EncoderA] Connected at 0x36");
    } else {
        Serial.println("[EncoderA] NOT FOUND at 0x36");
    }
}

float EncoderA::readAngle() {
    if (!_connected) return 0.0f;

    Wire.beginTransmission(ENCODER_A_ADDR);
    Wire.write(RAW_ANGLE_H);
    Wire.endTransmission(false);
    Wire.requestFrom(ENCODER_A_ADDR, 2);

    if (Wire.available() < 2) return 0.0f;

    uint16_t raw = ((uint16_t)Wire.read() << 8) | Wire.read();
    return (raw / 4096.0f) * 360.0f;
}

bool EncoderA::isConnected() {
    return _connected;
}
```

---

## `firmware/src/sensors/EncoderB.h`

```cpp
#pragma once
#include <Arduino.h>

class EncoderB {
public:
    void  begin();
    float readAngle();
    bool  isConnected();

private:
    bool  _connected = false;
};
```

---

## `firmware/src/sensors/EncoderB.cpp`

```cpp
#include "EncoderB.h"
#include "../../include/config.h"
#include <Wire.h>

// EncoderB reads from 0x37 via TCA9548A I2C mux
// In v2 single-encoder builds, this returns 0.0 safely

void EncoderB::begin() {
    Wire.beginTransmission(ENCODER_B_ADDR);
    _connected = (Wire.endTransmission() == 0);

    if (_connected) {
        Serial.println("[EncoderB] Connected at 0x37");
    } else {
        Serial.println("[EncoderB] Not found — single-arm mode");
    }
}

float EncoderB::readAngle() {
    if (!_connected) return 0.0f;

    Wire.beginTransmission(ENCODER_B_ADDR);
    Wire.write(RAW_ANGLE_H);
    Wire.endTransmission(false);
    Wire.requestFrom(ENCODER_B_ADDR, 2);

    if (Wire.available() < 2) return 0.0f;

    uint16_t raw = ((uint16_t)Wire.read() << 8) | Wire.read();
    return (raw / 4096.0f) * 360.0f;
}

bool EncoderB::isConnected() {
    return _connected;
}
```

---

## `firmware/src/modes/Mode1_DegRad.h`

```cpp
#pragma once

struct Mode1Data {
    float degrees;
    float radians;
    float cosVal;
    float sinVal;
};

class Mode1_DegRad {
public:
    Mode1Data compute(float degrees);
};
```

---

## `firmware/src/modes/Mode1_DegRad.cpp`

```cpp
#include "Mode1_DegRad.h"
#include "../../include/config.h"
#include <math.h>

Mode1Data Mode1_DegRad::compute(float degrees) {
    Mode1Data data;
    data.degrees = degrees;
    data.radians = degrees * DEG_TO_RAD_FACTOR;
    data.cosVal  = cosf(data.radians);
    data.sinVal  = sinf(data.radians);
    return data;
}
```

---

## `firmware/src/modes/Mode2_VectorAdd.h`

```cpp
#pragma once

struct Mode2Data {
    float a1;           // arm 1 angle degrees
    float a2;           // arm 2 angle degrees
    float v1x, v1y;     // arm 1 components
    float v2x, v2y;     // arm 2 components
    float rx,  ry;      // resultant components
    float rmag;         // resultant magnitude
    float rang;         // resultant angle degrees
};

class Mode2_VectorAdd {
public:
    Mode2Data compute(float a1, float a2);
};
```

---

## `firmware/src/modes/Mode2_VectorAdd.cpp`

```cpp
#include "Mode2_VectorAdd.h"
#include "../../include/config.h"
#include <math.h>

Mode2Data Mode2_VectorAdd::compute(float a1, float a2) {
    Mode2Data data;
    data.a1 = a1;
    data.a2 = a2;

    // Unit vectors for each arm
    data.v1x = cosf(a1 * DEG_TO_RAD_FACTOR);
    data.v1y = sinf(a1 * DEG_TO_RAD_FACTOR);
    data.v2x = cosf(a2 * DEG_TO_RAD_FACTOR);
    data.v2y = sinf(a2 * DEG_TO_RAD_FACTOR);

    // Resultant
    data.rx   = data.v1x + data.v2x;
    data.ry   = data.v1y + data.v2y;
    data.rmag = sqrtf(data.rx * data.rx + data.ry * data.ry);
    data.rang = atan2f(data.ry, data.rx) * RAD_TO_DEG_FACTOR;

    if (data.rang < 0) data.rang += 360.0f;

    return data;
}
```

---

## `firmware/src/modes/Mode3_RotMatrix.h`

```cpp
#pragma once

struct Mode3Data {
    float theta;        // rotation angle degrees
    float r00, r01;     // rotation matrix row 0
    float r10, r11;     // rotation matrix row 1
    float vx,  vy;      // original arm 2 vector
    float vxp, vyp;     // transformed vector
};

class Mode3_RotMatrix {
public:
    Mode3Data compute(float theta, float a2);
};
```

---

## `firmware/src/modes/Mode3_RotMatrix.cpp`

```cpp
#include "Mode3_RotMatrix.h"
#include "../../include/config.h"
#include <math.h>

Mode3Data Mode3_RotMatrix::compute(float theta, float a2) {
    Mode3Data data;
    data.theta = theta;

    float rad = theta * DEG_TO_RAD_FACTOR;

    // Rotation matrix R(theta)
    data.r00 =  cosf(rad);
    data.r01 = -sinf(rad);
    data.r10 =  sinf(rad);
    data.r11 =  cosf(rad);

    // Arm 2 as input vector
    data.vx = cosf(a2 * DEG_TO_RAD_FACTOR);
    data.vy = sinf(a2 * DEG_TO_RAD_FACTOR);

    // Apply rotation matrix
    data.vxp = data.r00 * data.vx + data.r01 * data.vy;
    data.vyp = data.r10 * data.vx + data.r11 * data.vy;

    return data;
}
```

---

## `firmware/src/modes/Mode4_PolygonSnap.h`

```cpp
#pragma once

struct Mode4Data {
    int   n;            // polygon sides
    float snappedAngle; // nearest multiple of 360/n
    float interior;     // interior angle degrees
    float exterior;     // exterior angle degrees
    float central;      // central angle degrees
};

class Mode4_PolygonSnap {
public:
    Mode4Data compute(float degrees, int n);
    int       clampN(int n);  // keeps n between 3 and 12
};
```

---

## `firmware/src/modes/Mode4_PolygonSnap.cpp`

```cpp
#include "Mode4_PolygonSnap.h"
#include <math.h>

int Mode4_PolygonSnap::clampN(int n) {
    if (n < 3)  return 3;
    if (n > 12) return 12;
    return n;
}

Mode4Data Mode4_PolygonSnap::compute(float degrees, int n) {
    Mode4Data data;
    n = clampN(n);
    data.n = n;

    float step = 360.0f / n;

    // Snap to nearest multiple of step
    data.snappedAngle = roundf(degrees / step) * step;

    data.central  = step;
    data.interior = (float)(n - 2) * 180.0f / n;
    data.exterior = 360.0f / n;

    return data;
}
```

---

## `firmware/src/modes/ModeManager.h`

```cpp
#pragma once
#include "Mode1_DegRad.h"
#include "Mode2_VectorAdd.h"
#include "Mode3_RotMatrix.h"
#include "Mode4_PolygonSnap.h"
#include "../../include/config.h"

struct ComputedPayload {
    int   mode;
    float a1;
    float a2;
    // Mode 1
    float rad;
    float rx, ry;
    // Mode 2
    float rmag, rang;
    // Mode 4
    int   snap;
    float interior, exterior;
    unsigned long ts;
};

class ModeManager {
public:
    void           begin();
    void           setMode(int mode);
    int            getMode();
    void           nextMode();
    int            getPolygonN();
    void           incrementN();
    void           decrementN();
    ComputedPayload compute(float a1, float a2);

private:
    int _mode     = MODE_DEFAULT;
    int _polygonN = 6;

    Mode1_DegRad    _mode1;
    Mode2_VectorAdd _mode2;
    Mode3_RotMatrix _mode3;
    Mode4_PolygonSnap _mode4;
};
```

---

## `firmware/src/modes/ModeManager.cpp`

```cpp
#include "ModeManager.h"
#include <Arduino.h>

void ModeManager::begin() {
    _mode     = MODE_DEFAULT;
    _polygonN = 6;
    Serial.println("[ModeManager] Ready — default Mode 1");
}

void ModeManager::setMode(int mode) {
    if (mode >= 1 && mode <= 4) {
        _mode = mode;
        Serial.print("[ModeManager] Switched to Mode ");
        Serial.println(_mode);
    }
}

int ModeManager::getMode() { return _mode; }

void ModeManager::nextMode() {
    _mode = (_mode % 4) + 1;
    Serial.print("[ModeManager] Mode → "); Serial.println(_mode);
}

int  ModeManager::getPolygonN()  { return _polygonN; }
void ModeManager::incrementN()   { if (_polygonN < 12) _polygonN++; }
void ModeManager::decrementN()   { if (_polygonN > 3)  _polygonN--; }

ComputedPayload ModeManager::compute(float a1, float a2) {
    ComputedPayload p;
    p.mode = _mode;
    p.a1   = a1;
    p.a2   = a2;
    p.ts   = millis();

    switch (_mode) {
        case MODE_DEGRAD: {
            Mode1Data d = _mode1.compute(a1);
            p.rad = d.radians;
            p.rx  = d.cosVal;
            p.ry  = d.sinVal;
            break;
        }
        case MODE_VECTOR: {
            Mode2Data d = _mode2.compute(a1, a2);
            p.rmag = d.rmag;
            p.rang = d.rang;
            p.rx   = d.rx;
            p.ry   = d.ry;
            break;
        }
        case MODE_ROTMATRIX: {
            Mode3Data d = _mode3.compute(a1, a2);
            p.rx = d.vxp;
            p.ry = d.vyp;
            break;
        }
        case MODE_POLYGON: {
            Mode4Data d = _mode4.compute(a1, _polygonN);
            p.snap     = d.n;
            p.interior = d.interior;
            p.exterior = d.exterior;
            break;
        }
    }

    return p;
}
```

---

## `firmware/src/ble/BLEService.h`

```cpp
#pragma once
#include <NimBLEDevice.h>
#include "../modes/ModeManager.h"

class BLEServiceRADIAN {
public:
    void begin();
    void notify(ComputedPayload& payload);
    bool isConnected();

private:
    NimBLEServer*         _server        = nullptr;
    NimBLECharacteristic* _characteristic = nullptr;
    bool                  _connected     = false;

    String buildJSON(ComputedPayload& p);
};
```

---

## `firmware/src/ble/BLEService.cpp`

```cpp
#include "BLEService.h"
#include "../../include/config.h"
#include <ArduinoJson.h>

class ServerCallbacks : public NimBLEServerCallbacks {
public:
    bool* connected;
    void onConnect(NimBLEServer* s) override {
        *connected = true;
        Serial.println("[BLE] Client connected");
    }
    void onDisconnect(NimBLEServer* s) override {
        *connected = false;
        Serial.println("[BLE] Client disconnected — restarting advertising");
        s->startAdvertising();
    }
};

void BLEServiceRADIAN::begin() {
    NimBLEDevice::init(BLE_DEVICE_NAME);
    NimBLEDevice::setPower(ESP_PWR_LVL_P9);

    _server = NimBLEDevice::createServer();

    auto* cb = new ServerCallbacks();
    cb->connected = &_connected;
    _server->setCallbacks(cb);

    NimBLEService* service = _server->createService(BLE_SERVICE_UUID);

    _characteristic = service->createCharacteristic(
        BLE_CHAR_UUID,
        NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::NOTIFY
    );

    service->start();

    NimBLEAdvertising* adv = NimBLEDevice::getAdvertising();
    adv->addServiceUUID(BLE_SERVICE_UUID);
    adv->start();

    Serial.println("[BLE] Advertising as RADIAN");
}

String BLEServiceRADIAN::buildJSON(ComputedPayload& p) {
    StaticJsonDocument<200> doc;
    doc["mode"] = p.mode;
    doc["a1"]   = serialized(String(p.a1, 1));
    doc["a2"]   = serialized(String(p.a2, 1));

    JsonObject val = doc.createNestedObject("val");
    val["rad"]  = serialized(String(p.rad,  3));
    val["rx"]   = serialized(String(p.rx,   3));
    val["ry"]   = serialized(String(p.ry,   3));
    val["rmag"] = serialized(String(p.rmag, 2));
    val["rang"] = serialized(String(p.rang, 2));
    val["snap"] = p.snap;
    val["int"]  = serialized(String(p.interior, 1));
    val["ext"]  = serialized(String(p.exterior, 1));

    doc["ts"] = p.ts;

    String output;
    serializeJson(doc, output);
    return output;
}

void BLEServiceRADIAN::notify(ComputedPayload& payload) {
    if (!_connected) return;
    String json = buildJSON(payload);
    _characteristic->setValue(json.c_str());
    _characteristic->notify();
}

bool BLEServiceRADIAN::isConnected() {
    return _connected;
}
```

---

## `firmware/src/main.cpp`

```cpp
#include <Arduino.h>
#include "sensors/EncoderA.h"
#include "sensors/EncoderB.h"
#include "modes/ModeManager.h"
#include "ble/BLEService.h"
#include "../include/config.h"

EncoderA        encoderA;
EncoderB        encoderB;
ModeManager     modeManager;
BLEServiceRADIAN bleService;

unsigned long lastLoop = 0;

void setup() {
    Serial.begin(115200);
    Serial.println("=== RADIAN Firmware v0.1 ===");

    encoderA.begin();
    encoderB.begin();
    modeManager.begin();
    bleService.begin();

    Serial.println("=== Ready ===");
}

void loop() {
    unsigned long now = millis();
    if (now - lastLoop < LOOP_INTERVAL_MS) return;
    lastLoop = now;

    float a1 = encoderA.readAngle();
    float a2 = encoderB.readAngle();

    ComputedPayload payload = modeManager.compute(a1, a2);
    bleService.notify(payload);

    // Serial debug
    Serial.print("Mode:"); Serial.print(payload.mode);
    Serial.print(" A1:"); Serial.print(payload.a1, 1);
    Serial.print(" A2:"); Serial.print(payload.a2, 1);
    Serial.print(" rad:"); Serial.print(payload.rad, 3);
    Serial.print(" BLE:"); Serial.println(bleService.isConnected() ? "connected" : "waiting");
}
```

---

## `firmware/test/test_modes.cpp`

```cpp
#include <unity.h>
#include "../src/modes/Mode1_DegRad.h"
#include "../src/modes/Mode2_VectorAdd.h"
#include "../src/modes/Mode4_PolygonSnap.h"

Mode1_DegRad    mode1;
Mode2_VectorAdd mode2;
Mode4_PolygonSnap mode4;

void test_mode1_90_degrees() {
    Mode1Data d = mode1.compute(90.0f);
    TEST_ASSERT_FLOAT_WITHIN(0.001f, 1.5708f, d.radians);
    TEST_ASSERT_FLOAT_WITHIN(0.001f, 0.0f,   d.cosVal);
    TEST_ASSERT_FLOAT_WITHIN(0.001f, 1.0f,   d.sinVal);
}

void test_mode1_0_degrees() {
    Mode1Data d = mode1.compute(0.0f);
    TEST_ASSERT_FLOAT_WITHIN(0.001f, 0.0f,  d.radians);
    TEST_ASSERT_FLOAT_WITHIN(0.001f, 1.0f,  d.cosVal);
    TEST_ASSERT_FLOAT_WITHIN(0.001f, 0.0f,  d.sinVal);
}

void test_mode2_resultant_magnitude() {
    // Two vectors at 0 and 90 degrees — resultant should be sqrt(2)
    Mode2Data d = mode2.compute(0.0f, 90.0f);
    TEST_ASSERT_FLOAT_WITHIN(0.01f, 1.414f, d.rmag);
}

void test_mode4_hexagon() {
    Mode4Data d = mode4.compute(0.0f, 6);
    TEST_ASSERT_EQUAL_INT(6, d.n);
    TEST_ASSERT_FLOAT_WITHIN(0.01f, 120.0f, d.interior);
    TEST_ASSERT_FLOAT_WITHIN(0.01f,  60.0f, d.exterior);
    TEST_ASSERT_FLOAT_WITHIN(0.01f,  60.0f, d.central);
}

int main(int argc, char **argv) {
    UNITY_BEGIN();
    RUN_TEST(test_mode1_0_degrees);
    RUN_TEST(test_mode1_90_degrees);
    RUN_TEST(test_mode2_resultant_magnitude);
    RUN_TEST(test_mode4_hexagon);
    return UNITY_END();
}
```

---

## Coding Order

Follow this sequence — each step builds on the previous:

| Step | File(s) | Command to test |
|---|---|---|
| 1 | `include/config.h` | No test yet — just save |
| 2 | `EncoderA.h` + `.cpp` | `pio run` — should compile |
| 3 | `EncoderB.h` + `.cpp` | `pio run` — should compile |
| 4 | `Mode1_DegRad.h` + `.cpp` | `pio test` |
| 5 | `Mode2_VectorAdd.h` + `.cpp` | `pio test` |
| 6 | `Mode3_RotMatrix.h` + `.cpp` | `pio test` |
| 7 | `Mode4_PolygonSnap.h` + `.cpp` | `pio test` |
| 8 | `ModeManager.h` + `.cpp` | `pio run` |
| 9 | `BLEService.h` + `.cpp` | `pio run --target upload` |
| 10 | `main.cpp` | `pio run --target upload` then `pio device monitor` |

---

## Push as You Go

```powershell
# After each step
git add .
git commit -m "feat(firmware): <what you just did>"
git push origin feature/firmware-mode1-degrad
```

Example commit messages:
```
feat(firmware): add config.h with pin definitions and BLE UUIDs
feat(firmware): add EncoderA AS5600 reader with connection check
feat(firmware): add Mode1 degree to radian compute with cos/sin
feat(firmware): add Mode2 vector addition with resultant
feat(firmware): add Mode3 rotation matrix compute
feat(firmware): add Mode4 polygon snap with interior/exterior angles
feat(firmware): add ModeManager switching and payload builder
feat(firmware): add BLEService NimBLE broadcast with JSON payload
feat(firmware): wire all modules in main.cpp — v0.1 complete
```

---

<div align="center">

**Sikhay Research, Development and Prototyping × Valiger**
*Internal — Proprietary and Confidential · © 2026 All rights reserved*

</div>

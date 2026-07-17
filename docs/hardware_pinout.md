# RADIAN Hardware Pinout

> **Version:** 1.0  
> **Sikhay and Valiger Collaboration**  
> **Date:** July 17, 2026

---

## Board — ESP32-WROOM-32 DevKit V1

```
                        ┌─────────────────┐
                 3.3V  ─┤ 3V3         GND ├─  GND
                  GND  ─┤ GND          23 ├─  
                   15  ─┤ D15          22 ├─  SCL  ◄── AS5600 (both encoders)
                    2  ─┤ D2           TX ├─  
                    4  ─┤ D4           RX ├─  
                   16  ─┤ RX2          21 ├─  SDA  ◄── AS5600 (both encoders)
                   17  ─┤ TX2          19 ├─  
                    5  ─┤ D5           18 ├─  
                   18  ─┤ D18           5 ├─  
                   19  ─┤ D19          17 ├─  
                   21  ─┤ D21          16 ├─  
                   RX  ─┤ RX0           4 ├─  
                   TX  ─┤ TX0           0 ├─  
                   22  ─┤ D22           2 ├─  
                   23  ─┤ D23          15 ├─  
                        └─────────────────┘
                               │ USB
```

---

## Pin Assignments

| GPIO | Label | Connected To | Notes |
|---|---|---|---|
| 21 | SDA | AS5600 SDA (both encoders) | I2C data line |
| 22 | SCL | AS5600 SCL (both encoders) | I2C clock line |
| 3.3V | Power | AS5600 VCC, OLED VCC | 3.3V rail — do not use 5V |
| GND | Ground | AS5600 GND, OLED GND, Battery GND | Common ground |
| USB | Power in | TP4056 output | 5V via USB-C charging module |

---

## I2C Devices

Both AS5600 encoders share the same I2C bus (SDA: GPIO21, SCL: GPIO22). They are differentiated by address:

| Device | I2C Address | Notes |
|---|---|---|
| EncoderA (Arm 1) | `0x36` | Default AS5600 address |
| EncoderB (Arm 2) | `0x37` | Requires TCA9548A I2C mux or address bridge resistor |
| OLED Display | `0x3C` | SSD1306 / SH1106 — standard address |

> ⚠️ **Address conflict:** The AS5600 only has one hardware address (`0x36`). To use two encoders on the same bus, use a **TCA9548A I2C multiplexer** — select channel 0 for EncoderA and channel 1 for EncoderB before each read.

---

## Power

| Component | Voltage | Source |
|---|---|---|
| ESP32 | 3.3V (internal regulator) | USB 5V or battery via regulator |
| AS5600 encoder | 3.3V | ESP32 3.3V pin |
| OLED display | 3.3V | ESP32 3.3V pin |
| TP4056 charger | 5V in, 4.2V out | USB-C port |
| 18650 cell | 3.7V nominal | TP4056 output |
| MT3608 boost | 5V out | 18650 cell input |

---

## AS5600 Wiring (Per Encoder)

```
AS5600 Pin    →    ESP32 Pin
──────────────────────────────
VCC           →    3.3V
GND           →    GND
SDA           →    GPIO 21
SCL           →    GPIO 22
DIR           →    GND (clockwise positive)
```

> The `DIR` pin sets rotation direction. Tie to GND for clockwise = increasing angle. Tie to 3.3V for counter-clockwise = increasing angle.

---

## OLED Wiring (SSD1306 / SH1106 — 0.96")

```
OLED Pin    →    ESP32 Pin
────────────────────────────
VCC         →    3.3V
GND         →    GND
SDA         →    GPIO 21
SCL         →    GPIO 22
```

---

## TCA9548A I2C Multiplexer (for dual encoder)

```
TCA9548A Pin    →    Connection
────────────────────────────────────────
VCC             →    3.3V
GND             →    GND
SDA             →    GPIO 21 (ESP32)
SCL             →    GPIO 22 (ESP32)
A0, A1, A2      →    GND (sets mux address to 0x70)
SD0, SC0        →    EncoderA SDA/SCL (channel 0)
SD1, SC1        →    EncoderB SDA/SCL (channel 1)
```

To select a channel before reading:

```cpp
// Select channel 0 (EncoderA)
Wire.beginTransmission(0x70);
Wire.write(1 << 0);
Wire.endTransmission();

// Select channel 1 (EncoderB)
Wire.beginTransmission(0x70);
Wire.write(1 << 1);
Wire.endTransmission();
```

---

## Power Wiring Diagram

```
USB-C port
    │
    ▼
TP4056 module
    │ (charge management + protection)
    ▼
18650 Li-ion cell
    │
    ▼
MT3608 boost converter
    │ (3.7V → 5V regulated)
    ▼
ESP32 VIN pin (5V in)
    │
    └── ESP32 onboard 3.3V regulator
              │
              ├── AS5600 EncoderA VCC
              ├── AS5600 EncoderB VCC (via TCA9548A)
              └── OLED VCC
```

---

## config.h Reference

All pin definitions and I2C addresses are centralized in `firmware/include/config.h`:

```cpp
#define I2C_SDA         21
#define I2C_SCL         22
#define ENCODER_A_ADDR  0x36
#define ENCODER_B_ADDR  0x37
#define RAW_ANGLE_H     0x0C
#define RAW_ANGLE_L     0x0D
```

> Never hardcode pin numbers or addresses in `.cpp` files — always use the `config.h` constants.

---

## Hardware Checklist (Before First Flash)

- [ ] ESP32 recognized by OS — check Device Manager (Windows) for COM port
- [ ] USB driver installed — CP210x or CH340 depending on board variant
- [ ] AS5600 encoder wired to GPIO 21 (SDA) and GPIO 22 (SCL)
- [ ] 3.3V and GND connected to encoder VCC and GND
- [ ] Magnet seated on encoder shaft — AS5600 requires a diametric magnet on the rotating axis
- [ ] `pio run --target upload` completes without error
- [ ] Serial monitor at 115200 baud shows `[EncoderA] Connected at 0x36`

---

<div align="center">

**Sikhay Research, Development and Prototyping and Valiger**  
*Internal — Proprietary and Confidential · © 2026 All rights reserved*

</div>
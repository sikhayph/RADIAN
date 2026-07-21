#pragma once

// ── I2C ──────────────────────────────────────────────
#define I2C_SDA         21
#define I2C_SCL         22

// ── AS5600 Encoder Addresses ─────────────────────────
#define ENCODER_A_ADDR  0x36
#define ENCODER_B_ADDR  0x37

// ── AS5600 Registers ─────────────────────────────────
#define RAW_ANGLE_H     0x0C
#define RAW_ANGLE_L     0x0D

// ── BLE ──────────────────────────────────────────────
#define BLE_DEVICE_NAME     "RADIAN"
#define BLE_SERVICE_UUID    "4a2b0001-0000-1000-8000-00805f9b34fb"
#define BLE_CHAR_UUID       "4a2b0002-0000-1000-8000-00805f9b34fb"

// ── Timing ───────────────────────────────────────────
#define LOOP_INTERVAL_MS    50

// ── Modes ────────────────────────────────────────────
#define MODE_DEGRAD         1
#define MODE_VECTOR         2
#define MODE_ROTMATRIX      3
#define MODE_POLYGON        4
#define MODE_DEFAULT        MODE_DEGRAD

// ── Math ─────────────────────────────────────────────
#define DEG_TO_RAD_FACTOR   0.017453292519943f
#define RAD_TO_DEG_FACTOR   57.29577951308232f
#include "EncoderB.h"
#include "../../include/config.h"
#include <Wire.h>

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
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
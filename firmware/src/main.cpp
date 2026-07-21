#include <Arduino.h>
#include "sensors/EncoderA.h"
#include "sensors/EncoderB.h"
#include "modes/ModeManager.h"
#include "ble/BLEService.h"
#include "../include/config.h"

EncoderA         encoderA;
EncoderB         encoderB;
ModeManager      modeManager;
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

    Serial.print("Mode:"); Serial.print(payload.mode);
    Serial.print(" A1:");  Serial.print(payload.a1, 1);
    Serial.print(" A2:");  Serial.print(payload.a2, 1);
    Serial.print(" rad:"); Serial.print(payload.rad, 3);
    Serial.print(" BLE:"); Serial.println(bleService.isConnected() ? "connected" : "waiting");
}
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

int  ModeManager::getMode()     { return _mode; }
int  ModeManager::getPolygonN() { return _polygonN; }
void ModeManager::incrementN()  { if (_polygonN < 12) _polygonN++; }
void ModeManager::decrementN()  { if (_polygonN > 3)  _polygonN--; }

void ModeManager::nextMode() {
    _mode = (_mode % 4) + 1;
    Serial.print("[ModeManager] Mode → ");
    Serial.println(_mode);
}

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
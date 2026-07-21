#pragma once
#include <NimBLEDevice.h>
#include "../modes/ModeManager.h"

class BLEServiceRADIAN {
public:
    void begin();
    void notify(ComputedPayload& payload);
    bool isConnected();

private:
    NimBLEServer*         _server         = nullptr;
    NimBLECharacteristic* _characteristic = nullptr;
    bool                  _connected      = false;

    String buildJSON(ComputedPayload& p);
};
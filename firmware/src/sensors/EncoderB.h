#pragma once
#include <Arduino.h>

class EncoderB {
public:
    void  begin();
    float readAngle();
    bool  isConnected();

private:
    bool _connected = false;
};
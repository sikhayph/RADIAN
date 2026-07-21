#pragma once
#include <Arduino.h>

class EncoderA {
public:
    void  begin();
    float readAngle();
    bool  isConnected();

private:
    bool _connected = false;
};
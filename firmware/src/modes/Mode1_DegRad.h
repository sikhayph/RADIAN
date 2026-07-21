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
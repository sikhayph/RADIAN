#pragma once

struct Mode3Data {
    float theta;
    float r00, r01;
    float r10, r11;
    float vx,  vy;
    float vxp, vyp;
};

class Mode3_RotMatrix {
public:
    Mode3Data compute(float theta, float a2);
};
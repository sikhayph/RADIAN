#pragma once

struct Mode2Data {
    float a1;
    float a2;
    float v1x, v1y;
    float v2x, v2y;
    float rx,  ry;
    float rmag;
    float rang;
};

class Mode2_VectorAdd {
public:
    Mode2Data compute(float a1, float a2);
};
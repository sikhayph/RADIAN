#pragma once

struct Mode4Data {
    int   n;
    float snappedAngle;
    float interior;
    float exterior;
    float central;
};

class Mode4_PolygonSnap {
public:
    Mode4Data compute(float degrees, int n);
    int       clampN(int n);
};
#pragma once
#include "Mode1_DegRad.h"
#include "Mode2_VectorAdd.h"
#include "Mode3_RotMatrix.h"
#include "Mode4_PolygonSnap.h"
#include "../../include/config.h"

struct ComputedPayload {
    int   mode;
    float a1;
    float a2;
    float rad;
    float rx, ry;
    float rmag, rang;
    int   snap;
    float interior, exterior;
    unsigned long ts;
};

class ModeManager {
public:
    void            begin();
    void            setMode(int mode);
    int             getMode();
    void            nextMode();
    int             getPolygonN();
    void            incrementN();
    void            decrementN();
    ComputedPayload compute(float a1, float a2);

private:
    int _mode     = MODE_DEFAULT;
    int _polygonN = 6;

    Mode1_DegRad      _mode1;
    Mode2_VectorAdd   _mode2;
    Mode3_RotMatrix   _mode3;
    Mode4_PolygonSnap _mode4;
};
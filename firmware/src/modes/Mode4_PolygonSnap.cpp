#include "Mode4_PolygonSnap.h"
#include <math.h>

int Mode4_PolygonSnap::clampN(int n) {
    if (n < 3)  return 3;
    if (n > 12) return 12;
    return n;
}

Mode4Data Mode4_PolygonSnap::compute(float degrees, int n) {
    Mode4Data data;
    n = clampN(n);
    data.n = n;

    float step = 360.0f / n;

    data.snappedAngle = roundf(degrees / step) * step;
    data.central      = step;
    data.interior     = (float)(n - 2) * 180.0f / n;
    data.exterior     = 360.0f / n;

    return data;
}
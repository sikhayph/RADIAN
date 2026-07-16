#include "Mode2_VectorAdd.h"
#include "../../include/config.h"
#include <math.h>

Mode2Data Mode2_VectorAdd::compute(float a1, float a2) {
    Mode2Data data;
    data.a1 = a1;
    data.a2 = a2;

    data.v1x = cosf(a1 * DEG_TO_RAD_FACTOR);
    data.v1y = sinf(a1 * DEG_TO_RAD_FACTOR);
    data.v2x = cosf(a2 * DEG_TO_RAD_FACTOR);
    data.v2y = sinf(a2 * DEG_TO_RAD_FACTOR);

    data.rx   = data.v1x + data.v2x;
    data.ry   = data.v1y + data.v2y;
    data.rmag = sqrtf(data.rx * data.rx + data.ry * data.ry);
    data.rang = atan2f(data.ry, data.rx) * RAD_TO_DEG_FACTOR;

    if (data.rang < 0) data.rang += 360.0f;

    return data;
}
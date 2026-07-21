#include "Mode3_RotMatrix.h"
#include "../../include/config.h"
#include <math.h>

Mode3Data Mode3_RotMatrix::compute(float theta, float a2) {
    Mode3Data data;
    data.theta = theta;

    float rad = theta * DEG_TO_RAD_FACTOR;

    data.r00 =  cosf(rad);
    data.r01 = -sinf(rad);
    data.r10 =  sinf(rad);
    data.r11 =  cosf(rad);

    data.vx = cosf(a2 * DEG_TO_RAD_FACTOR);
    data.vy = sinf(a2 * DEG_TO_RAD_FACTOR);

    data.vxp = data.r00 * data.vx + data.r01 * data.vy;
    data.vyp = data.r10 * data.vx + data.r11 * data.vy;

    return data;
}
#include "Mode1_DegRad.h"
#include "../../include/config.h"
#include <math.h>

Mode1Data Mode1_DegRad::compute(float degrees) {
    Mode1Data data;
    data.degrees = degrees;
    data.radians = degrees * DEG_TO_RAD_FACTOR;
    data.cosVal  = cosf(data.radians);
    data.sinVal  = sinf(data.radians);
    return data;
}
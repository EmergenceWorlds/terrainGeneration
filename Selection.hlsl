#ifndef SELECTION_INCLUDED
#define SELECTION_INCLUDED

#include "Interpolation.hlsl"

float selection(float noiseValue1, float noiseValue2, float controlNoiseValue, float lowerBound, float upperBound, float edgeFalloff)
{
    float t;
    if (edgeFalloff > 0.0) {
        if (controlNoiseValue < (lowerBound - edgeFalloff)) {
            // The output value from the control module is below the selector
            // threshold; return the output value from the first source module.
            return noiseValue1;

        } else if (controlNoiseValue < (lowerBound + edgeFalloff)) {
            // The output value from the control module is near the lower end of the
            // selector threshold and within the smooth curve. Interpolate between
            // the output values from the first and second source modules.
            float lowerCurve = (lowerBound - edgeFalloff);
            float upperCurve = (lowerBound + edgeFalloff);

            t = SCurve3 ((controlNoiseValue - lowerCurve) / (upperCurve - lowerCurve));

            return lerp(noiseValue1, noiseValue2, t);

        } else if (controlNoiseValue < (upperBound - edgeFalloff)) {
            // The output value from the control module is within the selector
            // threshold; return the output value from the second source module.
            return noiseValue2;

        } else if (controlNoiseValue < (upperBound + edgeFalloff)) {
            // The output value from the control module is near the upper end of the
            // selector threshold and within the smooth curve. Interpolate between
            // the output values from the first and second source modules.
            float lowerCurve = (upperBound - edgeFalloff);
            float upperCurve = (upperBound + edgeFalloff);

            t = SCurve3 ((controlNoiseValue - lowerCurve) / (upperCurve - lowerCurve));

            return lerp(noiseValue2, noiseValue1, t);

        } else {
            // Output value from the control module is above the selector threshold;
            // return the output value from the first source module.
            return noiseValue1;
        }
    } else {
        if (controlNoiseValue < lowerBound || controlNoiseValue > upperBound) {
            return noiseValue1;
        } else {
            return noiseValue2;
        }
    }
}

#endif //SELECTION_INCLUDED
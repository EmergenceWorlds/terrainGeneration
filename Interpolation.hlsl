#ifndef INTERPOLATION_INCLUDED
#define INTERPOLATION_INCLUDED

/// Performs cubic interpolation between two values bound between two other
/// values.
///
/// @param n0 The value before the first value.
/// @param n1 The first value.
/// @param n2 The second value.
/// @param n3 The value after the second value.
/// @param a The alpha value.
///
/// @returns The interpolated value.
///
/// The alpha value should range from 0.0 to 1.0.  If the alpha value is
/// 0.0, this function returns @a n1.  If the alpha value is 1.0, this
/// function returns @a n2.
float CubicInterp (float n0, float n1, float n2, float n3, float a)
{
	float p = (n3 - n2) - (n0 - n1);
	float q = (n0 - n1) - p;
	float r = n2 - n0;
	float s = n1;
	return p * a * a * a + q * a * a + r * a + s;
}

/// Maps a value onto a cubic S-curve.
///
/// @param a The value to map onto a cubic S-curve.
///
/// @returns The mapped value.
///
/// @a a should range from 0.0 to 1.0.
///
/// The derivitive of a cubic S-curve is zero at @a a = 0.0 and @a a =
/// 1.0
float SCurve3 (float a)
{
	return (a * a * (3.0 - 2.0 * a));
}

/// Maps a value onto a quintic S-curve.
///
/// @param a The value to map onto a quintic S-curve.
///
/// @returns The mapped value.
///
/// @a a should range from 0.0 to 1.0.
///
/// The first derivitive of a quintic S-curve is zero at @a a = 0.0 and
/// @a a = 1.0
///
/// The second derivitive of a quintic S-curve is zero at @a a = 0.0 and
/// @a a = 1.0
float SCurve5 (float a)
{
	float a3 = a * a * a;
	float a4 = a3 * a;
	float a5 = a4 * a;
	return (6.0 * a5) - (15.0 * a4) + (10.0 * a3);
}

float evaluateCurveCubic(float value, StructuredBuffer<float> curve, int curveSize) {
    float curveX = value * curveSize;
    int curveIndex = floor(curveX);

    if(curveIndex < 1) { curveIndex = 1; }
    else if(curveIndex > curveSize - 3) { curveIndex = curveSize - 3; }

    float t = frac(curveX);

    return CubicInterp(curve[curveIndex - 1], curve[curveIndex], curve[curveIndex + 1], curve[curveIndex + 2], t);

    //return lerp(curve[curveIndex], curve[curveIndex + 1], t);
}

float evaluateCurveLinear(float value, StructuredBuffer<float> curve, int curveSize) {
    float curveX = value * curveSize;
    int curveIndex = floor(curveX);

    if(curveIndex < 0) { curveIndex = 0; }
    else if(curveIndex > curveSize - 1) { curveIndex = curveSize - 1; }

    float t = frac(curveX);

    return lerp(curve[curveIndex], curve[curveIndex + 1], t);
}

#endif //INTERPOLATION_INCLUDED
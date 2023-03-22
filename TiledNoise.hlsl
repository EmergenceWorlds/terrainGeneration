#ifndef TILED_NOISE_INCLUDED
#define TILED_NOISE_INCLUDED

#define tau 6.2831853

// the basic hash function for our noise
float2 hash(float2 x)
{
    const float2 k = float2(0.3183099, 0.3678794);
    x = x * k + k.yx;
    return -1.0 + 2.0 * frac(16.0 * k * frac(x.x * x.y * (x.x + x.y)));
}

// the modulo for the tield noise function to ensure negative values are modulo'd correctly
float2 modulo(float2 divident, float2 divisor){
    float2 positiveDivident = divident % divisor + divisor;
    return positiveDivident % divisor;
}

// the noise is being tiled with cells max and min as well as with modulo
float noise(float2 p, int limitSize)
{
    float2 cellsMinimum = floor(p);
    float2 cellsMaximum = ceil(p);
    
    cellsMinimum = modulo(cellsMinimum, float2 (limitSize, limitSize));
    cellsMaximum = modulo(cellsMaximum, float2 (limitSize, limitSize));

    float2 f = frac(p);

    float2 u = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);

    float2 ga = hash(float2(cellsMinimum.x, cellsMinimum.y));
    float2 gb = hash(float2(cellsMaximum.x, cellsMinimum.y));
    float2 gc = hash(float2(cellsMinimum.x, cellsMaximum.y));
    float2 gd = hash(float2(cellsMaximum.x, cellsMaximum.y));

    float va = dot(ga, f - float2(0.0, 0.0));
    float vb = dot(gb, f - float2(1.0, 0.0));
    float vc = dot(gc, f - float2(0.0, 1.0));
    float vd = dot(gd, f - float2(1.0, 1.0));

    return float(va + u.x * (vb - va) + u.y * (vc - va) + u.x * u.y * (va - vb - vc + vd));
}

// a custom modulo function that ensures an integer is being modulo'd correctly without floating points
int2 moduloInt(int2 pInt, int modulo)
{
    return pInt - floor(pInt / modulo) * modulo;
}

// get the coordinates that are being modulo'd after a certain limitSize
float2 getStaticCoordinate(float2 pInt, float2 pFloat, int limitSize, float scale)
{
    int limitSize2 = floor(limitSize / scale);
    pInt = moduloInt(pInt, limitSize2);
    pFloat = pFloat % limitSize2;

    return (pInt * scale + pFloat * scale) % limitSize;
}

// get the tiled noise with the corrected coordinates
float tiledNoise(int2 pInt, float2 pFloat, int2 offset, int limitSize, float scale)
{
    float2 staticCoordinate = getStaticCoordinate(pInt + offset, pFloat, limitSize, scale);

    return noise(staticCoordinate, limitSize);
}

// a function to create tiled noise with multiple octaves (fbm)
float tiledNoiseFBM(int2 pInt, float2 pFloat, int2 offset, int limitSize,
    float scale, float frequency, int octaves, float persistance = 0.5, float lacunarity = 2.0)
{
    float value = 0.0;

    float amplitude = 0.5;
    for (int i = 0; i < octaves; i++) {
        value += (tiledNoise(pInt * frequency, pFloat * frequency, offset, limitSize, scale)) * amplitude;
        amplitude *= persistance;
        frequency *= lacunarity;
    }

    return value;
}

// same function as above, only that return values are in range [0,1] instead of [-1,1]
float tiledNoiseFBMCorrected(int2 pInt, float2 pFloat, int2 offset, int limitSize,
    float scale, float frequency, int octaves, float persistance = 0.5, float lacunarity = 2.0)
{
    float value = 0.0;

    float amplitude = 0.5;
    for (int i = 0; i < octaves; i++) {
        value += (tiledNoise(pInt * frequency, pFloat * frequency, offset, limitSize, scale) * 0.5 + 0.5 ) * amplitude;
        amplitude *= persistance;
        frequency *= lacunarity;
    }

    return value;
}

int2 tiledTurbulence(int2 pInt, float2 pFloat, int2 offset, int limitSize, float scale, float frequency = 1.0, float power = 1.0)
{
    int2 pIntReturn = pInt;
    float xValue = tiledNoise(pInt * frequency, pFloat * frequency, offset, limitSize, scale);
    float yValue = tiledNoise(pInt * frequency, pFloat * frequency, offset + int2(99832, 87532), limitSize, scale);

    pIntReturn.x += floor(xValue * power / scale);
    pIntReturn.y += floor(yValue * power / scale);

    return pIntReturn;
}

float tiledNoiseFBMBillow(int2 pInt, float2 pFloat, int2 offset, int limitSize,
    float scale, float frequency, int octaves, float persistance = 0.5, float lacunarity = 2.0)
{
    float value = 0.0;

    float amplitude = 0.5;
    for (int i = 0; i < octaves; i++) {
        value += abs(tiledNoise(pInt * frequency, pFloat * frequency, offset, limitSize, scale)) * amplitude;
        amplitude *= persistance;
        frequency *= lacunarity;
    }

    return value;
}

float2 getM2Val(float theta)
{
	return float2(cos(theta),-sin(theta));
}

static float spectralWeights[7] = {
    0.5,
    0.3,
    0.25,
    0.1,
    0.05,
    0.03,
    0.01
};

float tiledNoiseFBMRidge(int2 pInt, float2 pFloat, int2 offset, int limitSize,
    float scale, float frequency, int octaves, float ridgeOffset = 0.9, float gain = 1.5, float lacunarity = 2.0)
{
    float value = 1.0;
    float n = 0.0;
	float weight = 0.0;

    // get first octave of function
	n = tiledNoise(pInt * frequency, pFloat * frequency, offset, limitSize, scale);
	n = ridgeOffset - abs(n);
	n *= n;
	value = n * spectralWeights[0];
	weight = 1.0;

    for (int i = 1; i < octaves - 1; i++) {
        frequency *= lacunarity;
		weight = clamp(n * gain, 0.0, 1.0);
		n = tiledNoise(pInt * frequency, pFloat * frequency, offset, limitSize, scale);
		n = ridgeOffset - abs(n);
		n *= n;
		n *= weight;
		value += n * spectralWeights[i];
    }

    return value;
}

#endif //TILED_NOISE_INCLUDED
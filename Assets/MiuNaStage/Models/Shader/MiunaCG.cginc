#ifndef MIUNA_CG_INCLUDED
#define MIUNA_CG_INCLUDED

#define M_PI 3.14159265358979323846

// ==== about lights ====
// Reference: Valve
// from [-1, 1] to [0, 1]
inline fixed halfLambert(fixed value) {
	return 0.5*value + 0.5;
}

// ==== about colors ====
inline fixed4 blend(fixed4 src, fixed4 dest)
{
    return src.rgba * src.a + dest.rgba * (1.0 - src.a);
}

// ==== about transforms ====
inline float radians(uint degrees)
{
    return degrees * M_PI / 180.0;
}

void zRotate(inout float4x4 toModify, float radian) 
{
    float sinv = sin(radian);
    float cosv = cos(radian);

    float4x4 rotateMatrix;
    // row-first
    rotateMatrix._11_12_13_14 = (cosv, -sinv, 0.0, 0.0);
    rotateMatrix._21_22_23_24 = (sinv, cosv, 0.0, 0.0);
    rotateMatrix._31_32_33_34 = (0.0, 0.0, 1.0, 0.0);
    rotateMatrix._41_42_43_44 = (0.0, 0.0, 0.0, 1.0);

    toModify = mul(toModify, rotateMatrix);
}
#endif // MIUNA_CG_INCLUDED
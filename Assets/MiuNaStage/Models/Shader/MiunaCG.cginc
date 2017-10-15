#ifndef MIUNA_CG_INCLUDED
#define MIUNA_CG_INCLUDED

#define M_PI 3.14159265358979323846

// ==== about lights ====
// Reference: Valve
// from [-1, 1] to [0, 1]
inline fixed halfLambert(fixed value) {
	return 0.5*value + 0.5;
}

float2 hash2(float2 p)
{
    float2 q = float2(dot(p, float2(127.1, 311.7)),
							   dot(p, float2(269.5, 183.3)));
    return frac(sin(q) * 43758.5453);
}

float voronoi(float2 x)
{
    int2 p = floor(x);
    float2 f = frac(x);

    float res = 8.0f;
    for (int j = -1; j <= 1; j++)
    {
        for (int i = -1; i <= 1; i++)
        {
            int2 b = int2(i, j);
            float2 r = float2(b) - f + hash2(p + b);
            float d = dot(r, r);

            res = min(res, d);
        }
    }
    return sqrt(res);
}

// TODO: if do uv animate like this, how does the frag shader interpolate
void uvAnimate(inout float2 uv, float2 diff, float2 uv_left_top, float2 uv_right_bottom)
{
    float2 wh = uv_right_bottom - uv_left_top;
    uv += diff * wh;
    uv.x -= step(uv.x, uv_right_bottom.x) * wh.x;
    uv.y -= step(uv.y, uv_right_bottom.y) * wh.y;
}
fixed2 hash22(fixed2 p)
{
    p = fixed2(dot(p, fixed2(127.1, 311.7)),
					dot(p, fixed2(269.5, 183.3)));

    return -1.0 + 2.0 * saturate(sin(p) * 43758.5453123);
}
float perlin_noise(fixed2 p)
{
    fixed2 pi = floor(p);
    fixed2 pf = p - pi;

    fixed2 w = pf * pf * (3.0 - 2.0 * pf);

    return lerp(lerp(dot(hash22(pi + fixed2(0.0, 0.0)), pf - fixed2(0.0, 0.0)),
					dot(hash22(pi + fixed2(1.0, 0.0)), pf - fixed2(1.0, 0.0)), w.x),
					lerp(dot(hash22(pi + fixed2(0.0, 1.0)), pf - fixed2(0.0, 1.0)),
						dot(hash22(pi + fixed2(1.0, 1.0)), pf - fixed2(1.0, 1.0)), w.x),
					w.y);
}

// ==== about colors ====
inline fixed4 blend(fixed4 src, fixed4 dest)
{
    return src.rgba * src.a + dest.rgba * (1.0 - src.a);
}

inline void noise_color(inout fixed4 color, float noise)
{
    noise = noise * 0.5 + 0.5;
    color = noise * color;
}

// ==== about transforms ====
inline float radians(uint degrees)
{
    return degrees * M_PI / 180.0;
}

void xRotate(inout float4x4 toModify, float radian)
{
    float sinv = sin(radian);
    float cosv = cos(radian);

    float4x4 rotateMatrix = float4x4(
					1.0, 0.0, 0.0, 0.0,
                    0.0, cosv, -sinv, 0.0,
					0.0, sinv, cosv, 0.0,
					0.0, 0.0, 0.0, 1.0
					);

    toModify = mul(toModify, rotateMatrix);
}

void yRotate(inout float4x4 toModify, float radian)
{
    float sinv = sin(radian);
    float cosv = cos(radian);

    float4x4 rotateMatrix = float4x4(
					cosv, 0.0, sinv, 0.0,
                    0.0, 1.0, 0.0, 0.0,
					-sinv, 0.0, cosv, 0.0,
					0.0, 0.0, 0.0, 1.0
					);

    toModify = mul(toModify, rotateMatrix);
}

void zRotate(inout float4x4 toModify, float radian) 
{
    float sinv = sin(radian);
    float cosv = cos(radian);

    float4x4 rotateMatrix = float4x4(
					cosv, -sinv, 0.0, 0.0,
                    sinv, cosv, 0.0, 0.0,
					0.0, 0.0, 1.0, 0.0,
					0.0, 0.0, 0.0, 1.0
					);

    toModify = mul(toModify, rotateMatrix);
}

// fish object space is right-hand and z axis up
void applyVelocity(inout float4x4 toModify, float3 velocity)
{
    float3 forward = normalize(velocity);
    float3 up = float3(0, 0, 1);
    // +y
    float3 sides = normalize(cross(up, forward));
    float3 uup = cross(forward, sides);
    
    float4x4 coord_trans = float4x4(
        forward.xyz, 0.0,
        sides.xyz, 0.0,
        uup.xyz, 0.0,
        0.0, 0.0, 0.0, 1.0
    );
    toModify = mul(toModify, coord_trans);
}
#endif // MIUNA_CG_INCLUDED
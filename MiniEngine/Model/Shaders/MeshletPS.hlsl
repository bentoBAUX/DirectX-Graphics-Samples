#include "MeshletCommon.hlsli"

// https://github.com/skeeto/hash-prospector
float4 hash(uint x)
{
    x ^= x >> 16;
    x *= 0x7feb352d;
    x ^= x >> 15;
    x *= 0x846ca68b;
    x ^= x >> 16;
    float3 colour = float3(x & 255u, (x >> 8) & 255u, (x >> 16) & 255u) / 255.0f;
    return float4(0.2f + colour * 0.8f, 1.0f);
}

float4 main(MSOutput msOutput) : SV_Target0
{
    float4 colour = hash(msOutput.id);
    return colour;
}


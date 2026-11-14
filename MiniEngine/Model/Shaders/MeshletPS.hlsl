#include "MeshletCommon.hlsli"

float4 main(MSOutput msOutput) : SV_Target0
{
    uint h = msOutput.id;
    h ^= h >> 16;
    h *= 0x7feb352du;
    h ^= h >> 15;
    h *= 0x846ca68bu;
    h ^= h >> 16;

    float3 colour = float3(h & 255u, (h >> 8) & 255u, (h >> 16) & 255u) / 255.0f;
    return float4(0.2f + colour * 0.8f, 1.0f);
}


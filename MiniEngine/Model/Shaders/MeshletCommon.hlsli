#ifndef MESHLET_COMMON_HLSLI
#define MESHLET_COMMON_HLSLI

struct Payload
{
    uint placeholder;
};

struct MSOutput
{
    float4 positionCS : SV_POSITION;
    float3 normal : NORMAL;
#ifndef NO_TANGENT_FRAME
    float4 tangent : TANGENT;
#endif
    float2 uv0 : TEXCOORD0;
#ifndef NO_SECOND_UV
    float2 uv1 : TEXCOORD1;
#endif
    float3 positionWS : TEXCOORD2;
    float3 sunShadowCoord : TEXCOORD3;
    nointerpolation uint id : TEXCOORD4;
};
#endif
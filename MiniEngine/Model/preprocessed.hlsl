#line 1 "Shaders/MeshletAS.hlsl"
#line 1 "./Shaders/MeshletCommon.hlsli"



struct Payload
{
    uint placeholder;
};

struct MSOutput
{
    float4 position : SV_POSITION;
    float3 normal : NORMAL;

    float4 tangent : TANGENT;

    float2 uv0 : TEXCOORD0;

    float2 uv1 : TEXCOORD1;

    float3 worldPos : TEXCOORD2;
    float3 sunShadowCoord : TEXCOORD3;
};
#line 1 "Shaders/MeshletAS.hlsl"


[numthreads(1, 1, 1)]
void main()
{
    Payload payload;
    payload.placeholder = 0;

    DispatchMesh(1, 1, 1, payload);
}

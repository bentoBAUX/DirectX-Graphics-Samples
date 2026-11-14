#include "MeshletCommon.hlsli"

cbuffer MeshDrawConstants : register(b22)
{
    uint descriptorOffset;
    uint meshletVertexIndicesOffset;
    uint meshletTriangleIndicesOffset;
    uint vertexBufferOffset;
    uint vertexStride;
};

cbuffer MeshConstants : register(b2)
{
    float4x4 WorldMatrix;
    float3x3 WorldIT;
};

cbuffer GlobalConstants : register(b1)
{
    float4x4 ViewProjMatrix;
    float4x4 SunShadowMatrix;
    float3 ViewerPos;
    float3 SunDirection;
    float3 SunIntensity;
}

ByteAddressBuffer Geometry : register(t21);

struct meshopt_Meshlet
{
    uint vertex_offset;
    uint triangle_offset;
    uint vertex_count;
    uint triangle_count;
};

// Load reads 4 bytes. ReadByte masks the other 3 bytes and delivers the first byte.
uint ReadByte(uint byteOffset)
{
    uint alignedOffset = byteOffset & ~3u;
    uint packed = Geometry.Load(alignedOffset);

    uint shift = (byteOffset % 4) * 8;
    return (packed >> shift) & 0xFFu;
}

float3 UnpackNormal(uint address)
{
    uint packedNormal = Geometry.Load(address);
    float3 normalOS = float3(packedNormal & 0x3FFu, (packedNormal >> 10) & 0x3FFu, (packedNormal >> 20) & 0x3FFu) / 1023.0;
    return normalOS * 2.0 - 1.0;
}

float2 UnpackUV(uint address)
{
    uint packedUV = Geometry.Load(address);
    uint u = packedUV & 0xFFFFu;
    uint v = (packedUV >> 16 & 0xFFFFu);
    return f16tof32(uint2(u, v));
}

// https://microsoft.github.io/DirectX-Specs/d3d/MeshShader.html?utm_source=chatgpt.com#hlsl-attributes-and-intrinsics
// https://github.com/microsoft/DirectX-Graphics-Samples/blob/master/Samples/Desktop/D3D12MeshShaders/src/MeshletCull/MeshletMS.hlsl
[outputtopology("triangle")]
[NumThreads(128, 1, 1)]
void main(
    uint3 groupID : SV_GroupID,
    uint3 threadID : SV_GroupThreadID,
    out vertices MSOutput verts[64],
    out indices uint3 triangles[126])
{
    
    uint j = groupID.x;
    uint4 descriptor = Geometry.Load4(descriptorOffset + j * 16); // D(i,j) = mesh.meshletsOffset + mesh.draw[i].meshletsOffset + j * sizeof(meshopt_Meshlet)

    meshopt_Meshlet M_ij =
    {
        descriptor.x, // vertex_offset
        descriptor.y, // triangle_offset
        descriptor.z, // vertex_count
        descriptor.w  // triangle_count
    };
    
    SetMeshOutputCounts(M_ij.vertex_count, M_ij.triangle_count);
    
    
    MSOutput msOutput;
    
    uint Av_ij = meshletVertexIndicesOffset + M_ij.vertex_offset * 4;
    if (threadID.x < M_ij.vertex_count)
    {
        msOutput.id = j;
        uint Av_ijk = Av_ij + 4 * threadID.x;
        uint I_ijk = Geometry.Load(Av_ijk);
        uint Avb_ijk = vertexBufferOffset + I_ijk * vertexStride;
        float3 positionOS = asfloat(Geometry.Load3(Avb_ijk));
        
        float4 positionWS = mul(WorldMatrix, float4(positionOS, 1.0));
        msOutput.positionWS = positionWS.xyz;
        msOutput.positionCS = mul(ViewProjMatrix, positionWS);
        msOutput.sunShadowCoord = mul(SunShadowMatrix, positionWS).xyz;
        msOutput.normal = mul(WorldIT, UnpackNormal(Avb_ijk + 12));
        msOutput.uv0 = UnpackUV(Avb_ijk + 16);
        verts[threadID.x] = msOutput;
    }
    
    uint At_ij = meshletTriangleIndicesOffset + M_ij.triangle_offset;
    if (threadID.x < M_ij.triangle_count)
    {
        uint At_ijq = At_ij + threadID.x * 3;
        triangles[threadID.x] = uint3(ReadByte(At_ijq), ReadByte(At_ijq + 1), ReadByte(At_ijq + 2));
    }
    
    /* TO TEST: numthreads(128,1,1) vs numthreads(32,1,1)
    // 32 threads process 32 triangles in parallel. 
    // With each thread handling max 4 triangles.
    // Requiring at most 4 loop iterations per thread. 
    for (int q = threadID.x; q < M_ij.triangle_count; q += 32)
    {
        uint offset = triangleStart + q * 3;

        uint3 tri = uint3(ReadByte(offset), ReadByte(offset + 1), ReadByte(offset + 2));
        triangles[q] = tri;
    }*/
    
}
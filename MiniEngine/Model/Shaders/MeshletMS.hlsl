#include "MeshletCommon.hlsli"

[outputtopology("triangle")]
[numthreads(1, 1, 1)]
void main(
    in payload Payload payload,
    out vertices MSOutput verts[3],
    out indices uint3 triangles[1])
{
    SetMeshOutputCounts(3, 1);

    verts[0].position = float4(-0.5, -0.5, 0.5, 1.0);
    verts[1].position = float4(0.0, 0.5, 0.5, 1.0);
    verts[2].position = float4(0.5, -0.5, 0.5, 1.0);

    triangles[0] = uint3(0, 2, 1); // Front side (CCW)
}
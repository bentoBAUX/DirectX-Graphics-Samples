struct MSOutput
{
    float4 position : SV_Position;
};

[outputtopology("triangle")]
[numthreads(1, 1, 1)]
void main(
    out vertices MSOutput verts[3],
    out indices uint3 triangles[1])
{
    SetMeshOutputCounts(3, 1);

    verts[0].position = float4(-0.5, -0.5, 0.5, 1.0);
    verts[1].position = float4(0.0, 0.5, 0.5, 1.0);
    verts[2].position = float4(0.5, -0.5, 0.5, 1.0);

    triangles[0] = uint3(0, 1, 2);
}
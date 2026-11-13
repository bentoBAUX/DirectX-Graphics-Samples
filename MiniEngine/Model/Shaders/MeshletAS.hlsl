#include "MeshletCommon.hlsli"

[numthreads(1, 1, 1)]
void main()
{
    Payload payload;
    payload.placeholder = 0;

    DispatchMesh(1, 1, 1, payload);
}
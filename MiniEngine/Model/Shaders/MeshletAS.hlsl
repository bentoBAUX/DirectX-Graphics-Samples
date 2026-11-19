#include "MeshletCommon.hlsli"

[NumThreads(1, 1, 1)]
void main(uint3 groupID: SV_GroupID)
{
    // Renderer::DispatchMesh(4,1,1) launches 4 amp shader groups.
    // Each amp shader processes a batch of meshlets.
    // Test visibility a batch of meshlets, cull them, dispatch necessary ones.
    ASPayload payload;
    payload.meshletID = groupID.x;

    // Launches x mesh shaders for x meshlets from the culled batch
    DispatchMesh(1, 1, 1, payload);
}
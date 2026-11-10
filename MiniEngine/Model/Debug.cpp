#include "Debug.h"

void CompareBuffer(const char* label, const byte* packed, const void* original, size_t size, size_t& offset, size_t alignment = 1) {
	if (std::memcmp(packed + offset, original, size) != 0)
	{
		OutputDebugStringA(label);
		OutputDebugStringA(" mismatch!\n");
		assert(false);
	}

	offset += Math::AlignUp(size, alignment);
}

void Debug::ValidateMeshPacking(const std::vector<byte>& memory, const Mesh& mesh, const std::vector<Renderer::Primitive*>& prims) {
	const byte* buffer = memory.data();
	const byte* vb = buffer + mesh.vbOffset;
	const byte* dvb = buffer + mesh.vbDepthOffset;
	const byte* ib = buffer + mesh.ibOffset;
	const byte* meshlets = buffer + mesh.meshletsOffset;
	const byte* meshletsVertex = buffer + mesh.meshletsVertexOffset;
	const byte* meshletsTriangle = buffer + mesh.meshletsTriangleOffset;

	size_t expectedVBSize = 0;
	size_t expectedDVBSize = 0;
	size_t expectedIBSize = 0;
	size_t expectedMSize = 0;
	size_t expectedMVSize = 0;
	size_t expectedMTSize = 0;

	for (const auto* prim : prims) {
		expectedVBSize += prim->VB->size();
		expectedDVBSize += prim->DepthVB->size();
		expectedIBSize += prim->IB->size();
		expectedMSize += prim->meshletsData.meshlets.size() * sizeof(meshopt_Meshlet);
		expectedMVSize += prim->meshletsData.vertices.size() * sizeof(unsigned int);
		expectedMTSize += Math::AlignUp(prim->meshletsData.triangles.size(), 4);
	}

	// Buffer size validation
	assert(mesh.vbSize == expectedVBSize);
	assert(mesh.vbDepthSize == expectedDVBSize);
	assert(mesh.ibSize == expectedIBSize);
	assert(mesh.meshletsSize == expectedMSize);
	assert(mesh.meshletsVertexSize == expectedMVSize);
	assert(mesh.meshletsTriangleSize == expectedMTSize);

	// Memory boundary validation
	assert(mesh.vbOffset <= memory.size());
	assert(mesh.vbSize <= memory.size() - mesh.vbOffset);

	assert(mesh.vbDepthOffset <= memory.size());
	assert(mesh.vbDepthSize <= memory.size() - mesh.vbDepthOffset);

	assert(mesh.ibOffset <= memory.size());
	assert(mesh.ibSize <= memory.size() - mesh.ibOffset);

	assert(mesh.meshletsOffset <= memory.size());
	assert(mesh.meshletsSize <= memory.size() - mesh.meshletsOffset);

	assert(mesh.meshletsVertexOffset <= memory.size());
	assert(mesh.meshletsVertexSize <= memory.size() - mesh.meshletsVertexOffset);

	assert(mesh.meshletsTriangleOffset <= memory.size());
	assert(mesh.meshletsTriangleSize <= memory.size() - mesh.meshletsTriangleOffset);

	// Content validation
	size_t vbOffset = 0;
	size_t dvbOffset = 0;
	size_t ibOffset = 0;
	size_t mOffset = 0;
	size_t mvOffset = 0;
	size_t mtOffset = 0;
	for (const auto& prim : prims) {
		CompareBuffer("VB", vb, prim->VB->data(), prim->VB->size(), vbOffset);
		CompareBuffer("DVB", dvb, prim->DepthVB->data(), prim->DepthVB->size(), dvbOffset);
		CompareBuffer("IB", ib, prim->IB->data(), prim->IB->size(), ibOffset);

		const auto& md = prim->meshletsData;

		CompareBuffer("Meshlets", meshlets, md.meshlets.data(), md.meshlets.size() * sizeof(meshopt_Meshlet), mOffset);
		CompareBuffer("Meshlets Vertex", meshletsVertex, md.vertices.data(), md.vertices.size() * sizeof(unsigned int), mvOffset);
		CompareBuffer("Meshlets Triangle", meshletsTriangle, md.triangles.data(), md.triangles.size(), mtOffset, 4);
	}

	// Draw metadata validation
	size_t expectedStartIndex = 0;
	size_t expectedBaseVertex = 0;
	size_t expectedMOffset = 0;
	size_t expectedMVOffset = 0;
	size_t expectedMTOffset = 0;

	assert(mesh.numDraws == prims.size());
	for (int i = 0; i < mesh.numDraws; i++) {
		const auto* prim = prims[i];
		const auto& draw = mesh.draw[i];
		const auto& md = prim->meshletsData;

		assert(draw.primCount == prim->primCount);
		assert(draw.startIndex == expectedStartIndex);
		assert(draw.baseVertex == expectedBaseVertex);

		assert(draw.meshletsCount == md.meshlets.size());
		assert(draw.meshletsOffset == expectedMOffset);
		assert(draw.meshletsVertexOffset == expectedMVOffset);
		assert(draw.meshletsTriangleOffset == expectedMTOffset);

		expectedStartIndex += prim->IB->size() / (prim->index32 ? 4 : 2);
		expectedBaseVertex += prim->VB->size() / prim->vertexStride;
		expectedMOffset += md.meshlets.size() * sizeof(meshopt_Meshlet);
		expectedMVOffset += md.vertices.size() * sizeof(unsigned int);
		expectedMTOffset += Math::AlignUp(md.triangles.size(), 4);


		// Meshlet integrity validation
		for (auto& m : md.meshlets) {
			// Check vertex/triangle limits
			assert(m.vertex_count <= 64);
			assert(m.triangle_count <= 126);

			// Check offset validity
			assert(m.vertex_offset <= md.vertices.size());
			assert(m.vertex_count <= md.vertices.size() - m.vertex_offset);
			assert(m.triangle_offset <= md.triangles.size());
			assert(m.triangle_count * 3 <= md.triangles.size() - m.triangle_offset);

			// Check vertex reference validity (refers to valid vertices in Primitive)
			for (size_t i = 0; i < m.vertex_count; i++)
			{
				uint32_t vertexIndex = md.vertices[m.vertex_offset + i];
				assert(vertexIndex < prim->VB->size()/prim->vertexStride);
			}

			// Check local - Primitive vertex reference validity
			for (size_t i = 0; i < m.triangle_count * 3; i++)
			{
				uint8_t localIndex = md.triangles[m.triangle_offset + i];

				assert(localIndex < m.vertex_count);
			}
		}
	}

}

void ValidateModelMemoryLayout(const std::vector<byte>& memory, const std::vector<Mesh*>& meshList) {}

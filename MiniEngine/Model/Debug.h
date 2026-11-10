#pragma once

#include <vector>
#include "Model.h"
#include "MeshConvert.h"

namespace Debug {
	// Verify packed mesh data against the original primitives.
	void ValidateMeshPacking(const std::vector<byte>& memory, const Mesh& mesh, const std::vector<Renderer::Primitive*>& prims);

	// Verify all mesh offsets, sizes and memory boundaries.
	void ValidateModelMemoryLayout(const std::vector<byte>& memory, const std::vector<Mesh*>& meshList);
}
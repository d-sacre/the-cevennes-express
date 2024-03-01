#pragma once

#include "Tile/EdgeType.hpp"

#include <array>

namespace CE
{
	namespace Tile
	{
		struct Edge
		{
			std::array<EdgeType, 3> Types;
		};
	} // namespace Tile

	bool IsCompatible(const Tile::Edge& left, const Tile::Edge& right);
} // namespace CE

#pragma once

#include "Tile/EdgeType.hpp"

#include <array>

namespace CE
{
	namespace Tile
	{
		struct Edge
		{
			std::array<EdgeType, 3> Types {EdgeType::None, EdgeType::None, EdgeType::None};

			friend bool operator==(Edge const& lhs, Edge const& rhs) = default;
		};
	} // namespace Tile

	bool IsCompatible(const Tile::Edge& left, const Tile::Edge& right);
} // namespace CE

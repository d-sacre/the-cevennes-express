#pragma once

#include "EdgeType_Utils.hpp"
#include "Tile/Edge.hpp"

namespace CE
{
	bool IsCompatible(Tile::EdgeType one, Tile::EdgeType two)
	{
		return one == two;
	}
} // CE

namespace EdgeUtils
{
	std::string ToString(const CE::Tile::Edge& edge)
	{
		return "(" + EdgeTypeUtils::ToString(edge.Types[0]) + ", " + EdgeTypeUtils::ToString(edge.Types[1]) + ", " + EdgeTypeUtils::ToString(edge.Types[2]) + ")";
	}
} // namespace EdgeUtils

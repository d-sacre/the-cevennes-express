#include "Tile/Edge.hpp"

namespace CE
{
	bool IsCompatible(const Tile::Edge& first, const Tile::Edge& second)
	{
		return IsCompatible(first.Types[0], second.Types[2]) && 
			   IsCompatible(first.Types[1], second.Types[1]) &&
			   IsCompatible(first.Types[2], second.Types[0]);
	}

} // namespace CE
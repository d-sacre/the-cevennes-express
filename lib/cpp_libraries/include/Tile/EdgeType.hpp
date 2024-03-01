#pragma once

#include <cstdint>

namespace CE
{
	namespace Tile
	{
		enum class EdgeType
		{
			None,
			// Roads
			DirtTrack,
			RoadSingle,
			RoadDouble,
			TownSquare,
			// Railroads
			RailroadSingle,
			RailroadDouble,
			// Water
			River,
			Stream,
			Lake,
			// Landscape
			Grass,
			Forest,
			Field,
			Mountain,
			// Town
			Settlement,
		};

	} // namespace Tile

	bool IsCompatible(Tile::EdgeType left, Tile::EdgeType right);
} // namespace CE

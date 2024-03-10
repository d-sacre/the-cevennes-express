#pragma once

#include <cstdint>
#include <string>

namespace CE
{
	namespace Tile
	{
		enum class EdgeType : uint8_t
		{
			None,
			// Landscape
			Grass,
			Forest,
			Field,
			Mountain,
			// Water
			Creek,
			Stream,
			RiverSmall,
			RiverLarge,
			Lake,
			// Railroads
			RailroadSingle,
			RailroadSingleBridge,
			RailroadDouble,
			RailroadDoubleBridge,
			PlatformLow,
			PlatformHighSimple,
			PlatformHighElaborate,
			// Roads
			DirtTrack,
			DirtRoadSingle,
			DirtRoadSingleStreetrunningSingle,
			DirtRoadSingleBridge,
			DirtRoadSingleBridgeStreetrunningSingle,
			DirtRoadDouble,
			DirtRoadDoubleStreetrunningSingle,
			DirtRoadDoubleStreetrunningDouble,
			DirtRoadDoubleBridge,
			DirtRoadDoubleBridgeStreetrunningSingle,
			DirtRoadDoubleBridgeStreetrunningDouble,
			RoadSingle,
			RoadSingleStreetrunningSingle,
			RoadSingleBridge,
			RoadSingleBridgeStreetrunningSingle,
			RoadDouble,
			RoadDoubleStreetrunningSingle,
			RoadDoubleStreetrunningDouble,
			RoadDoubleBridge,
			RoadDoubleBridgeStreetrunningSingle,
			RoadDoubleBridgeStreetrunningDouble,
			// Town
			Square,
			SquareStreetrunningSingle,
			SquareStreetrunningDouble,
			Buildings,
		};

	} // namespace Tile

	bool IsCompatible(Tile::EdgeType left, Tile::EdgeType right);

	// std::string ToString(Tile::EdgeType type);
} // namespace CE

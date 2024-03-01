#pragma once

#include "Tile/EdgeType.hpp"

#include <set>
#include <string>
#include <tuple>
#include <vector>

namespace EdgeTypeUtils
{
	std::string ToString(CE::Tile::EdgeType edgeTpye)
	{
		switch (edgeTpye)
		{
		case CE::Tile::EdgeType::None: return "None";
		case CE::Tile::EdgeType::DirtTrack: return "DirtTrack";
		case CE::Tile::EdgeType::RoadSingle: return "RoadSingle";
		case CE::Tile::EdgeType::RoadDouble: return "RoadDouble";
		case CE::Tile::EdgeType::TownSquare: return "TownSquare";
		case CE::Tile::EdgeType::RailroadSingle: return "RailroadSingle";
		case CE::Tile::EdgeType::RailroadDouble: return "RailroadDouble";
		case CE::Tile::EdgeType::River: return "River";
		case CE::Tile::EdgeType::Stream: return "Stream";
		case CE::Tile::EdgeType::Lake: return "Lake";
		case CE::Tile::EdgeType::Grass: return "Grass";
		case CE::Tile::EdgeType::Forest: return "Forest";
		case CE::Tile::EdgeType::Field: return "Field";
		case CE::Tile::EdgeType::Mountain: return "Mountain";
		case CE::Tile::EdgeType::Settlement: return "Settlement";
		default: return "Undefined Value";
		}
	}

	const std::set<CE::Tile::EdgeType> allEdgeTypes {
		CE::Tile::EdgeType::DirtTrack,
		CE::Tile::EdgeType::RoadSingle,
		CE::Tile::EdgeType::RoadDouble,
		CE::Tile::EdgeType::TownSquare,
		CE::Tile::EdgeType::RailroadSingle,
		CE::Tile::EdgeType::RailroadDouble,
		CE::Tile::EdgeType::River,
		CE::Tile::EdgeType::Stream,
		CE::Tile::EdgeType::Lake,
		CE::Tile::EdgeType::Grass,
		CE::Tile::EdgeType::Forest,
		CE::Tile::EdgeType::Field,
		CE::Tile::EdgeType::Mountain,
		CE::Tile::EdgeType::Settlement};

	const std::vector<std::tuple<CE::Tile::EdgeType, std::set<CE::Tile::EdgeType>>> compatibilityMapping {
		{
			CE::Tile::EdgeType::DirtTrack,
			{
			CE::Tile::EdgeType::DirtTrack,
			},
		 },
		{
			CE::Tile::EdgeType::RoadSingle,
			{
			CE::Tile::EdgeType::RoadSingle,
			},
		 },
		{
			CE::Tile::EdgeType::RoadDouble,
			{
			CE::Tile::EdgeType::RoadDouble,
			},
		 },
		{
			CE::Tile::EdgeType::TownSquare,
			{
			CE::Tile::EdgeType::TownSquare,
			CE::Tile::EdgeType::RoadSingle,
			CE::Tile::EdgeType::RoadDouble,
			},
		 },
		{
			CE::Tile::EdgeType::RailroadSingle,
			{
			CE::Tile::EdgeType::RailroadSingle,
			},
		 },
		{
			CE::Tile::EdgeType::RailroadDouble,
			{
			CE::Tile::EdgeType::RailroadDouble,
			},
		 },
		{
			CE::Tile::EdgeType::River,
			{
			CE::Tile::EdgeType::River,
			CE::Tile::EdgeType::Stream,
			},
		 },
		{
			CE::Tile::EdgeType::Stream,
			{
			CE::Tile::EdgeType::River,
			CE::Tile::EdgeType::Stream,
			CE::Tile::EdgeType::Lake,
			},
		 },
		{
			CE::Tile::EdgeType::Lake,
			{
			CE::Tile::EdgeType::Stream,
			CE::Tile::EdgeType::Lake,
			},
		 },
		{
			CE::Tile::EdgeType::Grass,
			{
			CE::Tile::EdgeType::Grass,
			CE::Tile::EdgeType::Forest,
			CE::Tile::EdgeType::Field,
			CE::Tile::EdgeType::Mountain,
			},
		 },
		{
			CE::Tile::EdgeType::Forest,
			{
			CE::Tile::EdgeType::Grass,
			CE::Tile::EdgeType::Forest,
			CE::Tile::EdgeType::Field,
			CE::Tile::EdgeType::Mountain,
			},
		 },
		{
			CE::Tile::EdgeType::Field,
			{
			CE::Tile::EdgeType::Grass,
			CE::Tile::EdgeType::Forest,
			CE::Tile::EdgeType::Field,
			CE::Tile::EdgeType::Mountain,
			},
		 },
		{
			CE::Tile::EdgeType::Mountain,
			{
			CE::Tile::EdgeType::Grass,
			CE::Tile::EdgeType::Forest,
			CE::Tile::EdgeType::Field,
			CE::Tile::EdgeType::Mountain,
			},
		 },
		{
			CE::Tile::EdgeType::Settlement,
			{
			CE::Tile::EdgeType::Settlement,
			},
		 },
	};
} // namespace EdgeTypeUtils

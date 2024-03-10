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
		case CE::Tile::EdgeType::Grass: return "Grass";
		case CE::Tile::EdgeType::Forest: return "Forest";
		case CE::Tile::EdgeType::Field: return "Field";
		case CE::Tile::EdgeType::Mountain: return "Mountain";
		case CE::Tile::EdgeType::Creek: return "Creek";
		case CE::Tile::EdgeType::Stream: return "Stream";
		case CE::Tile::EdgeType::RiverSmall: return "RiverSmall";
		case CE::Tile::EdgeType::RiverLarge: return "RiverLarge";
		case CE::Tile::EdgeType::Lake: return "Lake";
		case CE::Tile::EdgeType::RailroadSingle: return "RailroadSingle";
		case CE::Tile::EdgeType::RailroadSingleBridge: return "RailroadSingleBridge";
		case CE::Tile::EdgeType::RailroadDouble: return "RailroadDouble";
		case CE::Tile::EdgeType::RailroadDoubleBridge: return "RailroadDoubleBridge";
		case CE::Tile::EdgeType::PlatformLow: return "PlatformLow";
		case CE::Tile::EdgeType::PlatformHighSimple: return "PlatformHighSimple";
		case CE::Tile::EdgeType::PlatformHighElaborate: return "PlatformHighElaborate";
		case CE::Tile::EdgeType::DirtTrack: return "DirtTrack";
		case CE::Tile::EdgeType::DirtRoadSingle: return "DirtRoadSingle";
		case CE::Tile::EdgeType::DirtRoadSingleStreetrunningSingle: return "DirtRoadSingleStreetrunningSingle";
		case CE::Tile::EdgeType::DirtRoadSingleBridge: return "DirtRoadSingleBridge";
		case CE::Tile::EdgeType::DirtRoadSingleBridgeStreetrunningSingle: return "DirtRoadSingleBridgeStreetrunningSingle";
		case CE::Tile::EdgeType::DirtRoadDouble: return "DirtRoadDouble";
		case CE::Tile::EdgeType::DirtRoadDoubleStreetrunningSingle: return "DirtRoadDoubleStreetrunningSingle";
		case CE::Tile::EdgeType::DirtRoadDoubleStreetrunningDouble: return "DirtRoadDoubleStreetrunningDouble";
		case CE::Tile::EdgeType::DirtRoadDoubleBridge: return "DirtRoadDoubleBridge";
		case CE::Tile::EdgeType::DirtRoadDoubleBridgeStreetrunningSingle: return "DirtRoadDoubleBridgeStreetrunningSingle";
		case CE::Tile::EdgeType::DirtRoadDoubleBridgeStreetrunningDouble: return "DirtRoadDoubleBridgeStreetrunningDouble";
		case CE::Tile::EdgeType::RoadSingle: return "RoadSingle";
		case CE::Tile::EdgeType::RoadSingleBridge: return "RoadSingleBridge";
		case CE::Tile::EdgeType::RoadSingleStreetrunningSingle: return "RoadSingleStreetrunningSingle";
		case CE::Tile::EdgeType::RoadSingleBridgeStreetrunningSingle: return "RoadSingleBridgeStreetrunningSingle";
		case CE::Tile::EdgeType::RoadDouble: return "RoadDouble";
		case CE::Tile::EdgeType::RoadDoubleStreetrunningSingle: return "RoadDoubleStreetrunningSingle";
		case CE::Tile::EdgeType::RoadDoubleStreetrunningDouble: return "RoadDoubleStreetrunningDouble";
		case CE::Tile::EdgeType::RoadDoubleBridge: return "RoadDoubleBridge";
		case CE::Tile::EdgeType::RoadDoubleBridgeStreetrunningSingle: return "RoadDoubleBridgeStreetrunningSingle";
		case CE::Tile::EdgeType::RoadDoubleBridgeStreetrunningDouble: return "RoadDoubleBridgeStreetrunningDouble";
		case CE::Tile::EdgeType::Square: return "Square";
		case CE::Tile::EdgeType::SquareStreetrunningSingle: return "SquareStreetrunningSingle";
		case CE::Tile::EdgeType::SquareStreetrunningDouble: return "SquareStreetrunningDouble";
		case CE::Tile::EdgeType::Buildings: return "Buildings";
		default: return "Undefined Value";
		}
	}

	const std::set<CE::Tile::EdgeType> allEdgeTypes
	{
		CE::Tile::EdgeType::Grass,
		CE::Tile::EdgeType::Forest,
		CE::Tile::EdgeType::Field,
		CE::Tile::EdgeType::Mountain,
		CE::Tile::EdgeType::Creek,
		CE::Tile::EdgeType::Stream,
		CE::Tile::EdgeType::RiverSmall,
		CE::Tile::EdgeType::RiverLarge,
		CE::Tile::EdgeType::Lake,
		CE::Tile::EdgeType::RailroadSingle,
		CE::Tile::EdgeType::RailroadSingleBridge,
		CE::Tile::EdgeType::RailroadDouble,
		CE::Tile::EdgeType::RailroadDoubleBridge,
		CE::Tile::EdgeType::PlatformLow,
		CE::Tile::EdgeType::PlatformHighSimple,
		CE::Tile::EdgeType::PlatformHighElaborate,
		CE::Tile::EdgeType::DirtTrack,
		CE::Tile::EdgeType::DirtRoadSingle,
		CE::Tile::EdgeType::DirtRoadSingleStreetrunningSingle,
		CE::Tile::EdgeType::DirtRoadSingleBridge,
		CE::Tile::EdgeType::DirtRoadSingleBridgeStreetrunningSingle,
		CE::Tile::EdgeType::DirtRoadDouble,
		CE::Tile::EdgeType::DirtRoadDoubleStreetrunningSingle,
		CE::Tile::EdgeType::DirtRoadDoubleStreetrunningDouble,
		CE::Tile::EdgeType::DirtRoadDoubleBridge,
		CE::Tile::EdgeType::DirtRoadDoubleBridgeStreetrunningSingle,
		CE::Tile::EdgeType::DirtRoadDoubleBridgeStreetrunningDouble,
		CE::Tile::EdgeType::RoadSingle,
		CE::Tile::EdgeType::RoadSingleStreetrunningSingle,
		CE::Tile::EdgeType::RoadSingleBridge,
		CE::Tile::EdgeType::RoadSingleBridgeStreetrunningSingle,
		CE::Tile::EdgeType::RoadDouble,
		CE::Tile::EdgeType::RoadDoubleStreetrunningSingle,
		CE::Tile::EdgeType::RoadDoubleStreetrunningDouble,
		CE::Tile::EdgeType::RoadDoubleBridge,
		CE::Tile::EdgeType::RoadDoubleBridgeStreetrunningSingle,
		CE::Tile::EdgeType::RoadDoubleBridgeStreetrunningDouble,
		CE::Tile::EdgeType::Square,
		CE::Tile::EdgeType::SquareStreetrunningSingle,
		CE::Tile::EdgeType::SquareStreetrunningDouble,
		CE::Tile::EdgeType::Buildings,
	};

	const std::vector<std::tuple<CE::Tile::EdgeType, std::set<CE::Tile::EdgeType>>> compatibilityMapping
	{
		{
			CE::Tile::EdgeType::Grass,
			{
			CE::Tile::EdgeType::Grass,
			CE::Tile::EdgeType::Forest,
			CE::Tile::EdgeType::Field,
			CE::Tile::EdgeType::Lake,
			CE::Tile::EdgeType::Square,
			CE::Tile::EdgeType::Buildings,
			},
		 },
		{
			CE::Tile::EdgeType::Forest,
			{
			CE::Tile::EdgeType::Grass,
			CE::Tile::EdgeType::Forest,
			CE::Tile::EdgeType::Field,
			CE::Tile::EdgeType::Lake,
			},
		 },
		{
			CE::Tile::EdgeType::Field,
			{
			CE::Tile::EdgeType::Grass,
			CE::Tile::EdgeType::Forest,
			CE::Tile::EdgeType::Field,
			},
		 },
		{
			CE::Tile::EdgeType::Mountain,
			{
			CE::Tile::EdgeType::Mountain,
			},
		 },
		 {
			CE::Tile::EdgeType::Creek,
			{
			CE::Tile::EdgeType::Creek,
			CE::Tile::EdgeType::Lake,
			},
		 },
		 {
			CE::Tile::EdgeType::Stream,
			{
			CE::Tile::EdgeType::Stream,
			CE::Tile::EdgeType::Lake,
			},
		 },
		 {
			CE::Tile::EdgeType::RiverSmall,
			{
			CE::Tile::EdgeType::RiverSmall,
			CE::Tile::EdgeType::Lake,
			},
		 },
		 {
			CE::Tile::EdgeType::RiverLarge,
			{
			CE::Tile::EdgeType::RiverLarge,
			CE::Tile::EdgeType::Lake,
			},
		 },
		 {
			CE::Tile::EdgeType::Lake,
			{
			CE::Tile::EdgeType::Lake,
			CE::Tile::EdgeType::Creek,
			CE::Tile::EdgeType::Stream,
			CE::Tile::EdgeType::RiverSmall,
			CE::Tile::EdgeType::RiverLarge,
			CE::Tile::EdgeType::Grass,
			CE::Tile::EdgeType::Forest,
			},
		 },
		 {
			CE::Tile::EdgeType::RailroadSingle,
			{
			CE::Tile::EdgeType::RailroadSingle,
			CE::Tile::EdgeType::RailroadSingleBridge,
			},
		 },
		 {
			CE::Tile::EdgeType::RailroadSingleBridge,
			{
			CE::Tile::EdgeType::RailroadSingleBridge,
			CE::Tile::EdgeType::RailroadSingle,
			},
		 },
		 {
			CE::Tile::EdgeType::RailroadDouble,
			{
			CE::Tile::EdgeType::RailroadDouble,
			CE::Tile::EdgeType::RailroadDoubleBridge,
			},
		 },
		 {
			CE::Tile::EdgeType::RailroadDoubleBridge,
			{
			CE::Tile::EdgeType::RailroadDoubleBridge,
			CE::Tile::EdgeType::RailroadDouble,
			},
		 },
		 {
			CE::Tile::EdgeType::PlatformLow,
			{
			CE::Tile::EdgeType::PlatformLow,
			CE::Tile::EdgeType::PlatformHighSimple,
			CE::Tile::EdgeType::PlatformHighElaborate,
			},
		 },
		 {
			CE::Tile::EdgeType::PlatformHighSimple,
			{
			CE::Tile::EdgeType::PlatformHighSimple,
			CE::Tile::EdgeType::PlatformLow,
			},
		 },
		 {
			CE::Tile::EdgeType::PlatformHighElaborate,
			{
			CE::Tile::EdgeType::PlatformHighElaborate,
			CE::Tile::EdgeType::PlatformLow,
			},
		 },
		 {
			CE::Tile::EdgeType::DirtTrack,
			{
			CE::Tile::EdgeType::DirtTrack,
			},
		 },
		 {
			CE::Tile::EdgeType::DirtRoadSingle,
			{
			CE::Tile::EdgeType::DirtRoadSingle,
			CE::Tile::EdgeType::DirtRoadSingleBridge,
			CE::Tile::EdgeType::RoadSingle,
			CE::Tile::EdgeType::RoadSingleBridge,
			CE::Tile::EdgeType::Square,
			},
		 },
		 {
			CE::Tile::EdgeType::DirtRoadSingleStreetrunningSingle,
			{
			CE::Tile::EdgeType::DirtRoadSingleStreetrunningSingle,
			CE::Tile::EdgeType::DirtRoadSingleBridgeStreetrunningSingle,
			CE::Tile::EdgeType::RoadSingleStreetrunningSingle,
			CE::Tile::EdgeType::RoadSingleBridgeStreetrunningSingle,
			CE::Tile::EdgeType::SquareStreetrunningSingle,
			},
		 },
		 {
			CE::Tile::EdgeType::DirtRoadSingleBridge,
			{
			CE::Tile::EdgeType::DirtRoadSingleBridge,
			CE::Tile::EdgeType::DirtRoadSingle,
			CE::Tile::EdgeType::RoadSingle,
			CE::Tile::EdgeType::RoadSingleBridge,
			},
		 },
		 {
			CE::Tile::EdgeType::DirtRoadSingleBridgeStreetrunningSingle,
			{
			CE::Tile::EdgeType::DirtRoadSingleBridgeStreetrunningSingle,
			CE::Tile::EdgeType::DirtRoadSingleStreetrunningSingle,
			CE::Tile::EdgeType::RoadSingleBridgeStreetrunningSingle,
			CE::Tile::EdgeType::RoadSingleStreetrunningSingle,
			},
		 },
		 {
			CE::Tile::EdgeType::DirtRoadDouble,
			{
			CE::Tile::EdgeType::DirtRoadDouble,
			CE::Tile::EdgeType::DirtRoadDoubleBridge,
			CE::Tile::EdgeType::RoadDouble,
			CE::Tile::EdgeType::RoadDoubleBridge,
			CE::Tile::EdgeType::Square,
			},
		 },
		 {
			CE::Tile::EdgeType::DirtRoadDoubleStreetrunningSingle,
			{
			CE::Tile::EdgeType::DirtRoadDoubleStreetrunningSingle,
			CE::Tile::EdgeType::DirtRoadDoubleBridgeStreetrunningSingle,
			CE::Tile::EdgeType::RoadDoubleStreetrunningSingle,
			CE::Tile::EdgeType::RoadDoubleBridgeStreetrunningSingle,
			CE::Tile::EdgeType::SquareStreetrunningSingle,
			},
		 },
		 {
			CE::Tile::EdgeType::DirtRoadDoubleStreetrunningDouble,
			{
			CE::Tile::EdgeType::DirtRoadDoubleStreetrunningDouble,
			CE::Tile::EdgeType::DirtRoadDoubleBridgeStreetrunningDouble,
			CE::Tile::EdgeType::RoadDoubleStreetrunningDouble,
			CE::Tile::EdgeType::RoadDoubleBridgeStreetrunningDouble,
			CE::Tile::EdgeType::SquareStreetrunningDouble,
			},
		 },
		 {
			CE::Tile::EdgeType::DirtRoadDoubleBridge,
			{
			CE::Tile::EdgeType::DirtRoadDoubleBridge,
			CE::Tile::EdgeType::DirtRoadDouble,
			CE::Tile::EdgeType::RoadDouble,
			CE::Tile::EdgeType::RoadDoubleBridge,
			},
		 },
		 {
			CE::Tile::EdgeType::DirtRoadDoubleBridgeStreetrunningSingle,
			{
			CE::Tile::EdgeType::DirtRoadDoubleBridgeStreetrunningSingle,
			CE::Tile::EdgeType::DirtRoadDoubleStreetrunningSingle,
			CE::Tile::EdgeType::RoadDoubleStreetrunningSingle,
			CE::Tile::EdgeType::RoadDoubleBridgeStreetrunningSingle,
			},
		 },
		 {
			CE::Tile::EdgeType::DirtRoadDoubleBridgeStreetrunningDouble,
			{
			CE::Tile::EdgeType::DirtRoadDoubleBridgeStreetrunningDouble,
			CE::Tile::EdgeType::DirtRoadDoubleStreetrunningDouble,
			CE::Tile::EdgeType::RoadDoubleStreetrunningDouble,
			CE::Tile::EdgeType::RoadDoubleBridgeStreetrunningDouble,
			},
		 },
		 {
			CE::Tile::EdgeType::RoadSingle,
			{
			CE::Tile::EdgeType::RoadSingle,
			CE::Tile::EdgeType::RoadSingleBridge,
			CE::Tile::EdgeType::DirtRoadSingle,
			CE::Tile::EdgeType::DirtRoadSingleBridge,
			CE::Tile::EdgeType::Square,
			},
		 },
		 {
			CE::Tile::EdgeType::RoadSingleStreetrunningSingle,
			{
			CE::Tile::EdgeType::RoadSingleStreetrunningSingle,
			CE::Tile::EdgeType::RoadSingleBridgeStreetrunningSingle,
			CE::Tile::EdgeType::DirtRoadSingleStreetrunningSingle,
			CE::Tile::EdgeType::DirtRoadSingleBridgeStreetrunningSingle,
			CE::Tile::EdgeType::SquareStreetrunningSingle,
			},
		 },
		 {
			CE::Tile::EdgeType::RoadSingleBridge,
			{
			CE::Tile::EdgeType::RoadSingleBridge,
			CE::Tile::EdgeType::RoadSingle,
			CE::Tile::EdgeType::DirtRoadSingle,
			CE::Tile::EdgeType::DirtRoadSingleBridge,
			},
		 },
		 {
			CE::Tile::EdgeType::RoadSingleBridgeStreetrunningSingle,
			{
			CE::Tile::EdgeType::RoadSingleBridgeStreetrunningSingle,
			CE::Tile::EdgeType::RoadSingleStreetrunningSingle,
			CE::Tile::EdgeType::DirtRoadSingleStreetrunningSingle,
			CE::Tile::EdgeType::DirtRoadSingleBridgeStreetrunningSingle,
			},
		 },
		 {
			CE::Tile::EdgeType::RoadDouble,
			{
			CE::Tile::EdgeType::RoadDouble,
			CE::Tile::EdgeType::RoadDoubleBridge,
			CE::Tile::EdgeType::DirtRoadDouble,
			CE::Tile::EdgeType::DirtRoadDoubleBridge,
			CE::Tile::EdgeType::Square,
			},
		 },
		 {
			CE::Tile::EdgeType::RoadDoubleBridgeStreetrunningSingle,
			{
			CE::Tile::EdgeType::RoadDoubleBridgeStreetrunningSingle,
			CE::Tile::EdgeType::RoadDoubleStreetrunningSingle,
			CE::Tile::EdgeType::DirtRoadDoubleStreetrunningSingle,
			CE::Tile::EdgeType::DirtRoadDoubleBridgeStreetrunningSingle,
			},
		 },
		 {
			CE::Tile::EdgeType::RoadDoubleBridgeStreetrunningDouble,
			{
			CE::Tile::EdgeType::RoadDoubleBridgeStreetrunningDouble,
			CE::Tile::EdgeType::RoadDoubleStreetrunningDouble,
			CE::Tile::EdgeType::DirtRoadDoubleStreetrunningDouble,
			CE::Tile::EdgeType::DirtRoadDoubleBridgeStreetrunningDouble,
			},
		 },
		 {
			CE::Tile::EdgeType::RoadDoubleBridge,
			{
			CE::Tile::EdgeType::RoadDoubleBridge,
			CE::Tile::EdgeType::RoadDouble,
			CE::Tile::EdgeType::DirtRoadDouble,
			CE::Tile::EdgeType::DirtRoadDoubleBridge,
			},
		 },
		 {
			CE::Tile::EdgeType::RoadDoubleStreetrunningSingle,
			{
			CE::Tile::EdgeType::RoadDoubleStreetrunningSingle,
			CE::Tile::EdgeType::RoadDoubleBridgeStreetrunningSingle,
			CE::Tile::EdgeType::DirtRoadDoubleStreetrunningSingle,
			CE::Tile::EdgeType::DirtRoadDoubleBridgeStreetrunningSingle,
			CE::Tile::EdgeType::SquareStreetrunningSingle,
			},
		 },
		 {
			CE::Tile::EdgeType::RoadDoubleStreetrunningDouble,
			{
			CE::Tile::EdgeType::RoadDoubleStreetrunningDouble,
			CE::Tile::EdgeType::RoadDoubleBridgeStreetrunningDouble,
			CE::Tile::EdgeType::DirtRoadDoubleStreetrunningDouble,
			CE::Tile::EdgeType::DirtRoadDoubleBridgeStreetrunningDouble,
			CE::Tile::EdgeType::SquareStreetrunningDouble,
			},
		 },
		 {
			CE::Tile::EdgeType::Square,
			{
			CE::Tile::EdgeType::Square,
			CE::Tile::EdgeType::RoadSingle,
			CE::Tile::EdgeType::RoadDouble,
			CE::Tile::EdgeType::DirtRoadSingle,
			CE::Tile::EdgeType::DirtRoadDouble,
			CE::Tile::EdgeType::Buildings,
			CE::Tile::EdgeType::Grass,
			},
		 },
		 {
			CE::Tile::EdgeType::SquareStreetrunningSingle,
			{
			CE::Tile::EdgeType::SquareStreetrunningSingle,
			CE::Tile::EdgeType::RoadSingleStreetrunningSingle,
			CE::Tile::EdgeType::RoadDoubleStreetrunningSingle,
			CE::Tile::EdgeType::DirtRoadSingleStreetrunningSingle,
			CE::Tile::EdgeType::DirtRoadDoubleStreetrunningSingle,
			},
		 },
		 {
			CE::Tile::EdgeType::SquareStreetrunningDouble,
			{
			CE::Tile::EdgeType::SquareStreetrunningDouble,
			CE::Tile::EdgeType::RoadDoubleStreetrunningDouble,
			CE::Tile::EdgeType::DirtRoadDoubleStreetrunningDouble,
			},
		 },
		 {
			CE::Tile::EdgeType::Buildings,
			{
			CE::Tile::EdgeType::Buildings,
			CE::Tile::EdgeType::Square,
			CE::Tile::EdgeType::Grass,
			},
		 },
	};
} // namespace EdgeTypeUtils

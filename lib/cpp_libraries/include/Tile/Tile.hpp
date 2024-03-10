#pragma once

#include "Tile/Edge.hpp"

#include <array>
#include <type_traits>

namespace CE
{
	namespace Tile
	{
		enum class Direction : uint8_t
		{
			Top = 0,
			TopRight = 1,
			BottomRight = 2,
			Bottom = 3,
			BottomLeft = 4,
			TopLeft = 5,
		};

		struct Tile
		{
			std::array<Edge, 6> Edges {Edge(), Edge(), Edge(), Edge(), Edge(), Edge()};
			
			friend bool operator==(const Tile& lhs, const Tile& rhs) = default;
			const Edge& operator[](Direction direction) const;
			Edge& operator[](Direction direction);
		};

		enum class Rotation : uint8_t
		{
			Degree_60 = 1,
			Degree_120 = 2,
			Degree_180 = 3,
			Degree_240 = 4,
			Degree_300 = 5,
		};

		Tile Rotate(const Tile& /*tile*/, Rotation /*rotation*/);
		Direction Opposite(const Direction);
	} // namespace Tile

	bool IsCompatible(const Tile::Tile& center, const Tile::Tile& outer, const Tile::Direction direction);

} // namespace CE

#include "Tile/Tile.hpp"

#include <stdexcept>

namespace CE
{
    namespace Tile
    {
        const Edge& Tile::operator[](Direction direction) const
        {
            auto offset = static_cast<std::underlying_type_t<Rotation>>(direction);
            return Edges[offset];
        }
        Edge& Tile::operator[](Direction direction)
        {
            auto offset = static_cast<std::underlying_type_t<Rotation>>(direction);
            return Edges[offset];
        }

        Tile Rotate(const Tile& tile, Rotation rotation)
        {
            auto offset = static_cast<std::underlying_type_t<Rotation>>(rotation);
            return {tile.Edges[(0 + offset) % 6], tile.Edges[(1 + offset) % 6], tile.Edges[(2 + offset) % 6],
                    tile.Edges[(3 + offset) % 6], tile.Edges[(4 + offset) % 6], tile.Edges[(5 + offset) % 6]};
        }

        Direction Opposite(const Direction direction)
        {
            switch (direction)
            {
            case Direction::Top: return Direction::Bottom;
            case Direction::TopRight: return Direction::BottomLeft;
            case Direction::BottomRight: return Direction::TopLeft;
            case Direction::Bottom: return Direction::Top;
            case Direction::BottomLeft: return Direction::TopRight;
            case Direction::TopLeft: return Direction::BottomRight;
            }
            throw std::runtime_error("Invalid direction used!");
        }
    } // Tile

    bool IsCompatible(const Tile::Tile& center, const Tile::Tile& outer, const Tile::Direction direction)
    {
        return IsCompatible(center[direction], outer[Tile::Opposite(direction)]);
    }
} // CE
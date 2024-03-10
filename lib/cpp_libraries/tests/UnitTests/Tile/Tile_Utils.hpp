#pragma once

namespace CE
{
    bool IsCompatible(const Tile::Edge& one, const Tile::Edge& two)
    {
        return one == two;
    }
}
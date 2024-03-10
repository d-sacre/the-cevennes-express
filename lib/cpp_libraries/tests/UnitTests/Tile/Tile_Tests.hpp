#pragma once

#include "Tile/Tile.hpp"
#include "Tile_Utils.hpp"

#include <gtest/gtest.h>

namespace
{
    const CE::Tile::Edge edge1{CE::Tile::EdgeType::Forest, CE::Tile::EdgeType::Forest, CE::Tile::EdgeType::Forest};
    const CE::Tile::Edge edge2{CE::Tile::EdgeType::Square, CE::Tile::EdgeType::Square, CE::Tile::EdgeType::Square};

    TEST(Tile_Tests, EdgeAccessConst)
    {
        ASSERT_TRUE(CE::IsCompatible(edge1, edge1));
        ASSERT_TRUE(CE::IsCompatible(edge2, edge2));
        ASSERT_FALSE(CE::IsCompatible(edge1, edge2));

        const CE::Tile::Tile tileTop         {edge2, edge1, edge1, edge1, edge1, edge1};
        const CE::Tile::Tile tileTopRight    {edge1, edge2, edge1, edge1, edge1, edge1};
        const CE::Tile::Tile tileBottomRight {edge1, edge1, edge2, edge1, edge1, edge1};
        const CE::Tile::Tile tileBottom      {edge1, edge1, edge1, edge2, edge1, edge1};
        const CE::Tile::Tile tileBottomLeft  {edge1, edge1, edge1, edge1, edge2, edge1};
        const CE::Tile::Tile tileTopLeft     {edge1, edge1, edge1, edge1, edge1, edge2};

        EXPECT_EQ(tileTop[CE::Tile::Direction::Top], edge2);
        EXPECT_NE(tileTop[CE::Tile::Direction::TopRight], edge2);
        EXPECT_NE(tileTop[CE::Tile::Direction::BottomRight], edge2);
        EXPECT_NE(tileTop[CE::Tile::Direction::Bottom], edge2);
        EXPECT_NE(tileTop[CE::Tile::Direction::BottomLeft], edge2);
        EXPECT_NE(tileTop[CE::Tile::Direction::TopLeft], edge2);

        EXPECT_NE(tileTopRight[CE::Tile::Direction::Top], edge2);
        EXPECT_EQ(tileTopRight[CE::Tile::Direction::TopRight], edge2);
        EXPECT_NE(tileTopRight[CE::Tile::Direction::BottomRight], edge2);
        EXPECT_NE(tileTopRight[CE::Tile::Direction::Bottom], edge2);
        EXPECT_NE(tileTopRight[CE::Tile::Direction::BottomLeft], edge2);
        EXPECT_NE(tileTopRight[CE::Tile::Direction::TopLeft], edge2);

        EXPECT_NE(tileBottomRight[CE::Tile::Direction::Top], edge2);
        EXPECT_NE(tileBottomRight[CE::Tile::Direction::TopRight], edge2);
        EXPECT_EQ(tileBottomRight[CE::Tile::Direction::BottomRight], edge2);
        EXPECT_NE(tileBottomRight[CE::Tile::Direction::Bottom], edge2);
        EXPECT_NE(tileBottomRight[CE::Tile::Direction::BottomLeft], edge2);
        EXPECT_NE(tileBottomRight[CE::Tile::Direction::TopLeft], edge2);

        EXPECT_NE(tileBottom[CE::Tile::Direction::Top], edge2);
        EXPECT_NE(tileBottom[CE::Tile::Direction::TopRight], edge2);
        EXPECT_NE(tileBottom[CE::Tile::Direction::BottomRight], edge2);
        EXPECT_EQ(tileBottom[CE::Tile::Direction::Bottom], edge2);
        EXPECT_NE(tileBottom[CE::Tile::Direction::BottomLeft], edge2);
        EXPECT_NE(tileBottom[CE::Tile::Direction::TopLeft], edge2);

        EXPECT_NE(tileBottomLeft[CE::Tile::Direction::Top], edge2);
        EXPECT_NE(tileBottomLeft[CE::Tile::Direction::TopRight], edge2);
        EXPECT_NE(tileBottomLeft[CE::Tile::Direction::BottomRight], edge2);
        EXPECT_NE(tileBottomLeft[CE::Tile::Direction::Bottom], edge2);
        EXPECT_EQ(tileBottomLeft[CE::Tile::Direction::BottomLeft], edge2);
        EXPECT_NE(tileBottomLeft[CE::Tile::Direction::TopLeft], edge2);

        EXPECT_NE(tileTopLeft[CE::Tile::Direction::Top], edge2);
        EXPECT_NE(tileTopLeft[CE::Tile::Direction::TopRight], edge2);
        EXPECT_NE(tileTopLeft[CE::Tile::Direction::BottomRight], edge2);
        EXPECT_NE(tileTopLeft[CE::Tile::Direction::Bottom], edge2);
        EXPECT_NE(tileTopLeft[CE::Tile::Direction::BottomLeft], edge2);
        EXPECT_EQ(tileTopLeft[CE::Tile::Direction::TopLeft], edge2);
    }

    TEST(Tile_Tests, EdgeAccessNonConst)
    {
        ASSERT_TRUE(CE::IsCompatible(edge1, edge1));
        ASSERT_TRUE(CE::IsCompatible(edge2, edge2));
        ASSERT_FALSE(CE::IsCompatible(edge1, edge2));

        CE::Tile::Tile tileTop         {edge2, edge1, edge1, edge1, edge1, edge1};
        CE::Tile::Tile tileTopRight    {edge1, edge2, edge1, edge1, edge1, edge1};
        CE::Tile::Tile tileBottomRight {edge1, edge1, edge2, edge1, edge1, edge1};
        CE::Tile::Tile tileBottom      {edge1, edge1, edge1, edge2, edge1, edge1};
        CE::Tile::Tile tileBottomLeft  {edge1, edge1, edge1, edge1, edge2, edge1};
        CE::Tile::Tile tileTopLeft     {edge1, edge1, edge1, edge1, edge1, edge2};

        EXPECT_EQ(tileTop[CE::Tile::Direction::Top], edge2);
        EXPECT_NE(tileTop[CE::Tile::Direction::TopRight], edge2);
        EXPECT_NE(tileTop[CE::Tile::Direction::BottomRight], edge2);
        EXPECT_NE(tileTop[CE::Tile::Direction::Bottom], edge2);
        EXPECT_NE(tileTop[CE::Tile::Direction::BottomLeft], edge2);
        EXPECT_NE(tileTop[CE::Tile::Direction::TopLeft], edge2);

        EXPECT_NE(tileTopRight[CE::Tile::Direction::Top], edge2);
        EXPECT_EQ(tileTopRight[CE::Tile::Direction::TopRight], edge2);
        EXPECT_NE(tileTopRight[CE::Tile::Direction::BottomRight], edge2);
        EXPECT_NE(tileTopRight[CE::Tile::Direction::Bottom], edge2);
        EXPECT_NE(tileTopRight[CE::Tile::Direction::BottomLeft], edge2);
        EXPECT_NE(tileTopRight[CE::Tile::Direction::TopLeft], edge2);

        EXPECT_NE(tileBottomRight[CE::Tile::Direction::Top], edge2);
        EXPECT_NE(tileBottomRight[CE::Tile::Direction::TopRight], edge2);
        EXPECT_EQ(tileBottomRight[CE::Tile::Direction::BottomRight], edge2);
        EXPECT_NE(tileBottomRight[CE::Tile::Direction::Bottom], edge2);
        EXPECT_NE(tileBottomRight[CE::Tile::Direction::BottomLeft], edge2);
        EXPECT_NE(tileBottomRight[CE::Tile::Direction::TopLeft], edge2);

        EXPECT_NE(tileBottom[CE::Tile::Direction::Top], edge2);
        EXPECT_NE(tileBottom[CE::Tile::Direction::TopRight], edge2);
        EXPECT_NE(tileBottom[CE::Tile::Direction::BottomRight], edge2);
        EXPECT_EQ(tileBottom[CE::Tile::Direction::Bottom], edge2);
        EXPECT_NE(tileBottom[CE::Tile::Direction::BottomLeft], edge2);
        EXPECT_NE(tileBottom[CE::Tile::Direction::TopLeft], edge2);

        EXPECT_NE(tileBottomLeft[CE::Tile::Direction::Top], edge2);
        EXPECT_NE(tileBottomLeft[CE::Tile::Direction::TopRight], edge2);
        EXPECT_NE(tileBottomLeft[CE::Tile::Direction::BottomRight], edge2);
        EXPECT_NE(tileBottomLeft[CE::Tile::Direction::Bottom], edge2);
        EXPECT_EQ(tileBottomLeft[CE::Tile::Direction::BottomLeft], edge2);
        EXPECT_NE(tileBottomLeft[CE::Tile::Direction::TopLeft], edge2);

        EXPECT_NE(tileTopLeft[CE::Tile::Direction::Top], edge2);
        EXPECT_NE(tileTopLeft[CE::Tile::Direction::TopRight], edge2);
        EXPECT_NE(tileTopLeft[CE::Tile::Direction::BottomRight], edge2);
        EXPECT_NE(tileTopLeft[CE::Tile::Direction::Bottom], edge2);
        EXPECT_NE(tileTopLeft[CE::Tile::Direction::BottomLeft], edge2);
        EXPECT_EQ(tileTopLeft[CE::Tile::Direction::TopLeft], edge2);
    }

    TEST(Tile_Tests, Rotation)
    {
        ASSERT_TRUE(CE::IsCompatible(edge1, edge1));
        ASSERT_TRUE(CE::IsCompatible(edge2, edge2));
        ASSERT_FALSE(CE::IsCompatible(edge1, edge2));

        const CE::Tile::Tile original{edge1, edge2, edge2, edge2, edge2, edge2};
        const CE::Tile::Tile rotated60{edge2, edge2, edge2, edge2, edge2, edge1};
        const CE::Tile::Tile rotated120{edge2, edge2, edge2, edge2, edge1, edge2};
        const CE::Tile::Tile rotated180{edge2, edge2, edge2, edge1, edge2, edge2};
        const CE::Tile::Tile rotated240{edge2, edge2, edge1, edge2, edge2, edge2};
        const CE::Tile::Tile rotated300{edge2, edge1, edge2, edge2, edge2, edge2};

        EXPECT_EQ(original, original);
        EXPECT_EQ(rotated60, CE::Tile::Rotate(original, CE::Tile::Rotation::Degree_60));
        EXPECT_EQ(rotated120, CE::Tile::Rotate(original, CE::Tile::Rotation::Degree_120));
        EXPECT_EQ(rotated180, CE::Tile::Rotate(original, CE::Tile::Rotation::Degree_180));
        EXPECT_EQ(rotated240, CE::Tile::Rotate(original, CE::Tile::Rotation::Degree_240));
        EXPECT_EQ(rotated300, CE::Tile::Rotate(original, CE::Tile::Rotation::Degree_300));
    }

    TEST(Tile_Tests, OppositeDirection)
    {
        EXPECT_EQ(CE::Tile::Direction::Top,         CE::Tile::Opposite(CE::Tile::Direction::Bottom));
        EXPECT_EQ(CE::Tile::Direction::TopRight,    CE::Tile::Opposite(CE::Tile::Direction::BottomLeft));
        EXPECT_EQ(CE::Tile::Direction::BottomRight, CE::Tile::Opposite(CE::Tile::Direction::TopLeft));
        EXPECT_EQ(CE::Tile::Direction::Bottom,      CE::Tile::Opposite(CE::Tile::Direction::Top));
        EXPECT_EQ(CE::Tile::Direction::BottomLeft,  CE::Tile::Opposite(CE::Tile::Direction::TopRight));
        EXPECT_EQ(CE::Tile::Direction::TopLeft,     CE::Tile::Opposite(CE::Tile::Direction::BottomRight));
    }
    
    TEST(Tile_Tests, IsCompatible)
    {
        ASSERT_TRUE(CE::IsCompatible(edge1, edge1));
        ASSERT_TRUE(CE::IsCompatible(edge2, edge2));
        ASSERT_FALSE(CE::IsCompatible(edge1, edge2));

        const CE::Tile::Tile tileCenter         {edge2, edge2, edge2, edge2, edge2, edge2};
        const CE::Tile::Tile tileOutTop         {edge1, edge1, edge1, edge2, edge1, edge1};
        const CE::Tile::Tile tileOutTopRight    {edge1, edge1, edge1, edge1, edge2, edge1};
        const CE::Tile::Tile tileOutBottomRight {edge1, edge1, edge1, edge1, edge1, edge2};
        const CE::Tile::Tile tileOutBottom      {edge2, edge1, edge1, edge1, edge1, edge1};
        const CE::Tile::Tile tileOutBottomLeft  {edge1, edge2, edge1, edge1, edge1, edge1};
        const CE::Tile::Tile tileOutTopLeft     {edge1, edge1, edge2, edge1, edge1, edge1};

        EXPECT_TRUE(CE::IsCompatible(tileCenter, tileOutTop, CE::Tile::Direction::Top));
        EXPECT_FALSE(CE::IsCompatible(tileCenter, tileOutTop, CE::Tile::Direction::TopRight));
        EXPECT_FALSE(CE::IsCompatible(tileCenter, tileOutTop, CE::Tile::Direction::BottomRight));
        EXPECT_FALSE(CE::IsCompatible(tileCenter, tileOutTop, CE::Tile::Direction::Bottom));
        EXPECT_FALSE(CE::IsCompatible(tileCenter, tileOutTop, CE::Tile::Direction::BottomLeft));
        EXPECT_FALSE(CE::IsCompatible(tileCenter, tileOutTop, CE::Tile::Direction::TopLeft));

        EXPECT_FALSE(CE::IsCompatible(tileCenter, tileOutTopRight, CE::Tile::Direction::Top));
        EXPECT_TRUE(CE::IsCompatible(tileCenter, tileOutTopRight, CE::Tile::Direction::TopRight));
        EXPECT_FALSE(CE::IsCompatible(tileCenter, tileOutTopRight, CE::Tile::Direction::BottomRight));
        EXPECT_FALSE(CE::IsCompatible(tileCenter, tileOutTopRight, CE::Tile::Direction::Bottom));
        EXPECT_FALSE(CE::IsCompatible(tileCenter, tileOutTopRight, CE::Tile::Direction::BottomLeft));
        EXPECT_FALSE(CE::IsCompatible(tileCenter, tileOutTopRight, CE::Tile::Direction::TopLeft));

        EXPECT_FALSE(CE::IsCompatible(tileCenter, tileOutBottomRight, CE::Tile::Direction::Top));
        EXPECT_FALSE(CE::IsCompatible(tileCenter, tileOutBottomRight, CE::Tile::Direction::TopRight));
        EXPECT_TRUE(CE::IsCompatible(tileCenter, tileOutBottomRight, CE::Tile::Direction::BottomRight));
        EXPECT_FALSE(CE::IsCompatible(tileCenter, tileOutBottomRight, CE::Tile::Direction::Bottom));
        EXPECT_FALSE(CE::IsCompatible(tileCenter, tileOutBottomRight, CE::Tile::Direction::BottomLeft));
        EXPECT_FALSE(CE::IsCompatible(tileCenter, tileOutBottomRight, CE::Tile::Direction::TopLeft));

        EXPECT_FALSE(CE::IsCompatible(tileCenter, tileOutBottom, CE::Tile::Direction::Top));
        EXPECT_FALSE(CE::IsCompatible(tileCenter, tileOutBottom, CE::Tile::Direction::TopRight));
        EXPECT_FALSE(CE::IsCompatible(tileCenter, tileOutBottom, CE::Tile::Direction::BottomRight));
        EXPECT_TRUE(CE::IsCompatible(tileCenter, tileOutBottom, CE::Tile::Direction::Bottom));
        EXPECT_FALSE(CE::IsCompatible(tileCenter, tileOutBottom, CE::Tile::Direction::BottomLeft));
        EXPECT_FALSE(CE::IsCompatible(tileCenter, tileOutBottom, CE::Tile::Direction::TopLeft));

        EXPECT_FALSE(CE::IsCompatible(tileCenter, tileOutBottomLeft, CE::Tile::Direction::Top));
        EXPECT_FALSE(CE::IsCompatible(tileCenter, tileOutBottomLeft, CE::Tile::Direction::TopRight));
        EXPECT_FALSE(CE::IsCompatible(tileCenter, tileOutBottomLeft, CE::Tile::Direction::BottomRight));
        EXPECT_FALSE(CE::IsCompatible(tileCenter, tileOutBottomLeft, CE::Tile::Direction::Bottom));
        EXPECT_TRUE(CE::IsCompatible(tileCenter, tileOutBottomLeft, CE::Tile::Direction::BottomLeft));
        EXPECT_FALSE(CE::IsCompatible(tileCenter, tileOutBottomLeft, CE::Tile::Direction::TopLeft));

        EXPECT_FALSE(CE::IsCompatible(tileCenter, tileOutTopLeft, CE::Tile::Direction::Top));
        EXPECT_FALSE(CE::IsCompatible(tileCenter, tileOutTopLeft, CE::Tile::Direction::TopRight));
        EXPECT_FALSE(CE::IsCompatible(tileCenter, tileOutTopLeft, CE::Tile::Direction::BottomRight));
        EXPECT_FALSE(CE::IsCompatible(tileCenter, tileOutTopLeft, CE::Tile::Direction::Bottom));
        EXPECT_FALSE(CE::IsCompatible(tileCenter, tileOutTopLeft, CE::Tile::Direction::BottomLeft));
        EXPECT_TRUE(CE::IsCompatible(tileCenter, tileOutTopLeft, CE::Tile::Direction::TopLeft));
    }
}

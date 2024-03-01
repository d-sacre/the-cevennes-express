#pragma once

#include "Edge_Utils.hpp"
#include "Tile/Edge.hpp"

#include <gtest/gtest.h>

namespace
{
	testing::AssertionResult IsCompatible(const CE::Tile::Edge& one, const CE::Tile::Edge& two)
	{
		if (CE::IsCompatible(one, two) && CE::IsCompatible(two, one))
		{
			return testing::AssertionSuccess();
		}
		else if (!CE::IsCompatible(one, two) && CE::IsCompatible(two, one))
		{
			return testing::AssertionFailure() << EdgeUtils::ToString(one) << " is not compatible with " << EdgeUtils::ToString(two) << " but "
											   << EdgeUtils::ToString(two) << " is compatible with " << EdgeUtils::ToString(one);
		}
		else if (CE::IsCompatible(one, two) && !CE::IsCompatible(two, one))
		{
			return testing::AssertionFailure() << EdgeUtils::ToString(two) << " is not compatible with " << EdgeUtils::ToString(one) << " but "
											   << EdgeUtils::ToString(one) << " is compatible with " << EdgeUtils::ToString(two);
		}
		else
		{
			return testing::AssertionFailure() << EdgeUtils::ToString(one) << " and " << EdgeUtils::ToString(two) << " are uncompatible";
		}
	}

	TEST(Edge_Test, MatchOnlyReverse)
	{
		CE::Tile::EdgeType type1 = CE::Tile::EdgeType::Forest;
		CE::Tile::EdgeType type2 = CE::Tile::EdgeType::Settlement;
		CE::Tile::EdgeType type3 = CE::Tile::EdgeType::River;

		ASSERT_TRUE(CE::IsCompatible(type1, type1));
		ASSERT_FALSE(CE::IsCompatible(type1, type2));
		ASSERT_FALSE(CE::IsCompatible(type1, type3));

		ASSERT_FALSE(CE::IsCompatible(type2, type1));
		ASSERT_TRUE(CE::IsCompatible(type2, type2));
		ASSERT_FALSE(CE::IsCompatible(type2, type3));

		ASSERT_FALSE(CE::IsCompatible(type3, type1));
		ASSERT_FALSE(CE::IsCompatible(type3, type2));
		ASSERT_TRUE(CE::IsCompatible(type3, type3));

		EXPECT_TRUE(IsCompatible({type1, type2, type3}, {type3, type2, type1}));
		EXPECT_FALSE(IsCompatible({type1, type2, type3}, {type3, type1, type2}));
		EXPECT_FALSE(IsCompatible({type1, type2, type3}, {type2, type1, type3}));
		EXPECT_FALSE(IsCompatible({type1, type2, type3}, {type2, type3, type1}));
		EXPECT_FALSE(IsCompatible({type1, type2, type3}, {type1, type3, type2}));
		EXPECT_FALSE(IsCompatible({type1, type2, type3}, {type1, type2, type3}));
	}
} // namespace

#pragma once

#include "EdgeType_Utils.hpp"
#include "Tile/EdgeType.hpp"

#include <gtest/gtest.h>
#include <set>
#include <tuple>

namespace
{
	testing::AssertionResult IsCompatible(CE::Tile::EdgeType one, CE::Tile::EdgeType two)
	{
		if (CE::IsCompatible(one, two) && CE::IsCompatible(two, one))
		{
			return testing::AssertionSuccess();
		}
		else if (!CE::IsCompatible(one, two) && CE::IsCompatible(two, one))
		{
			std::string errorMsg = EdgeTypeUtils::ToString(one) + " is not compatible with " + EdgeTypeUtils::ToString(two) + " but " + EdgeTypeUtils::ToString(two) + " is compatible with " + EdgeTypeUtils::ToString(one);
			throw std::runtime_error(errorMsg.c_str());
		}
		else if (CE::IsCompatible(one, two) && !CE::IsCompatible(two, one))
		{
			std::string errorMsg = EdgeTypeUtils::ToString(two) + " is not compatible with " + EdgeTypeUtils::ToString(one) + " but " + EdgeTypeUtils::ToString(one) + " is compatible with " + EdgeTypeUtils::ToString(two);
			throw std::runtime_error(errorMsg.c_str());
		}
		else
		{
			return testing::AssertionFailure() << EdgeTypeUtils::ToString(one) << " and " << EdgeTypeUtils::ToString(two) << " are uncompatible";
		}
	}

	class EdgeType_Test : public testing::TestWithParam<std::tuple<CE::Tile::EdgeType, std::set<CE::Tile::EdgeType>>>
	{
	};

	TEST_P(EdgeType_Test, IsCompatible)
	{
		auto typeToTest			   = std::get<CE::Tile::EdgeType>(GetParam());
		auto typesToBeCompatibleTo = std::get<std::set<CE::Tile::EdgeType>>(GetParam());

		for (auto compatibleType : EdgeTypeUtils::allEdgeTypes)
		{
			try
			{
				if (typesToBeCompatibleTo.contains(compatibleType))
				{
					EXPECT_TRUE(IsCompatible(typeToTest, compatibleType));
				}
				else
				{
					EXPECT_FALSE(IsCompatible(typeToTest, compatibleType));
				}
			}
			catch (std::exception& e)
			{
				EXPECT_TRUE(testing::AssertionFailure() << e.what());
			}
		}
	}

	INSTANTIATE_TEST_SUITE_P(IsCompatible, EdgeType_Test, testing::ValuesIn(EdgeTypeUtils::compatibilityMapping));

	TEST(EdgeType_Test, AllCompatibleToNone)
	{
		for (auto typeToTest : EdgeTypeUtils::allEdgeTypes)
		{
			EXPECT_TRUE(IsCompatible(typeToTest, CE::Tile::EdgeType::None));
		}
	}

	TEST(EdgeType_Test, AllCompatibleToSelf)
	{
		for (auto typeToTest : EdgeTypeUtils::allEdgeTypes)
		{
			EXPECT_TRUE(IsCompatible(typeToTest, typeToTest));
		}
	}

	// TEST(EdgeType_Test, ToString) // Enum to String
	// {
	// 	EXPECT_TRUE(false);
	// }

} // namespace

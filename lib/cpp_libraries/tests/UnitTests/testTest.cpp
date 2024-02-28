#include <gtest/gtest.h>


TEST(TestTest, Pass)
{
    ASSERT_TRUE(true);
}

TEST(TestTest, Fail)
{
    ASSERT_TRUE(false);
}

enum class EnumWithStringify { kMany = 0, kChoices = 1 };

// template <typename Sink>
// void AbslStringify(Sink& sink, EnumWithStringify e)
// {
// //   absl::Format(&sink, "%s", e == EnumWithStringify::kMany ? "Many" : "Choices");
// }

void PrintTo(const EnumWithStringify& point, std::ostream* os)
{
    switch (point)
    {
    case EnumWithStringify::kMany:
        *os << "Many";
        break;
    case EnumWithStringify::kChoices:
        *os << "Choices";
        break;
    default:
    *os << "default";
        break;
    }
}

// https://google.github.io/googletest/advanced.html#value-parameterized-tests

class FooTest : public testing::TestWithParam<EnumWithStringify> {};

TEST_P(FooTest, DoesBlah) {
  // Inside a test, access the test parameter with the GetParam() method
  // of the TestWithParam<T> class:
  std::cout << "Example Test Param: " << (GetParam() == EnumWithStringify::kMany ? "Many" : "Not Many") << std::endl;
}

TEST_P(FooTest, HasBlahBlah) {
    std::cout << "Example Test Param: " << (GetParam() == EnumWithStringify::kChoices ? "Choices" : "Not Choices") << std::endl;
}


INSTANTIATE_TEST_SUITE_P(MeenyMinyMoe,
                         FooTest,
                         testing::Values(EnumWithStringify::kMany, EnumWithStringify::kChoices));


int main(int argc, char** argv)
{
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}

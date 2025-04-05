#include <gtest/gtest.h>
#include "../src/calculator.h"

TEST(CalculatorTest, Add) {
    Calculator calc;
    EXPECT_EQ(calc.Add(3, 4), 7);
}

TEST(CalculatorTest, Subtract) {
    Calculator calc;
    EXPECT_EQ(calc.Subtract(10, 5), 5);
}

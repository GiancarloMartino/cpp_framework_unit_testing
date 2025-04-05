#include <gtest/gtest.h>
#include "../src/calculator.h"

TEST(CalculatorTest, Multiply) {
    Calculator calc;
    EXPECT_EQ(calc.Multiply(3, 4), 12);
}

TEST(CalculatorTest, errorMultiply) {
    Calculator calc;
    EXPECT_NE(calc.Multiply(0, 1), 1);
}

TEST(CalculatorTest, Divide) {
    Calculator calc;
    EXPECT_EQ(calc.Divide(10, 5), 2);
}
rm(list = ls())

library(ggplot2)

source("code/is_leap_year.R")

c(1:50) * 2 
summary(iris)

#test

test_years <- c(1900, 2000, 2004, 2023, 2024, 2100)
is_leap_year(test_years)

#remember first console then the function for false/true

is_leap_year(20)
is_leap_year(20.1)
is_leap_year(1900)
is_leap_year(2000)
is_leap_year(2004)
is_leap_year(2023)
is_leap_year("two thousand") #non-numeric so error -> modify

test_years <- c(1900, 2000, 2004, 2023, 2024, 2100)
is_leap_year(test_years)




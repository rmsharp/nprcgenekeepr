#' Copyright(c) 2017-2022 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("calculateSexRatio")
library(testthat)
library(nprcgenekeepr)
data("qcBreeders")
data("pedWithGenotype")
skip_if_not(exists("qcBreeders"))
skip_if_not(exists("pedWithGenotype"))
available <- c("JGPN6K", "8KM1MP", "I9TQ0T", "Q0RGP7", "VFS0XB", "CQC133",
               "2KULR3", "HOYW0S", "FHV13N", "OUM6QF", "6Z7MD9", "CFPEEU",
               "HLI95R", "RI0O7F", "7M51X5", "DR5GXB", "170ZTZ", "C1ICXL")
nonMales <- c("JGPN6K", "8KM1MP", "I9TQ0T", "Q0RGP7", "CQC133",
              "2KULR3", "HOYW0S", "FHV13N", "OUM6QF", "6Z7MD9", "CFPEEU",
              "HLI95R", "RI0O7F", "7M51X5", "DR5GXB", "170ZTZ", "C1ICXL")
male <- "VFS0XB"
test_that("calculateSexRatio calculates correctly", {
  expect_equal(calculateSexRatio(ids = male, ped = pedWithGenotype), 0)
  expect_equal(calculateSexRatio(ids = nonMales, ped = pedWithGenotype), Inf)
  expect_equal(calculateSexRatio(ids = available, ped = pedWithGenotype), 17)
  expect_equal(calculateSexRatio(ids = available, ped = pedWithGenotype,
                                 additionalMales = 1), 8.5)
  expect_equal(calculateSexRatio(ids = available, ped = pedWithGenotype,
                                 additionalFemales = 1), 18)
  expect_equal(calculateSexRatio(ids = available, ped = pedWithGenotype,
                                 additionalMales = 1, additionalFemales = 1), 9)
  expect_equal(calculateSexRatio(ids = nonMales, ped = pedWithGenotype,
                                 additionalMales = 1, additionalFemales = 0),
               17)
  expect_equal(calculateSexRatio(ids = character(0), ped = pedWithGenotype,
                                 additionalMales = 1, additionalFemales = 0),
               0)
  expect_true(is.na(calculateSexRatio(ids = character(0), ped = pedWithGenotype,
                                      additionalMales = 0,
                                      additionalFemales = 0)))
  expect_equal(calculateSexRatio(ids = character(0), ped = pedWithGenotype,
                                      additionalMales = 0,
                                      additionalFemales = 1), Inf)
  expect_equal(calculateSexRatio(ids = character(0), ped = pedWithGenotype,
                                 additionalMales = 2,
                                 additionalFemales = 1), 0.5)
  expect_equal(calculateSexRatio(ids = character(0), ped = pedWithGenotype,
                                 additionalMales = 0,
                                 additionalFemales = 0), NA)

})

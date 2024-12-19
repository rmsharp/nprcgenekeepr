#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("calcGU")
library(testthat)
data("ped1Alleles")
test_that("calcGU forms dataframe with correct calculations", {
  gu_1 <- calcGU(ped1Alleles, threshold = 1, byID = FALSE, pop = NULL)
  gu_3 <- calcGU(ped1Alleles, threshold = 3, byID = FALSE, pop = NULL)
  expect_equal(length(gu_1$gu[gu_1$gu == 50]), 110)
  expect_equal(length(gu_3$gu[gu_3$gu == 50]), 43)
  gu_1 <- calcGU(ped1Alleles, threshold = 2, byID = TRUE, pop = NULL)
  gu_3 <- calcGU(ped1Alleles, threshold = 3, byID = FALSE,
                 pop = ped1Alleles$id[20:60])
  expect_equal(length(gu_1$gu[gu_1$gu == 50]), 53)
  expect_equal(length(gu_3$gu[gu_3$gu == 50]), 0)
})

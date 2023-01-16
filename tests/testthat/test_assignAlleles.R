#' Copyright(c) 2017-2023 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("assignAlleles")
library(testthat)
alleles <- list(alleles = list(), counter = 1)
test_that("assignAlleles assigns alleles correctly", {
  expect_error(assignAlleles(alleles, parentType = "sire", parent = "s1",
                             id = "o1", n = 4))
  alleles_2 <- assignAlleles(alleles, parentType = "sire", parent = NA,
                             id = "o1", n = 4)
  expect_equal(alleles_2$alleles$o1$sire, rep(1, 4))
  alleles <- alleles_2
  alleles_3 <- assignAlleles(alleles, parentType = "dam", parent = NA,
                             id = "o1", n = 4)
  expect_equal(alleles_3$alleles$o1$dam, rep(2, 4))
  alleles <- alleles_3
  alleles_4 <- assignAlleles(alleles, parentType = "sire", parent = NA,
                             id = "o2", n = 4)
  expect_equal(alleles_4$alleles$o2$sire, rep(3, 4))
  alleles <- alleles_4
  alleles_5 <- assignAlleles(alleles, parentType = "dam", parent = NA,
                             id = "o2", n = 4)
  expect_equal(alleles_5$alleles$o2$dam, rep(4, 4))
  alleles <- alleles_5
  alleles_6 <- assignAlleles(alleles, parentType = "dam", parent = "o1",
                             id = "o3", n = 4)
  expect_true(all(alleles_6$alleles$o3$dam %in% c(1, 2)))
  alleles <- alleles_6
  alleles_7 <- assignAlleles(alleles, parentType = "dam", parent = "o2",
                             id = "o3", n = 4)
  expect_true(all(alleles_6$alleles$o3$sire %in% c(3, 4)))
})

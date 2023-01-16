#' Copyright(c) 2017-2023 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("filterReport")
library(testthat)

rpt <- nprcgenekeepr::pedWithGenotypeReport$report
test_that("filterReport correctly subsets reports based on provide IDs", {
  rpt1 <- filterReport(c("GHH9LB", "BD41WW"), rpt)
  expect_equal(nrow(rpt1), 2)
  rpt1 <- filterReport(c(), rpt)
  expect_equal(nrow(rpt1), 0)
  rpt1 <- filterReport(rpt$id, rpt)
  expect_equal(nrow(rpt1), nrow(rpt))
})

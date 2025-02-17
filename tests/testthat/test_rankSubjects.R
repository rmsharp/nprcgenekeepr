#' Copyright(c) 2017-2024 R. Mark Sharp
# This file is part of nprcgenekeepr
context("rankSubjects")
library(testthat)
## reportGV() unit test is weak.
rpt <- rankSubjects(nprcgenekeepr::finalRpt)
test_that("rankSubjects ranks subject correctly", {
  expect_equal(nrow(rpt[[2]]), 68)
  expect_equal(rpt[[1]][1, "value"], "High Value")
  expect_equal(rpt[[3]][1, "value"], "Low Value")
  expect_equal(rpt[[3]][1, "rank"], 190)
  expect_equal(rpt[["lowMk"]][68, "rank"], 189)
 })

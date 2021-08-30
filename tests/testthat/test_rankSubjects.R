#' Copyright(c) 2017-2020 R. Mark Sharp
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

rptNames <- names(nprcgenekeepr::finalRpt)
newRpt <- list(empty = data.frame(), rpt[[rptNames[1]]], rpt[[rptNames[2]]],
               rpt[[rptNames[3]]])
names(newRpt) <- c("empty", rptNames)
test_that("rankSubjects does not fail with empty list element", {
  expect_equal(nrow(newRpt[[3]]), 68)
  expect_equal(newRpt[[2]][1, "value"], "High Value")
  expect_equal(newRpt[[4]][1, "value"], "Low Value")
  expect_equal(newRpt[[4]][1, "rank"], 190)
  expect_equal(newRpt[["lowMk"]][68, "rank"], 189)
})


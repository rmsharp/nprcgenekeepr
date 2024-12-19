#' Copyright(c) 2017-2024 R. Mark Sharp
# This file is part of nprcgenekeepr
context("orderReport")
library(testthat)
library(stringi)
pedWithGenotypeReport <- nprcgenekeepr::pedWithGenotypeReport
ped <- nprcgenekeepr::qcPed
rpt <- pedWithGenotypeReport$report
countUnk <- function(ids) {
  length(ids[grepl("^U", ids, ignore.case = TRUE)])
}
test_that("orderReport correctly orders the report", {
  rpt1 <- nprcgenekeepr:::orderReport(rpt, ped)
  expect_equal(nrow(rpt1), nrow(rpt))
  expect_true(all(rpt1$id %in% rpt1$id))
  set_seed(100)
  rpt$origin <- ifelse(sample(c(TRUE, FALSE), size = nrow(rpt), replace = TRUE,
                              prob = c(0.8, 0.2)), "TEXAS", NA)
  rpt$totalOffspring <- sample(0:3, size = nrow(rpt), replace = TRUE,
                              prob = c(0.8, 0.05, 0.05, 0.1))
  rpt1 <- nprcgenekeepr:::orderReport(rpt, ped)
  expect_equal(countUnk(rpt1$id[1:100]), 34)
  expect_equal(countUnk(rpt$id[1:50]), 21)
})
rpt <- rpt[, !names(rpt) %in% "age"]
test_that("orderReport correctly orders the report without age column", {
  rpt1 <- nprcgenekeepr:::orderReport(rpt, ped)
  expect_equal(nrow(rpt1), nrow(rpt))
  expect_true(all(rpt1$id %in% rpt1$id))
  set_seed(100)
  rpt$origin <- ifelse(sample(c(TRUE, FALSE), size = nrow(rpt), replace = TRUE,
                              prob = c(0.8, 0.2)), "TEXAS", NA)
  rpt$totalOffspring <- sample(0:3, size = nrow(rpt), replace = TRUE,
                               prob = c(0.8, 0.05, 0.05, 0.1))
  rpt1 <- nprcgenekeepr:::orderReport(rpt, ped)
  expect_equal(countUnk(rpt1$id[1:100]), 34)
  expect_equal(countUnk(rpt$id[1:50]), 21)
})

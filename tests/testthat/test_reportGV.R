#' Copyright(c) 2017-2024 R. Mark Sharp
# This file is part of nprcgenekeepr
context("reportGV")
library(testthat)
qcPed <- nprcgenekeepr::qcPed
gvReport <- reportGV(qcPed, guIter = 100)
test_that("reportGV forms correct genetic value report", {
  expect_equal(names(gvReport), c("report", "kinship", "gu", "fe", "fg",
                                  "maleFounders", "femaleFounders",
                                  "nMaleFounders", "nFemaleFounders", "total"))
  expect_equal(names(gvReport$report),
               c("id", "sex", "age", "birth", "exit", "population",
                 "indivMeanKin", "zScores", "gu", "totalOffspring",
                 "livingOffspring", "value", "rank"))
  expect_equal(nrow(gvReport$report), nrow(qcPed))
  expect_equal(nrow(gvReport$gu), nrow(qcPed))
  expect_equal(gvReport$nMaleFounders, 20)
  expect_equal(gvReport$nFemaleFounders, 61)
})
updateProgress <- function(n = 1, detail = NULL, value = 0, reset = FALSE) {
  "stub"
}

gvReport <- reportGV(qcPed, guIter = 100, updateProgress = updateProgress)
test_that(
  "reportGV forms correct genetic value report with updateProgress defined", {
  expect_equal(names(gvReport), c("report", "kinship", "gu", "fe", "fg",
                                  "maleFounders", "femaleFounders",
                                  "nMaleFounders", "nFemaleFounders", "total"))
  expect_equal(names(gvReport$report),
               c("id", "sex", "age", "birth", "exit", "population",
                 "indivMeanKin", "zScores", "gu", "totalOffspring",
                 "livingOffspring", "value", "rank"))
  expect_equal(nrow(gvReport$report), nrow(qcPed))
  expect_equal(nrow(gvReport$gu), nrow(qcPed))
  expect_equal(gvReport$nMaleFounders, 20)
  expect_equal(gvReport$nFemaleFounders, 61)
})

#' Copyright(c) 2017-2022 R. Mark Sharp
# This file is part of nprcgenekeepr
context("print.summary.nprcgenekeeprGV")
library(testthat)

test_that("print.summary.nprcgenekeeprGV prints expected output", {
  ped <- nprcgenekeepr::pedOne
  ped$birth_date[ped$ego_id == "d2"] <- "2000-04-13"
  ped$birth_date[ped$ego_id == "o4"] <- "2016-04-13"
  ped <- suppressWarnings(qcStudbook(ped, reportErrors = FALSE))
  summaryGV <- summary(reportGV(ped, guIter = 10))
  expect_success(expect_output(print(summaryGV)))
  expect_equal(summaryGV[1], c("The genetic value report"))
  expect_equal(length(summaryGV), 8)
})

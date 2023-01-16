#' Copyright(c) 2017-2023 R. Mark Sharp
# This file is part of nprcgenekeepr
context("summary.nprcgenekeeprGV")
library(testthat)

test_that("summary.nprcgenekeeprGV provides expected output", {
  skip_on_cran()
  set_seed(10)
  ped <- nprcgenekeepr::pedOne
  ped$birth_date[ped$ego_id == "d2"] <- "2000-04-13"
  ped$birth_date[ped$ego_id == "o4"] <- "2016-04-13"
  ped <- suppressWarnings(qcStudbook(ped, reportErrors = FALSE))
  gvReport <- reportGV(ped, guIter = 10)
  summaryGV <- summary(gvReport)
  expect_equal(summaryGV[1], c("The genetic value report"))
  expect_equal(length(summaryGV), 8)
})

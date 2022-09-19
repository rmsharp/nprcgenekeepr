#' Copyright(c) 2017-2022 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("getPyramidPlot")
library(testthat)
recPlot <- function(expr) {
  pdf(NULL)
  on.exit(dev.off())
  dev.control(displaylist = "enable")
  expr
  recordPlot()
}
agePlot <- recPlot(getPyramidPlot(nprcgenekeepr::qcPed))
test_that("getPyramidPlot generates a plot with or without pedigree", {
  expect_true(inherits(agePlot, "recordedplot"))
  expect_true(inherits(recPlot(getPyramidPlot(NULL)), "recordedplot"))
})

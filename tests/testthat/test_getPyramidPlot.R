#' Copyright(c) 2017-2020 R. Mark Sharp
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
  expect_equal(class(agePlot), "recordedplot")
  expect_equal(class(recPlot(getPyramidPlot(NULL))), "recordedplot")
})

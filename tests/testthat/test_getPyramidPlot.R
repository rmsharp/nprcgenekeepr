## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
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
  expect_s3_class(agePlot, "recordedplot")
  expect_s3_class(recPlot(getPyramidPlot(NULL)), "recordedplot")
})

# Issue #111 coverage backfill (S293): the ageUnit == "months" age-conversion
# branch (getPyramidPlot.R L40), never exercised by the default-ageUnit tests.
test_that("getPyramidPlot converts age to months when ageUnit=months", {
  monthsPlot <- recPlot(
    getPyramidPlot(nprcgenekeepr::qcPed, ageUnit = "months")
  )
  expect_s3_class(monthsPlot, "recordedplot")
})

## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)
library(lubridate)

pedOne <- nprcgenekeepr::pedOne
pedOne$age <- (mdy("10-05-2017", tz = "America/Chicago") -
  as.POSIXct(pedOne$birth)) / dyears(1L)

test_that("getPedMaxAge finds max age", {
  expect_equal(getPedMaxAge(pedOne), 17.227146, tolerance = 0.01)
  expect_equal(getPedMaxAge(pedOne[c(-1L, -2L), ]), 11.48742, tolerance = 0.01)
})

test_that("getPedMaxAge returns NA (no warning) with no non-missing ages", {
  # Issue #121: max(ped$age, na.rm = TRUE) returned -Inf and emitted
  # "no non-missing arguments to max; returning -Inf" when the pedigree had no
  # age column or all-NA ages (runtime-reachable via an import lacking birth
  # dates; getPyramidPlot() then risked a -Inf axis bound). It must return
  # NA_real_ silently instead -- getPyramidPlot() already maps NA to binWidth.

  # (a) no age column at all
  noAge <- data.frame(
    id = c("A", "B"), sex = c("M", "F"), stringsAsFactors = FALSE
  )
  expect_warning(resNoAge <- getPedMaxAge(noAge), NA)
  expect_true(is.na(resNoAge))

  # (b) age column present but every value NA
  allNa <- data.frame(
    id = c("A", "B"), sex = c("M", "F"),
    age = c(NA_real_, NA_real_), stringsAsFactors = FALSE
  )
  expect_warning(resAllNa <- getPedMaxAge(allNa), NA)
  expect_true(is.na(resAllNa))
})

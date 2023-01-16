#' Copyright(c) 2017-2023 R. Mark Sharp
#' This file is part of nprcgenekeepr

test_that("getIndianOriginStatus returns the correct values", {
  origin <- c("INDIAN", "INDIAN", "INDIAN", "INDIAN", "INDIAN")
  status <- getIndianOriginStatus(origin)
  expect_equal(status,
               list(ancestry = list(
                 chinese = 0,
                 indian = 5,
                 hybrid = 0,
                 borderline = 0,
                 japanese = 0,
                 unknown = 0,
                 other = 0), color = "green", colorIndex = 3))
  expect_equal(sum(unlist(status$ancestry)), 5)
  origin <- c("INDIAN", "HYBRID", "INDIAN", "INDIAN", "INDIAN")
  status <- getIndianOriginStatus(origin)
  expect_equal(status,
               list(ancestry = list(
                 chinese = 0,
                 indian = 4,
                 hybrid = 1,
                 borderline = 0,
                 japanese = 0,
                 unknown = 0,
                 other = 0), color = "red", colorIndex = 1))
  expect_equal(sum(unlist(status$ancestry)), 5)
  origin <- c("INDIAN", "BORDERLINE_HYBRID", "INDIAN", "INDIAN", "INDIAN")
  status <- getIndianOriginStatus(origin)
  expect_equal(status,
               list(ancestry = list(
                 chinese = 0,
                 indian = 4,
                 hybrid = 0,
                 borderline = 1,
                 japanese = 0,
                 unknown = 0,
                 other = 0), color = "yellow", colorIndex = 2))
  expect_equal(sum(unlist(status$ancestry)), 5)
  origin <- c("INDIAN", "CHINESE", "INDIAN", "INDIAN", "INDIAN")
  status <- getIndianOriginStatus(origin)
  expect_equal(status,
               list(ancestry = list(
                 chinese = 1,
                 indian = 4,
                 hybrid = 0,
                 borderline = 0,
                 japanese = 0,
                 unknown = 0,
                 other = 0), color = "red", colorIndex = 1))
})


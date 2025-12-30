#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of mprcgenekeepr
context("getLkDirectAncestors")

test_that("getLkDirectAncestors throws an error with no mprcgenekeepr
          configuration file", {
  expect_warning(
    getLkDirectAncestors(),
    "The file should be named:"
  )
})

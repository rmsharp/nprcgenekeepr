#' Copyright(c) 2017-2023 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("getLkDirectAncestors")

test_that("getLkDirectAncestors throws an error with no nprcgenekeepr
          configuration file", {
  expect_warning(getLkDirectAncestors(),
                 "The file should be named:")
})

## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

test_that("getLkDirectAncestors throws an error with no nprcgenekeepr
          configuration file", {
  expect_warning(
    getLkDirectAncestors(),
    "The file should be named:"
  )
})

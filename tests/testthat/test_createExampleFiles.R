## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)
files <- suppressMessages(createExampleFiles())
test_that("createExampleFiles creates all files", {
  expect_true(all(file.exists(files)))
})

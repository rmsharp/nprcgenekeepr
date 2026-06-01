#' Copyright(c) 2017-2024 R. Mark Sharp
# This file is part of nprcgenekeepr
library(testthat)

## NEW-45: the shared validator that defines the "an ID may not contain a
## period ('.')" rule in one place. Reused by qcStudbook() (data input) and
## geneDrop() (point of use). Returns a logical vector, TRUE where the value
## contains a disallowed character (currently the period). NA -> FALSE.
test_that("hasInvalidIdChar flags IDs containing a period", {
  expect_true(hasInvalidIdChar("A.1"))
  expect_true(hasInvalidIdChar("x.y.z"))
  expect_false(hasInvalidIdChar("A1"))
  expect_false(hasInvalidIdChar("U0001"))
  expect_identical(
    hasInvalidIdChar(c("A.1", "B2", "C.3", "U0001")),
    c(TRUE, FALSE, TRUE, FALSE)
  )
})

test_that("hasInvalidIdChar treats NA and empty input safely", {
  expect_false(hasInvalidIdChar(NA_character_))
  expect_identical(hasInvalidIdChar(c("A.1", NA)), c(TRUE, FALSE))
  expect_identical(hasInvalidIdChar(character(0L)), logical(0L))
})

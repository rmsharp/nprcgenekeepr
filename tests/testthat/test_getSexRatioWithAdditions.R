## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Direct characterization of the internal helper (it was reached only
## through calculateSexRatio). Written before the sexCodes adoption
## (docs/planning/sexcodes-adoption-plan.md, stage 1) so that the refactor
## is proven behavior-preserving: these tests pass on the old and new code.
library(testthat)

ped <- data.frame(
  id = c("a", "b", "c", "d", "e", "f"),
  sex = c("M", "F", "F", "U", "M", "H"),
  stringsAsFactors = FALSE
)

test_that("getSexRatioWithAdditions returns females per male", {
  expect_equal(
    nprcgenekeepr:::getSexRatioWithAdditions(c("a", "b", "c", "e"), ped, 0, 0),
    1
  )
  expect_equal(
    nprcgenekeepr:::getSexRatioWithAdditions(c("a", "b", "c"), ped, 0, 0), 2
  )
})

test_that("getSexRatioWithAdditions counts every non-male as female", {
  expect_equal(
    nprcgenekeepr:::getSexRatioWithAdditions(c("a", "d", "f"), ped, 0, 0), 2
  )
})

test_that("getSexRatioWithAdditions adds the extra animals", {
  expect_equal(
    nprcgenekeepr:::getSexRatioWithAdditions(c("a", "b"), ped, 1, 3), 2
  )
})

test_that("getSexRatioWithAdditions ignores animals outside ids", {
  expect_equal(
    nprcgenekeepr:::getSexRatioWithAdditions("a", ped, 0, 0), 0
  )
})

test_that("getSexRatioWithAdditions is Inf with no males and no additions", {
  expect_identical(
    nprcgenekeepr:::getSexRatioWithAdditions(c("b", "c"), ped, 0, 0), Inf
  )
})

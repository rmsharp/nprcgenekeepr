## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
set_seed(1)
vec <- abs(rnorm(10L))

test_that("getProportionLow returns the correct values", {
  lowVec <- ifelse(vec > 0.3, "High", "Low")
  expect_identical(
    getProportionLow(lowVec),
    list(proportion = 0.1, color = "green", colorIndex = 3L)
  )
  lowVec <- ifelse(vec > 0.4, "High", "Low")
  expect_identical(
    getProportionLow(lowVec),
    list(proportion = 0.3, color = "yellow", colorIndex = 2L)
  )
  lowVec <- ifelse(vec > 0.7, "High", "Low")
  expect_identical(
    getProportionLow(lowVec),
    list(proportion = 0.6, color = "red", colorIndex = 1L)
  )
})

test_that("getProportionLow stops on empty input (NEW-25)", {
  ## Empty input previously crashed with the cryptic
  ## "missing value where TRUE/FALSE needed": 0 / 0 -> NaN -> if (NA).
  ## It must now fail loud with an intelligible message.
  expect_error(
    getProportionLow(character(0)),
    "requires at least one"
  )
  expect_error(
    getProportionLow(NULL),
    "requires at least one"
  )
  ## True-positive guard: a single non-empty value must still compute,
  ## proving the empty guard fires only on length-0 input.
  expect_identical(
    getProportionLow("Low"),
    list(proportion = 1, color = "red", colorIndex = 1L)
  )
})

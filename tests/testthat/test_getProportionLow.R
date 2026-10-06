## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
set_seed(1)
vec <- abs(rnorm(10L))

test_that("getProportionLow returns the correct values", {
  lowVec <- ifelse(vec > 0.3, "High Value", "Low Value")
  expect_identical(
    getProportionLow(lowVec),
    list(proportion = 0.1, color = "green", colorIndex = 3L)
  )
  lowVec <- ifelse(vec > 0.4, "High Value", "Low Value")
  expect_identical(
    getProportionLow(lowVec),
    list(proportion = 0.3, color = "yellow", colorIndex = 2L)
  )
  lowVec <- ifelse(vec > 0.7, "High Value", "Low Value")
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
    getProportionLow("Low Value"),
    list(proportion = 1, color = "red", colorIndex = 1L)
  )
})

## S920: the genetic-value labels come from one internal list (valueLabels), and
## getProportionLow() counts an animal as Low only when its value is exactly the
## Low Value label. Until then it counted any text containing "Low", so a value
## like "Very Low" counted, and so did a missing value (a missing value made
## geneticValues[NA] an NA element, which length() counted).
test_that("getProportionLow counts only the exact Low Value label (S920)", {
  ## "Very Low" and "Lowest priority" only contain the text Low
  veryLow <- getProportionLow(c("Low Value", "High Value", "Very Low"))
  expect_equal(veryLow$proportion, 1 / 3)
  expect_identical(veryLow$colorIndex, 2L)
  lowest <- getProportionLow(c("High Value", "Lowest priority"))
  expect_identical(lowest$proportion, 0)
  expect_identical(lowest$colorIndex, 3L)
})

test_that("getProportionLow does not count a missing value as Low Value (S920)", {
  ## 1 Low of 3 values, the missing one included in the 3
  withMissing <- getProportionLow(c("Low Value", "High Value", NA))
  expect_equal(withMissing$proportion, 1 / 3)
  expect_identical(withMissing$colorIndex, 2L)
})

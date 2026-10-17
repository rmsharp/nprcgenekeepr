## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)
original <- c(
  "y", "yes", "Y", "Yes", "YES", "n", "N", "No", "NO", "no",
  "t", "T", "True", "true", "TRUE", "f", "F", "false", "False",
  "FALSE"
)
status <- convertFromCenter(original)
test_that("convertFromCenter makes correct transformations", {
  expect_type(status, "logical")
  expect_true(status[1L])
  expect_true(status[2L])
  expect_true(status[3L])
  expect_true(status[4L])
  expect_true(status[5L])
  expect_false(status[6L])
  expect_false(status[7L])
  expect_false(status[8L])
  expect_false(status[9L])
  expect_false(status[10L])
  expect_true(status[11L])
  expect_true(status[12L])
  expect_true(status[13L])
  expect_true(status[14L])
  expect_true(status[15L])
  expect_false(status[16L])
  expect_false(status[17L])
  expect_false(status[18L])
  expect_false(status[19L])
  expect_false(status[20L])
})
test_that("convertFromCenter() detects input error", {
  original <- c("y", "&")
  expect_error(convertFromCenter(original), "fromCenter field has ambiguous")
})

# --- whole values only (BACKLOG.md:166, ruled S1004) -------------------------
# Each of these text values is read as TRUE or FALSE with no message when the
# match is not anchored to the whole value ("unknown" holds an n, "maybe" a y).

test_that("convertFromCenter() stops on text that only holds a y, t, n or f", {
  notYesOrNo <- c(
    "unknown", "N/A", "NA", "none", "nope", "No.", "maybe", "tru", "yess"
  )
  for (value in notYesOrNo) {
    expect_error(
      convertFromCenter(value),
      "fromCenter field has ambiguous values in row\\(s\\) 1$",
      info = value
    )
  }
})

test_that("convertFromCenter() names every offending row and only those", {
  expect_error(
    convertFromCenter(c("yes", "unknown", "no", "maybe", "N")),
    "row\\(s\\) 2 and 4$"
  )
  expect_error(
    convertFromCenter(c("yes", "unknown", "no", "maybe", "none")),
    "row\\(s\\) 2, 4, and 5$"
  )
  # a missing value is not an offending value
  expect_error(
    convertFromCenter(c(NA, "unknown", "y")),
    "row\\(s\\) 2$"
  )
})

test_that("convertFromCenter() judges a factor by its labels", {
  expect_error(
    convertFromCenter(factor(c("yes", "unknown", "no"))),
    "row\\(s\\) 2$"
  )
})

# --- guards: what must keep working ------------------------------------------

test_that("convertFromCenter() reads padded and mixed-case whole values", {
  yes <- c(" yes", "Yes ", "  Y  ", "tRuE", "T ", "yEs")
  no <- c("no ", " N", "fAlSe", "F  ", "nO", " false ")
  expect_identical(convertFromCenter(yes), rep(TRUE, length(yes)))
  expect_identical(convertFromCenter(no), rep(FALSE, length(no)))
  # a tab or a line end counts as surrounding space too
  expect_identical(convertFromCenter(c("\tyes", "no\n")), c(TRUE, FALSE))
  expect_identical(
    convertFromCenter(factor(c("Yes", "no", "T"))),
    c(TRUE, FALSE, TRUE)
  )
})

test_that("convertFromCenter() keeps NA as NA and passes a logical through", {
  expect_identical(convertFromCenter(c("y", NA, "n")), c(TRUE, NA, FALSE))
  expect_identical(
    convertFromCenter(c(NA_character_, NA_character_)),
    c(NA, NA)
  )
  expect_identical(convertFromCenter(c(TRUE, NA, FALSE)), c(TRUE, NA, FALSE))
  expect_identical(convertFromCenter(logical(0L)), logical(0L))
  expect_identical(convertFromCenter(character(0L)), logical(0L))
})

test_that("convertFromCenter() still stops on blanks, numbers, mixed answers", {
  notAnswers <- list("", " ", "1", "0", "y/n", "yes (transferred)", 1L, 0)
  for (value in notAnswers) {
    expect_error(
      convertFromCenter(value),
      "ambiguous values in row\\(s\\) 1$",
      info = format(value)
    )
  }
})

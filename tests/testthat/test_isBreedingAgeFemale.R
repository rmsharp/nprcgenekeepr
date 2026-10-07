## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

library(testthat)
library(nprcgenekeepr)

## isBreedingAgeFemale() is the one place the Genetic Diversity cells say who
## counts as a breeding-age female (S935): a female whose known age is at least
## minAge, or a female with no birth date whom the pedigree lists as a dam. The
## Production count of dams and the Inbreeding count of females both call it.
## Its answer is TRUE, FALSE or NA, and NA means "not counted" (callers drop it
## with na.rm = TRUE or which()), so these tests compare what is TRUE.

counts <- function(...) isBreedingAgeFemale(...) %in% TRUE

test_that("a female of known age counts when she is at least minAge", {
  expect_identical(
    counts(c("a", "b", "c"), c("F", "F", "F"), c(2.9, 3, 10), 3,
           character(0L)),
    c(FALSE, TRUE, TRUE)
  )
})

test_that("a female with no age counts only when damIds lists her", {
  expect_identical(
    counts(c("a", "b"), c("F", "F"), c(NA, NA), 3, "a"),
    c(TRUE, FALSE)
  )
})

test_that("a known age is judged by the age even when damIds lists her", {
  expect_identical(counts("a", "F", 1, 3, "a"), FALSE)
})

test_that("a male never counts, whatever his age or damIds", {
  ids <- c("a", "b", "c")
  expect_identical(
    counts(ids, c("M", "M", "M"), c(10, NA, 1), 3, ids),
    c(FALSE, FALSE, FALSE)
  )
})

test_that("a blank sex is never counted, even with a known age or a listed id", {
  ids <- c("a", "b", "c")
  res <- isBreedingAgeFemale(ids, c(NA, NA, NA), c(10, NA, NA), 3, "b")
  expect_identical(res, c(NA, NA, NA))
  expect_identical(counts(ids, c(NA, NA, NA), c(10, NA, NA), 3, "b"),
                   c(FALSE, FALSE, FALSE))
})

## The offspring rule lives in isCountedMotherWithoutBirthDate(). This test
## stubs it with a mask that DIFFERS from the real rule (the real rule counts
## nobody here, because no id is in damIds) and checks the helper follows the
## stub for the animals with no age. A control with the real rule comes first.

test_that("isBreedingAgeFemale asks isCountedMotherWithoutBirthDate about animals with no age", {
  ids <- c("a", "b", "c")
  sex <- c("F", "F", "F")
  age <- c(5, NA, NA)
  ## Control: the real rule counts neither b nor c (no damIds), and a is 5.
  expect_identical(counts(ids, sex, age, 3, "elsewhere"),
                   c(TRUE, FALSE, FALSE))
  helper <- mockery::mock(c(FALSE, TRUE, FALSE))
  mockery::stub(isBreedingAgeFemale, "isCountedMotherWithoutBirthDate", helper)
  ## Called directly: mockery::stub() reaches only calls made in this test.
  expect_identical(isBreedingAgeFemale(ids, sex, age, 3, "elsewhere") %in% TRUE,
                   c(TRUE, TRUE, FALSE))
  mockery::expect_called(helper, 1L)
  args <- mockery::mock_args(helper)[[1L]]
  expect_identical(args[[1L]], ids)
  expect_identical(args[[2L]], sex)
  expect_identical(args[[3L]], is.na(age))
  expect_identical(args[[4L]], "elsewhere")
})

## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

## isAddedRecord() is the one place that says which records are "added": only
## the exact status "added" is special. An NA, blank or unrecognized status is a
## real animal. The four functions that used to write this rule inline
## (convertDate, removeDuplicates, removeUnknownAnimals and correctParentSex)
## must now ask it, so the rule cannot drift between them (BACKLOG, S908).

## ---------------------------------------------------------------------------
## The rule
## ---------------------------------------------------------------------------
test_that("isAddedRecord is TRUE only for the exact status added", {
  expect_identical(
    isAddedRecord(c("added", "original", "added")),
    c(TRUE, FALSE, TRUE)
  )
})

test_that("isAddedRecord is FALSE, never NA, for a missing status", {
  expect_identical(
    isAddedRecord(c("added", NA, "original")),
    c(TRUE, FALSE, FALSE)
  )
  expect_identical(isAddedRecord(rep(NA_character_, 3L)), rep(FALSE, 3L))
  ## An all-NA logical column (what read.csv gives for an empty column).
  expect_identical(isAddedRecord(c(NA, NA)), c(FALSE, FALSE))
})

test_that("isAddedRecord treats a blank or unrecognized status as real", {
  odd <- c("", "ADDED", "Added", " added", "added ", "weird", "original")
  expect_identical(isAddedRecord(odd), rep(FALSE, length(odd)))
})

test_that("isAddedRecord accepts a factor status", {
  expect_identical(
    isAddedRecord(factor(c("added", "original", NA, "added"))),
    c(TRUE, FALSE, FALSE, TRUE)
  )
})

test_that("isAddedRecord returns one value per status, scalar included", {
  expect_identical(isAddedRecord("added"), TRUE)
  expect_identical(isAddedRecord("original"), FALSE)
  expect_identical(isAddedRecord(character(0L)), logical(0L))
})

test_that("isAddedRecord answers an absent (NULL) status with no added rows", {
  expect_identical(isAddedRecord(NULL, n = 4L), rep(FALSE, 4L))
  expect_identical(isAddedRecord(NULL), logical(0L))
  ## n only matters when there is no status to measure.
  expect_identical(
    isAddedRecord(c("added", "original"), n = 9L),
    c(TRUE, FALSE)
  )
})

test_that("isAddedRecord returns a plain logical mask with no NA", {
  statuses <- list(
    c("added", NA, "original"), rep(NA_character_, 3L), c(NA, NA),
    factor(c("added", NA)), character(0L), "added", NULL
  )
  for (status in statuses) {
    mask <- isAddedRecord(status, n = 2L)
    expect_type(mask, "logical")
    expect_false(anyNA(mask))
    expect_null(names(mask))
  }
})

## A mask, never an index: `x[-which(mask)]` drops EVERY row when nothing is
## added, while `x[!mask]` keeps them all.
test_that(paste0(
  "isAddedRecord is a mask, so negating it keeps every row when none are added"
), {
  noneAdded <- data.frame(
    id = c("a", "b", "c"), recordStatus = c("original", NA, ""),
    stringsAsFactors = FALSE
  )
  expect_identical(
    noneAdded[!isAddedRecord(noneAdded$recordStatus), ],
    noneAdded
  )
})

## Pin the helper to the expression the four callers wrote inline, so moving
## them onto it cannot change a result.
test_that("isAddedRecord equals the inline expression it replaces", {
  statuses <- list(
    allOriginal = rep("original", 6L),
    mixed = c("original", "added", NA, "", "ADDED", " added"),
    allAdded = rep("added", 6L),
    allNA = rep(NA_character_, 6L),
    logicalNA = rep(NA, 6L),
    factorMixed = factor(c("original", "added", NA, "", "weird", "added")),
    scalar = "original",
    empty = character(0L)
  )
  for (nm in names(statuses)) {
    x <- statuses[[nm]]
    expect_identical(isAddedRecord(x), !is.na(x) & x == "added", info = nm)
  }
})

## ---------------------------------------------------------------------------
## Each caller uses the helper's answer, not its own copy of the rule
## ---------------------------------------------------------------------------
## Each test stubs the helper with a mask that DIFFERS from the real rule
## (every status here is "original", so the real rule sets nothing aside) and
## checks the caller follows the stub. A control with the real rule comes first.

test_that("convertDate asks isAddedRecord which rows to set aside", {
  ped <- data.frame(
    id = c("a", "b", "c"),
    birth = c("2001-01-05", "notadate", "2003-03-07"),
    recordStatus = rep("original", 3L),
    stringsAsFactors = FALSE
  )
  ## Control: the real rule keeps row 2, so its bad date is reported.
  expect_identical(convertDate(ped, reportErrors = TRUE), "2")
  helper <- mockery::mock(c(FALSE, TRUE, FALSE))
  mockery::stub(convertDate, "isAddedRecord", helper)
  expect_null(convertDate(ped, reportErrors = TRUE))
  mockery::expect_called(helper, 1L)
  expect_identical(mockery::mock_args(helper)[[1L]][[1L]], ped$recordStatus)
})

test_that("removeDuplicates asks isAddedRecord which rows to leave out", {
  ped <- data.frame(
    id = c("a", "a", "b"), recordStatus = rep("original", 3L),
    stringsAsFactors = FALSE
  )
  ## Control: the real rule searches every row, so the second "a" is found.
  expect_identical(removeDuplicates(ped, reportErrors = TRUE), "a")
  helper <- mockery::mock(c(FALSE, TRUE, FALSE))
  mockery::stub(removeDuplicates, "isAddedRecord", helper)
  expect_null(removeDuplicates(ped, reportErrors = TRUE))
  mockery::expect_called(helper, 1L)
  expect_identical(mockery::mock_args(helper)[[1L]][[1L]], ped$recordStatus)
})

test_that("removeUnknownAnimals asks isAddedRecord which rows to remove", {
  ped <- data.frame(
    id = c("a", "b", "c"), recordStatus = rep("original", 3L),
    stringsAsFactors = FALSE
  )
  ## Control: the real rule removes nothing.
  expect_identical(removeUnknownAnimals(ped), ped)
  helper <- mockery::mock(c(FALSE, TRUE, FALSE))
  mockery::stub(removeUnknownAnimals, "isAddedRecord", helper)
  result <- removeUnknownAnimals(ped)
  mockery::expect_called(helper, 1L)
  expect_identical(result$id, c("a", "c"))
  expect_identical(mockery::mock_args(helper)[[1L]][[1L]], ped$recordStatus)
})

test_that("correctParentSex asks isAddedRecord which parents to leave out", {
  id <- c("a", "b", "c")
  sire <- c(NA, NA, "b")
  dam <- c(NA, NA, NA)
  sex <- c("M", "F", "M")
  status <- rep("original", 3L)
  ## Control: "b" sires "c" but is female, and the real rule reports her.
  control <- correctParentSex(id, sire, dam, sex, status, reportErrors = TRUE)
  expect_identical(control$femaleSires, "b")
  helper <- mockery::mock(c(FALSE, TRUE, FALSE))
  mockery::stub(correctParentSex, "isAddedRecord", helper)
  result <- correctParentSex(id, sire, dam, sex, status, reportErrors = TRUE)
  mockery::expect_called(helper, 1L)
  expect_null(result$femaleSires)
  expect_identical(mockery::mock_args(helper)[[1L]][[1L]], status)
})

test_that(paste0(
  "correctParentSex gives isAddedRecord the row count for a NULL status"
), {
  id <- c("a", "b", "c")
  helper <- mockery::mock(rep(FALSE, 3L))
  mockery::stub(correctParentSex, "isAddedRecord", helper)
  result <- correctParentSex(
    id, c(NA, NA, "b"), c(NA, NA, NA), c("M", "F", "M"), NULL,
    reportErrors = TRUE
  )
  mockery::expect_called(helper, 1L)
  expect_null(mockery::mock_args(helper)[[1L]][[1L]])
  expect_identical(mockery::mock_args(helper)[[1L]][[2L]], 3L)
  ## With no status, nothing is set aside, so the female sire is reported.
  expect_identical(result$femaleSires, "b")
})

## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

## fixColumnNames() standardizes pedigree header names. The underscore-strip
## pass collapses the genotype-bearing headers first_name / second_name to
## firstname / secondname; the "clean up possible overreach" block restores
## them so they survive to newColNames. These tests pin that contract: every
## spelling of the two genotype headers (space, underscore, period, and the
## already-collapsed form) normalizes to canonical first_name / second_name in
## the returned newColNames, and the fix does not disturb non-genotype headers.
## See issue #117 (the restoration formerly wrote to a local that line 39
## discarded before the function returned newCols).

fixNames <- function(cols) {
  fixColumnNames(cols, errorLst = getEmptyErrorLst())$newColNames
}

test_that("space-form genotype headers restore to first_name/second_name", {
  out <- fixColumnNames(
    c("First Name", "Second Name", "id"),
    errorLst = getEmptyErrorLst()
  )
  expect_identical(out$newColNames, c("first_name", "second_name", "id"))
})

test_that("underscore-form genotype headers survive unchanged", {
  out <- fixColumnNames(
    c("first_name", "second_name", "id"),
    errorLst = getEmptyErrorLst()
  )
  expect_identical(out$newColNames, c("first_name", "second_name", "id"))
  ## The underscore strip is net-cancelled by the restore, so the previously
  ## spurious underScoreRemoved record is empty for this input.
  expect_identical(
    out$errorLst$changedCols$underScoreRemoved, character(0)
  )
})

test_that("period-form genotype headers restore to first_name/second_name", {
  expect_identical(
    fixNames(c("First.Name", "Second.Name")),
    c("first_name", "second_name")
  )
})

test_that("already-collapsed genotype headers normalize to canonical form", {
  expect_identical(
    fixNames(c("firstname", "secondname")),
    c("first_name", "second_name")
  )
})

test_that("only first_name present restores independently", {
  expect_identical(fixNames(c("first_name", "id")), c("first_name", "id"))
})

test_that("only second_name present restores independently", {
  expect_identical(fixNames(c("second_name", "sex")), c("second_name", "sex"))
})

test_that("genotype restore coexists with canonical renames", {
  expect_identical(
    fixNames(c("EGO", "first_name", "second_name", "Sire_ID")),
    c("id", "first_name", "second_name", "sire")
  )
})

test_that("non-genotype headers are untouched by the fix (invariant guard)", {
  ## Passes before and after issue #117: proves the fix does not disturb the
  ## normal canonical mapping or the underScoreRemoved diagnostic.
  out <- fixColumnNames(
    c("ego_id", "sire.id", "dam_id", "sex", "birth_date"),
    errorLst = getEmptyErrorLst()
  )
  expect_identical(
    out$newColNames, c("id", "sire", "dam", "sex", "birth")
  )
  expect_identical(
    out$errorLst$changedCols$underScoreRemoved,
    "ego_id, dam_id, and birth_date to egoid, damid, and birthdate"
  )
})

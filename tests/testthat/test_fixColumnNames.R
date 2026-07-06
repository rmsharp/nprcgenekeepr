## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

## Issue #111 coverage backfill: fixColumnNames() standardizes pedigree header
## names. Lines 31-36 (the "clean up possible overreach" block that restores
## first_name / second_name when a header collapses to firstname / secondname)
## were uncovered because existing tests feed underscore forms ("first_name")
## that never collapse to "firstname". Feeding the space form ("First Name")
## drives lines 32/35.
##
## KNOWN DEFECT (documented, not fixed here): the restoration at lines 31-36
## writes to `cols`, but line 39 (`cols <- newCols`) immediately overwrites it
## and the function returns `newCols`, so the first_name/second_name restoration
## never reaches newColNames. These tests therefore characterize the ACTUAL
## (currently incorrect) behavior -- newColNames comes back "firstname" /
## "secondname" for BOTH the space and underscore input forms. Tracked as
## issue #117; when that is fixed these assertions must be updated.

test_that("fixColumnNames executes the firstname/secondname overreach cleanup", {
  out <- fixColumnNames(
    c("First Name", "Second Name", "id"),
    errorLst = getEmptyErrorLst()
  )
  ## Documents the current (defective) output: cleanup does not reach the result.
  expect_identical(out$newColNames, c("firstname", "secondname", "id"))
  ## The cleanup DID run (line 32/35): it recorded a change in the errorLst,
  ## proving the branch executed even though the restored value was discarded.
  expect_true(nzchar(out$errorLst$changedCols$underScoreRemoved))
})

test_that("fixColumnNames underscore input yields the same collapsed output", {
  out <- fixColumnNames(
    c("first_name", "second_name", "id"),
    errorLst = getEmptyErrorLst()
  )
  expect_identical(out$newColNames, c("firstname", "secondname", "id"))
})

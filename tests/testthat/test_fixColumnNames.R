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

## S1020 (BACKLOG.md:168): every header is lower-cased, then recordStatus,
## fromCenter and geographicOrigin get their camel case back. A header that
## came in spelled that way ends up as it began, so no record may name it.
camelHeaders <- c("recordStatus", "fromCenter", "geographicOrigin")
camelRenameFields <- c(
  "recordstatusToRecordStatus", "fromcenterToFromCenter",
  "geographicoriginToGeographicOrigin"
)

changedColsFor <- function(cols) {
  fixColumnNames(cols, errorLst = getEmptyErrorLst())$errorLst$changedCols
}

test_that("a header already spelled recordStatus, fromCenter or geographicOrigin is no change", {
  for (hdr in camelHeaders) {
    out <- fixColumnNames(c("id", hdr), errorLst = getEmptyErrorLst())
    expect_identical(out$newColNames, c("id", hdr), info = hdr)
    expect_false(any(lengths(out$errorLst$changedCols) > 0L), info = hdr)
  }
  all3 <- fixColumnNames(c("id", camelHeaders), errorLst = getEmptyErrorLst())
  expect_identical(all3$newColNames, c("id", camelHeaders))
  expect_false(any(lengths(all3$errorLst$changedCols) > 0L))
})

test_that("a header spelled right is left out of the records of the headers that did change", {
  cc <- changedColsFor(c("ID", "recordStatus", "fromCenter", "geographicOrigin"))
  expect_identical(cc$caseChange, "ID to id")
  for (field in camelRenameFields) {
    expect_identical(cc[[field]], character(0L), info = field)
  }
})

test_that("an all-lowercase camel case header records its own rename and nothing else", {
  for (k in seq_along(camelHeaders)) {
    lower <- tolower(camelHeaders[k])
    cc <- changedColsFor(c("id", lower))
    expect_identical(cc[[camelRenameFields[k]]],
                     paste(lower, "to", camelHeaders[k]), info = lower)
    expect_identical(names(Filter(length, cc)), camelRenameFields[k],
                     info = lower)
  }
})

test_that("a camel case header whose spelling really changes still records each step", {
  capital <- changedColsFor(c("id", "RecordStatus"))
  expect_identical(capital$caseChange, "RecordStatus to recordstatus")
  expect_identical(capital$recordstatusToRecordStatus,
                   "recordstatus to recordStatus")
  underscore <- changedColsFor(c("id", "record_status"))
  expect_identical(underscore$underScoreRemoved,
                   "record_status to recordstatus")
  expect_identical(underscore$recordstatusToRecordStatus,
                   "recordstatus to recordStatus")
  expect_identical(
    fixNames(c("id", "RecordStatus", "record_status", "FromCenter")),
    c("id", "recordStatus", "recordStatus", "fromCenter")
  )
})

## S1021 (BACKLOG.md:168, a nameless header): a header that is NA, not a text,
## made fixColumnNames() stop "missing value where TRUE/FALSE needed" in its
## two `if (any(tolower(newCols) == ...))` checks, so qcStudbook() never
## reached its own missing-column check. A blank header ("") already works, so
## an NA header is read as a blank one before any step sees it. No reader the
## package has gives NA (getPedigree() gives "", the app "X", an Excel blank
## cell "...3"); only a script that sets names(ped)[k] <- NA does.

## One failing case must not end its block before the next, so a stop becomes
## the value (`STOP: <message>`) that the expectation then compares.
fixNamesOrStop <- function(cols) {
  tryCatch(fixNames(cols),
           error = function(e) paste("STOP:", conditionMessage(e)))
}
fixAllOrStop <- function(cols) {
  tryCatch(fixColumnNames(cols, errorLst = getEmptyErrorLst()),
           error = function(e) paste("STOP:", conditionMessage(e)))
}

test_that("an NA header is read as a blank one, wherever it stands", {
  expect_identical(fixNamesOrStop(c(NA, "id")), c("", "id"))
  expect_identical(fixNamesOrStop(c("id", NA, "Sire")), c("id", "", "sire"))
  expect_identical(fixNamesOrStop(c("id", "sire", NA)), c("id", "sire", ""))
  expect_identical(fixNamesOrStop(NA_character_), "")
  ## the whole answer is the blank header's, not only the names
  expect_identical(fixAllOrStop(c("id", NA, "Sire")),
                   fixAllOrStop(c("id", "", "Sire")))
})

test_that("a vector of only NA headers gives only blank names", {
  expect_identical(fixNamesOrStop(c(NA, NA, NA)), c("", "", ""))
})

test_that("an NA header leaves no record in changedCols", {
  recorded <- function(cols) {
    tryCatch(any(lengths(changedColsFor(cols)) > 0L), error = function(e) NA)
  }
  expect_false(recorded(c("id", NA, "sire")))
  ## beside a header that does change, only that change is recorded
  expect_identical(
    tryCatch(changedColsFor(c("ID", NA)), error = function(e) "STOP"),
    changedColsFor(c("ID", ""))
  )
})

test_that("the text NA is an ordinary header, not a missing one", {
  ## Passes before and after S1021: only a real NA is read as a blank one.
  out <- fixColumnNames(c("id", "NA"), errorLst = getEmptyErrorLst())
  expect_identical(out$newColNames, c("id", "na"))
  expect_identical(out$errorLst$changedCols$caseChange, "NA to na")
})

## helpPlaces() and skipUnlessHelpInSourceTree() are in helper-pageText.R.
fixColumnNamesPlaces <- helpPlaces("fixColumnNames", "fixColumnNames.R")

test_that("the help of fixColumnNames() says an NA header is read as a blank one", {
  skipUnlessHelpInSourceTree(fixColumnNamesPlaces)
  for (place in names(fixColumnNamesPlaces)) {
    expect_equal(
      occurrences(fixColumnNamesPlaces[[place]](), "is read as a blank one"),
      1L, info = place
    )
  }
})

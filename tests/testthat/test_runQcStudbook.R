## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

## Issue #111 coverage backfill: runQcStudbook() wraps qcStudbook() in two
## tryCatch passes. qcStudbook signals detected data problems by RETURNING them
## inside errorLst, not by raising R conditions, so with every real fixture the
## warning/error handlers never fire and the synthetic "Data Processing Error"
## branch is skipped -- lines 92-97, 100-105, 125-134 (first pass) and 178-183,
## 186-191 (second pass) were uncovered. Force those conditions by mocking
## qcStudbook via testthat::local_mocked_bindings (the pattern already used
## across the modInput tests).

pedGood <- nprcgenekeepr::pedGood

test_that("runQcStudbook reports a first-pass error as a Data Processing Error", {
  local_mocked_bindings(qcStudbook = function(...) stop("boom"))
  res <- runQcStudbook(pedGood)
  expect_true(res$qcResult$hasErrors)
  expect_null(res$cleaned)
  expect_true(any(res$qcResult$errors$Error == "Data Processing Error"))
  expect_true(any(grepl("boom", res$qcResult$errors$Details, fixed = TRUE)))
})

test_that("runQcStudbook survives a first-pass warning and a second-pass warning", {
  local_mocked_bindings(qcStudbook = function(...) {
    warning("just a warning")
    getEmptyErrorLst()
  })
  res <- runQcStudbook(pedGood)
  ## First-pass warning handler returns an empty errorLst (no errors); the
  ## second pass also warns, so the cleaned pedigree comes back NULL.
  expect_false(res$qcResult$hasErrors)
  expect_null(res$cleaned)
})

test_that("runQcStudbook handles a clean first pass then a second-pass error", {
  local_mocked_bindings(
    qcStudbook = function(ped, ..., reportErrors) {
      if (reportErrors) getEmptyErrorLst() else stop("second pass failed")
    }
  )
  res <- runQcStudbook(pedGood)
  expect_false(res$qcResult$hasErrors)
  expect_null(res$cleaned)
})

## Issue #119 Slice 1: runQcStudbook threads the new sex-specific
## breeding-age params through to qcStudbook; minParentAge stays a deprecated
## alias whose warning is emitted at runQcStudbook's own boundary (not
## swallowed by its internal warning-catching tryCatch passes).
test_that("runQcStudbook accepts minSireAge/minDamAge (issue #119)", {
  resNew <- runQcStudbook(pedGood, minSireAge = 2.0, minDamAge = 2.0)
  resOld <- suppressWarnings(runQcStudbook(pedGood, minParentAge = 2.0))
  expect_identical(resNew$cleaned, resOld$cleaned)
  expect_false(resNew$qcResult$hasErrors)
})

test_that("runQcStudbook minParentAge alias emits a deprecation warning", {
  lifecycle::expect_deprecated(
    runQcStudbook(pedGood, minParentAge = 2.0)
  )
})

## S933: the Input tab's "Animals with no birth date" warning (BACKLOG.md,
## owner ruled S932 and S933). runQcStudbook() adds the row to
## qcResult$warnings after its second pass, only when reportChanges is TRUE
## (the argument already means "put notices in the result", and the Input tab
## asks for TRUE), and never when errors exist or the second pass fails,
## because then there is no cleaned pedigree to count. The row never makes
## hasErrors TRUE.
noBirthWarning <- "Animals with no birth date"

## pedGood's birth column is named birth_date; blank the first animal's.
pedFirstBirthBlank <- function(ped) {
  ped$birth_date[1L] <- NA
  ped
}

test_that("runQcStudbook adds the no-birth-date warning when reportChanges is TRUE", {
  res <- runQcStudbook(pedFirstBirthBlank(pedGood), reportChanges = TRUE)
  expect_false(res$qcResult$hasErrors)
  expect_identical(nrow(res$qcResult$errors), 0L)
  expect_false(is.null(res$cleaned))
  expect_identical(res$qcResult$warnings$Warning, noBirthWarning)
  expect_match(
    res$qcResult$warnings$Details,
    "^1 of 8 animals has no birth date, so their age is unknown\\."
  )
})

test_that("runQcStudbook leaves the no-birth-date warning out unless reportChanges is TRUE", {
  ped <- pedFirstBirthBlank(pedGood)
  resDefault <- runQcStudbook(ped)
  ## The animal does lack a birth date; only the argument keeps the row out.
  expect_identical(sum(is.na(resDefault$cleaned$birth)), 1L)
  expect_identical(nrow(resDefault$qcResult$warnings), 0L)
  resFalse <- runQcStudbook(ped, reportChanges = FALSE)
  expect_identical(nrow(resFalse$qcResult$warnings), 0L)
})

test_that("runQcStudbook adds no no-birth-date warning when every animal has a birth date", {
  res <- runQcStudbook(pedGood, reportChanges = TRUE)
  expect_identical(sum(is.na(res$cleaned$birth)), 0L)
  expect_identical(nrow(res$qcResult$warnings), 0L)
})

test_that("runQcStudbook adds no no-birth-date warning when there are errors", {
  ped <- pedFirstBirthBlank(nprcgenekeepr::pedFemaleSireMaleDam)
  res <- runQcStudbook(ped, reportChanges = TRUE)
  expect_true(res$qcResult$hasErrors)
  expect_null(res$cleaned)
  expect_false(noBirthWarning %in% res$qcResult$warnings$Warning)
})

test_that("runQcStudbook adds no no-birth-date warning when the second pass fails", {
  local_mocked_bindings(
    qcStudbook = function(ped, ..., reportErrors) {
      if (reportErrors) getEmptyErrorLst() else stop("second pass failed")
    }
  )
  res <- runQcStudbook(pedFirstBirthBlank(pedGood), reportChanges = TRUE)
  expect_null(res$cleaned)
  expect_identical(nrow(res$qcResult$warnings), 0L)
})

test_that("runQcStudbook puts the no-birth-date warning after a column-rename warning", {
  ped <- data.frame(
    EGO_ID = c("A", "B", "C"),
    SIRE_ID = c(NA, NA, "A"),
    DAM_ID = c(NA, NA, "B"),
    SEX = c("M", "F", "F"),
    BIRTH_DATE = as.Date(c(NA, "2010-01-01", "2015-01-01")),
    stringsAsFactors = FALSE
  )
  res <- runQcStudbook(ped, minSireAge = 2.0, minDamAge = 2.0,
                       reportChanges = TRUE)
  expect_false(res$qcResult$hasErrors)
  expect_identical(res$qcResult$warnings$Warning,
                   c("Column name case changed", noBirthWarning))
})

## S982 (BACKLOG.md:156): the Input tab's "Animals with a death or departure
## before birth" warning. The owner ruled at Pre-RED: a warning (the file still
## loads), strictly earlier only, read from the cleaned exit column. Like the
## no-birth-date warning, runQcStudbook() adds the row to qcResult$warnings
## after its second pass, only when reportChanges is TRUE, after the
## no-birth-date row, and never when errors exist or the second pass fails,
## because then there is no cleaned pedigree to read. The row never makes
## hasErrors TRUE, and qcStudbook() itself stays as it was. pedEarlyExits() is
## in helper-pedEarlyExits.R: o1 and o3 leave before their births, o2 on its
## birth day.
exitBeforeBirthWarning <- "Animals with a death or departure before birth"

test_that("runQcStudbook adds the exit-before-birth warning when reportChanges is TRUE", {
  res <- runQcStudbook(pedEarlyExits(), reportChanges = TRUE)
  expect_false(res$qcResult$hasErrors)
  expect_identical(nrow(res$qcResult$errors), 0L)
  expect_identical(nrow(res$cleaned), 8L)
  expect_identical(res$qcResult$warnings$Warning, exitBeforeBirthWarning)
  expect_match(
    res$qcResult$warnings$Details,
    "^2 of 8 animals have an exit date earlier than their birth date \\(o1, o3\\)\\."
  )
})

test_that("runQcStudbook leaves the exit-before-birth warning out unless reportChanges is TRUE", {
  ped <- pedEarlyExits()
  resDefault <- runQcStudbook(ped)
  ## The two animals do leave before their births; only the argument keeps the
  ## row out, and the pedigree still loads.
  expect_identical(
    sum(resDefault$cleaned$exit < resDefault$cleaned$birth, na.rm = TRUE), 2L
  )
  expect_identical(nrow(resDefault$qcResult$warnings), 0L)
  resFalse <- runQcStudbook(ped, reportChanges = FALSE)
  expect_identical(nrow(resFalse$qcResult$warnings), 0L)
})

test_that("runQcStudbook adds no exit-before-birth warning when no exit is before its birth", {
  ## No exit column at all, then one same-day exit only (not flagged).
  expect_identical(
    nrow(runQcStudbook(pedGood, reportChanges = TRUE)$qcResult$warnings), 0L
  )
  sameDay <- pedEarlyExits()
  sameDay$death_date[sameDay$ego_id == "o1"] <- as.Date("2015-02-04")
  sameDay$departure[sameDay$ego_id == "o3"] <- as.Date("2012-04-11")
  res <- runQcStudbook(sameDay, reportChanges = TRUE)
  expect_identical(sum(res$cleaned$exit == res$cleaned$birth, na.rm = TRUE), 3L)
  expect_identical(nrow(res$qcResult$warnings), 0L)
})

test_that("runQcStudbook reads the dates, so a file's own age column does not hide the warning", {
  ped <- pedEarlyExits()
  ped$age <- 5
  res <- runQcStudbook(ped, reportChanges = TRUE)
  ## qcStudbook() keeps a file's own age column as given.
  expect_identical(unique(res$cleaned$age), 5)
  expect_identical(res$qcResult$warnings$Warning, exitBeforeBirthWarning)
  expect_match(res$qcResult$warnings$Details, "^2 of 8 animals have")
})

test_that("runQcStudbook puts the exit-before-birth warning after the no-birth-date warning", {
  ped <- pedEarlyExits()
  ped$birth_date[1L] <- NA
  res <- runQcStudbook(ped, reportChanges = TRUE)
  expect_false(res$qcResult$hasErrors)
  expect_identical(res$qcResult$warnings$Warning,
                   c(noBirthWarning, exitBeforeBirthWarning))
})

test_that("runQcStudbook adds no exit-before-birth warning when there are errors or the second pass fails", {
  ## Parent ages of 100 years flag every parent: errors, no cleaned pedigree.
  res <- runQcStudbook(pedEarlyExits(), minSireAge = 100, minDamAge = 100,
                       reportChanges = TRUE)
  expect_true(res$qcResult$hasErrors)
  expect_null(res$cleaned)
  expect_false(exitBeforeBirthWarning %in% res$qcResult$warnings$Warning)
  local_mocked_bindings(
    qcStudbook = function(ped, ..., reportErrors) {
      if (reportErrors) getEmptyErrorLst() else stop("second pass failed")
    }
  )
  failed <- runQcStudbook(pedEarlyExits(), reportChanges = TRUE)
  expect_null(failed$cleaned)
  expect_identical(nrow(failed$qcResult$warnings), 0L)
})

test_that("qcStudbook itself stays silent about an exit before its birth", {
  ped <- pedEarlyExits()
  expect_no_warning(cleaned <- qcStudbook(ped))
  expect_identical(nrow(cleaned), 8L)
  expect_identical(sum(cleaned$exit < cleaned$birth, na.rm = TRUE), 2L)
  expect_null(qcStudbook(ped, reportErrors = TRUE))
})

## S988 (BACKLOG.md:141-147, flag PB7): a lowercase `geographicorigin` header is
## renamed to geographicOrigin, and the renamed-column flag must say so.
test_that("runQcStudbook reports a lowercase geographicorigin header as a renamed column", {
  res <- runQcStudbook(pedLowercaseGeographicOrigin(), reportChanges = TRUE)
  expect_true(res$qcResult$hasChangedCols)
  expect_identical(res$qcResult$changedCols$geographicoriginToGeographicOrigin,
                   lowercaseGeographicOriginRename)
  expect_false(res$qcResult$hasErrors)
  expect_true("geographicOrigin" %in% names(res$cleaned))
})

test_that("runQcStudbook reports no renamed column when every header is already right", {
  res <- runQcStudbook(datePed(recordStatus = NULL), reportChanges = TRUE)
  expect_false(res$qcResult$hasChangedCols)
  expect_false(any(lengths(res$qcResult$changedCols) > 0L))
})

## S1020 (BACKLOG.md:168): headers spelled recordStatus, fromCenter and
## geographicOrigin are already right. QC lower-cased them and put the camel
## case back, and still reported a case change (the shipped example file's
## Changed Columns tab said "recordStatus and fromCenter to recordstatus and
## fromcenter").
test_that("runQcStudbook reports no renamed column for headers spelled recordStatus, fromCenter and geographicOrigin", {
  ped <- datePed()
  ped$fromCenter <- rep(c("yes", "no"), 3L)
  ped$geographicOrigin <- rep(c("India", "China"), 3L)
  res <- runQcStudbook(ped, reportChanges = TRUE)
  expect_false(res$qcResult$hasErrors)
  expect_false(res$qcResult$hasChangedCols)
  expect_false(any(lengths(res$qcResult$changedCols) > 0L))
  expect_false("Column name case changed" %in% res$qcResult$warnings$Warning)
  expect_false(shouldShowChangedColsTab(res$qcResult$changedCols))
  expect_true(all(c("recordStatus", "fromCenter", "geographicOrigin") %in%
                    names(res$cleaned)))
})

test_that("runQcStudbook reports no renamed column for the shipped example pedigree", {
  res <- runQcStudbook(examplePedigree, reportChanges = TRUE)
  expect_false(res$qcResult$hasChangedCols)
  expect_false(any(lengths(res$qcResult$changedCols) > 0L))
  expect_false("Column name case changed" %in% res$qcResult$warnings$Warning)
})

test_that("runQcStudbook says in words that a lowercase recordstatus or fromcenter header was renamed", {
  cases <- list(
    recordstatus = list(ped = pedLowercaseRecordStatus(),
                        field = "recordstatusToRecordStatus",
                        rename = lowercaseRecordStatusRename,
                        header = "recordStatus"),
    fromcenter = list(ped = pedLowercaseFromCenter(),
                      field = "fromcenterToFromCenter",
                      rename = lowercaseFromCenterRename,
                      header = "fromCenter")
  )
  for (nm in names(cases)) {
    case <- cases[[nm]]
    res <- runQcStudbook(case$ped, reportChanges = TRUE)
    expect_false(res$qcResult$hasErrors, info = nm)
    expect_true(res$qcResult$hasChangedCols, info = nm)
    expect_identical(res$qcResult$changedCols[[case$field]], case$rename,
                     info = nm)
    expect_identical(names(Filter(length, res$qcResult$changedCols)),
                     case$field, info = nm)
    expect_true(shouldShowChangedColsTab(res$qcResult$changedCols), info = nm)
    expect_true(grepl(
      paste0("Change: The column changed from: ", case$rename, "."),
      summary(res$errorLst)$txt, fixed = TRUE), info = nm)
    expect_true(case$header %in% names(res$cleaned), info = nm)
  }
})

test_that("runQcStudbook says in words that a lowercase geographicorigin header was renamed", {
  res <- runQcStudbook(pedLowercaseGeographicOrigin(), reportChanges = TRUE)
  expect_true(shouldShowChangedColsTab(res$qcResult$changedCols))
  expect_true(grepl(
    paste0("Change: The column changed from: ",
           lowercaseGeographicOriginRename, "."),
    summary(res$errorLst)$txt, fixed = TRUE))
})

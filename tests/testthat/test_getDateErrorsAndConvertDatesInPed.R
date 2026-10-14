## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

## pedInvalidDates has 8 animals; rows 3 ("205-06-19", a three-digit year) and
## 4 ("2002-16-22", a month of 16) have invalid birth dates. Only "added" rows
## (the placeholders qcStudbook() appends for unlisted parents) are skipped by
## date conversion; an NA or unrecognized recordStatus is a real animal.
pedWithStatus <- function(recordStatus = rep("original", 8L)) {
  ped <- nprcgenekeepr::pedInvalidDates
  ped$recordStatus <- recordStatus
  ped
}
## Return the error, not signal it, so a defect shows up as one clean failed
## expectation instead of aborting the test.
runDateQc <- function(ped) {
  tryCatch(
    getDateErrorsAndConvertDatesInPed(ped, getEmptyErrorLst()),
    error = function(e) e
  )
}
errorText <- function(result) {
  if (inherits(result, "error")) conditionMessage(result) else ""
}

test_that(paste0(
  "getDateErrorsAndConvertDatesInPed reports the invalid date rows and ",
  "keeps every animal when every recordStatus is original"
), {
  result <- runDateQc(pedWithStatus())
  expect_false(inherits(result, "error"), info = errorText(result))
  expect_identical(result$errorLst$invalidDateRows, c("3", "4"))
  expect_identical(result$sb$id, nprcgenekeepr::pedInvalidDates$id)
  expect_s3_class(result$sb$birth, "Date")
  expect_true(all(is.na(result$sb$birth[3L:4L])))
})

test_that(paste0(
  "getDateErrorsAndConvertDatesInPed keeps an animal whose recordStatus is ",
  "NA when the pedigree also has invalid dates"
), {
  status <- rep("original", 8L)
  status[6L] <- NA_character_
  result <- runDateQc(pedWithStatus(status))
  expect_false(inherits(result, "error"), info = errorText(result))
  expect_identical(result$errorLst$invalidDateRows, c("3", "4"))
  expect_false(anyNA(result$sb$id))
  expect_identical(result$sb$id, nprcgenekeepr::pedInvalidDates$id)
  expect_s3_class(result$sb$birth, "Date")
})

test_that(paste0(
  "getDateErrorsAndConvertDatesInPed keeps an animal with an unrecognized ",
  "recordStatus when the pedigree also has invalid dates"
), {
  status <- rep("original", 8L)
  status[6L] <- "weird"
  result <- runDateQc(pedWithStatus(status))
  expect_false(inherits(result, "error"), info = errorText(result))
  expect_identical(result$errorLst$invalidDateRows, c("3", "4"))
  expect_identical(result$sb$id, nprcgenekeepr::pedInvalidDates$id)
  expect_s3_class(result$sb$birth, "Date")
})

test_that(paste0(
  "getDateErrorsAndConvertDatesInPed retains added records and reports only ",
  "the invalid dates of original records"
), {
  ped <- pedWithStatus()
  addedRows <- data.frame(
    id = c("x1", "x2"), sire = NA_character_, dam = NA_character_,
    sex = c("M", "F"), birth = NA_character_, recordStatus = "added",
    stringsAsFactors = FALSE
  )
  result <- runDateQc(rbind(ped, addedRows))
  expect_false(inherits(result, "error"), info = errorText(result))
  expect_identical(result$errorLst$invalidDateRows, c("3", "4"))
  expect_identical(result$sb$id, c(ped$id, "x1", "x2"))
  expect_identical(result$sb$recordStatus[9L:10L], c("added", "added"))
})

test_that(paste0(
  "getDateErrorsAndConvertDatesInPed leaves the pedigree unconverted when ",
  "every original record has an invalid date"
), {
  ped <- data.frame(
    id = c("a", "b", "x1"), sire = NA_character_, dam = NA_character_,
    sex = c("M", "F", "M"), birth = c("205-06-19", "2002-16-22", NA),
    recordStatus = c("original", "original", "added"),
    stringsAsFactors = FALSE
  )
  result <- runDateQc(ped)
  expect_false(inherits(result, "error"), info = errorText(result))
  expect_identical(result$errorLst$invalidDateRows, c("1", "2"))
  expect_identical(result$sb, ped)
})

## S987 (BACKLOG.md:141-156; S986 flag PB11). The detection step above scans
## every date column on its own, but the conversion of a pedigree that has
## some invalid dates ran one as.Date() over all its date columns at once.
## as.Date() has no method for a data frame of two or more columns, and for
## one column it reads the date format from the first non-blank value. So a
## file with birth and exit columns (ExamplePedigree.csv has both) stopped with
## "do not know how to convert ..." instead of listing the bad rows, and a
## single date column whose first value was invalid stopped with "character
## string is not in a standard unambiguous format". The pedigrees above have
## one date column and a valid first value, so they never reached it, and
## test_qcStudbook.R makes every row invalid, which skips the conversion.
datePedBirth <- c(
  "2000-01-05", "2000-02-06", "2005-03-07", "2006-04-08", "2007-05-09",
  "2008-06-10"
)
datePedExit <- c(NA, NA, "2015-03-07", NA, "2016-05-09", NA)
datePed <- function(birth = datePedBirth, exit = datePedExit) {
  data.frame(
    id = paste0("a", 1L:6L),
    sire = c(NA, NA, "a1", "a1", "a1", "a1"),
    dam = c(NA, NA, "a2", "a2", "a2", "a2"),
    sex = c("M", "F", "M", "F", "M", "F"),
    birth = birth, exit = exit, recordStatus = "original",
    stringsAsFactors = FALSE
  )
}
## Both date columns come back as Date, with blanks only where the file's own
## text was invalid and every other date unchanged.
expectConvertedDates <- function(result, birth, exit) {
  expect_false(inherits(result, "error"), info = errorText(result))
  expect_s3_class(result$sb$birth, "Date")
  expect_s3_class(result$sb[["exit"]], "Date")
  expect_identical(as.character(result$sb$birth), birth)
  expect_identical(as.character(result$sb[["exit"]]), exit)
}

test_that(paste0(
  "getDateErrorsAndConvertDatesInPed lists a bad birth date by row when the ",
  "pedigree also has an exit column"
), {
  result <- runDateQc(datePed(birth = replace(datePedBirth, 3L, "2010-16-22")))
  expect_identical(result$errorLst$invalidDateRows, "3")
  expectConvertedDates(result, replace(datePedBirth, 3L, NA), datePedExit)
})

test_that(paste0(
  "getDateErrorsAndConvertDatesInPed lists a bad exit date by row when the ",
  "pedigree also has a birth column"
), {
  result <- runDateQc(datePed(exit = replace(datePedExit, 5L, "2016-13-40")))
  expect_identical(result$errorLst$invalidDateRows, "5")
  expectConvertedDates(result, datePedBirth, replace(datePedExit, 5L, NA))
})

test_that(paste0(
  "getDateErrorsAndConvertDatesInPed lists a bad date in each of two date ",
  "columns, each on its own row"
), {
  result <- runDateQc(datePed(
    birth = replace(datePedBirth, 3L, "2010-16-22"),
    exit = replace(datePedExit, 5L, "2016-13-40")
  ))
  expect_identical(result$errorLst$invalidDateRows, c("3", "5"))
  expectConvertedDates(
    result, replace(datePedBirth, 3L, NA), replace(datePedExit, 5L, NA)
  )
})

test_that(paste0(
  "getDateErrorsAndConvertDatesInPed converts a single date column whose ",
  "first value is invalid"
), {
  ped <- datePed(birth = replace(datePedBirth, 1L, "2000-99-99"))
  ped$exit <- NULL
  result <- runDateQc(ped)
  expect_false(inherits(result, "error"), info = errorText(result))
  expect_identical(result$errorLst$invalidDateRows, "1")
  expect_s3_class(result$sb$birth, "Date")
  expect_identical(as.character(result$sb$birth), replace(datePedBirth, 1L, NA))
})

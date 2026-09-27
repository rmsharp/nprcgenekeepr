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

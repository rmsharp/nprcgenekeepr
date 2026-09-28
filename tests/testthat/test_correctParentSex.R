## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)
pedOne <- data.frame(
  id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
  sire = c(NA, "s0", "s4", NA, "s1", "s1", "s2", "s2"),
  dam = c(NA, "d0", "d4", NA, "d1", "d2", "d2", "d2"),
  sex = c("F", "F", "M", "F", "F", "F", "F", "M"),
  recordStatus = rep("original", 8L),
  stringsAsFactors = FALSE
)
pedTwo <- data.frame(
  id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
  sire = c(NA, "s0", "s4", NA, "s1", "s1", "s2", "s2"),
  dam = c("d0", "d0", "d4", NA, "d1", "d2", "d2", "d2"),
  sex = c("M", "M", "M", "F", "F", "F", "F", "M"),
  recordStatus = rep("original", 8L),
  stringsAsFactors = FALSE
)
pedThree <- data.frame(
  id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
  sire = c(NA, "s0", "s4", NA, "s1", "s1", "s2", "s2"),
  dam = c("d0", "d0", "d4", NA, "d1", "d2", "s1", "d2"),
  sex = c("M", "M", "M", "F", "F", "F", "F", "M"),
  recordStatus = rep("original", 8L),
  stringsAsFactors = FALSE
)

pedOne$sex <- correctParentSex(
  pedOne$id, pedOne$sire, pedOne$dam, pedOne$sex,
  pedOne$recordStatus
)
pedTwo$sex <- correctParentSex(
  pedTwo$id, pedTwo$sire, pedTwo$dam, pedTwo$sex,
  pedOne$recordStatus
)
test_that("correctParentSex makes correct changes", {
  expect_true(pedOne$sex[1L] == "M")
  expect_true(pedTwo$sex[2L] == "F")
  expect_error(correctParentSex(
    pedThree$id, pedThree$sire, pedThree$dam,
    pedThree$sex, pedOne$recordStatus
  ))
})
test_that(paste0(
  "correctParentSex returns NULLs if no errors detected and ",
  "reportErrors flag is TRUE"
), {
  test <- correctParentSex(pedOne$id, pedOne$sire, pedOne$dam, pedOne$sex,
    pedOne$recordStatus,
    reportErrors = TRUE
  )
  expect_true(is.null(test$femaleSires) & is.null(test$maleDams))
  test <- correctParentSex(pedTwo$id, pedTwo$sire, pedTwo$dam, pedTwo$sex,
    pedOne$recordStatus,
    reportErrors = TRUE
  )
  expect_true(is.null(test$femaleSires) & is.null(test$maleDams))
})
test_that(paste0(
  "correctParentSex returns character vector with ID where ",
  "errors detected and reportErrors flag is TRUE"
), {
  expect_equal(correctParentSex(pedThree$id, pedThree$sire, pedThree$dam,
    pedThree$sex, pedOne$recordStatus,
    reportErrors = TRUE
  )$sireAndDam, "s1")
  pedTwo <- data.frame(
    id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
    sire = c(NA, "s0", "s4", NA, "s1", "s1", "s2", "s2"),
    dam = c("d0", "d0", "d4", NA, "d1", "d2", "d2", "d2"),
    sex = c("M", "M", "M", "F", "F", "F", "F", "M"),
    stringsAsFactors = FALSE
  )
  expect_identical(correctParentSex(pedTwo$id, pedTwo$sire, pedTwo$dam, pedTwo$sex,
    pedOne$recordStatus,
    reportErrors = TRUE
  )$maleDams, "d1")
})

# --- NEW-37: the correction branch must mirror the report branch -------------
# The report branch (reportErrors = TRUE) deliberately exempts H/U parents
# (correctParentSex.R:71,73 use `!sex %in% c("H","U","M")` / `c("H","U","F")`).
# The default correction branch (reportErrors = FALSE) must agree: a
# hermaphrodite ("H") or unknown-sex ("U") animal listed as a sire/dam keeps
# its recorded sex and is NOT silently rewritten to M/F.
pedHU <- data.frame(
  id = c("sH", "sU", "dH", "dU", "o1", "o2"),
  sire = c(NA, NA, NA, NA, "sH", "sU"),
  dam = c(NA, NA, NA, NA, "dH", "dU"),
  sex = c("H", "U", "H", "U", "F", "M"),
  recordStatus = rep("original", 6L),
  stringsAsFactors = FALSE
)
test_that("correctParentSex leaves H/U sires and dams unchanged (NEW-37)", {
  corrected <- correctParentSex(
    pedHU$id, pedHU$sire, pedHU$dam, pedHU$sex, pedHU$recordStatus
  )
  expect_identical(corrected[pedHU$id == "sH"], "H") # H sire stays H
  expect_identical(corrected[pedHU$id == "sU"], "U") # U sire stays U
  expect_identical(corrected[pedHU$id == "dH"], "H") # H dam stays H
  expect_identical(corrected[pedHU$id == "dU"], "U") # U dam stays U
})
test_that(paste0(
  "correctParentSex still corrects true female-sires and male-dams ",
  "(NEW-37 guard)"
), {
  pedMix <- data.frame(
    id = c("fSire", "mDam", "o1"),
    sire = c(NA, NA, "fSire"),
    dam = c(NA, NA, "mDam"),
    sex = c("F", "M", "F"),
    recordStatus = rep("original", 3L),
    stringsAsFactors = FALSE
  )
  corrected <- correctParentSex(
    pedMix$id, pedMix$sire, pedMix$dam, pedMix$sex, pedMix$recordStatus
  )
  expect_identical(corrected[pedMix$id == "fSire"], "M") # F sire -> M
  expect_identical(corrected[pedMix$id == "mDam"], "F") # M dam  -> F
})
test_that(paste0(
  "qcStudbook preserves a U-sex parent through the canonical pipeline ",
  "(NEW-37)"
), {
  sb <- data.frame(
    id = c("sU", "dF", "o1"),
    sire = c(NA, NA, "sU"),
    dam = c(NA, NA, "dF"),
    sex = c("U", "F", "F"),
    birth = as.Date(c("2000-01-01", "2000-01-01", "2010-01-01")),
    recordStatus = rep("original", 3L),
    stringsAsFactors = FALSE
  )
  ped <- qcStudbook(sb, reportErrors = FALSE)
  expect_identical(as.character(ped$sex[ped$id == "sU"]), "U")
})

## --- recordStatus contract of the report branch (S787) -----------------------
## Only "added" is a special recordStatus (the removeUnknownAnimals(),
## convertDate() and removeDuplicates() contract). An NA, blank or unrecognised
## status is a real animal, and an absent (NULL) status means no added rows are
## known, so every animal is checked. Script-only reach: qcStudbook() rewrites
## the column through addParents() before this function sees it.
## s1 is a female sire and d1 a male dam; sH (H) and dU (U) are exempt.
statusPed <- data.frame(
  id = c("s1", "d1", "sH", "dU", "o1", "o2", "o3", "o4"),
  sire = c(NA, NA, NA, NA, "s1", "s1", "sH", "s1"),
  dam = c(NA, NA, NA, NA, "d1", "d1", "dU", "d1"),
  sex = c("F", "M", "H", "U", "F", "M", "F", "M"),
  stringsAsFactors = FALSE
)
statusReport <- function(status, ped = statusPed) {
  correctParentSex(ped$id, ped$sire, ped$dam, ped$sex, status,
    reportErrors = TRUE
  )
}
statusAt <- function(pos, value) {
  status <- rep("original", nrow(statusPed))
  status[pos] <- value
  status
}
allStatus <- function(value) rep(value, nrow(statusPed))
## The same status put on the sire, the dam, both, every row, and as a scalar.
statusCases <- function(value) {
  list(
    sire = statusAt(1L, value), dam = statusAt(2L, value),
    both = statusAt(1L:2L, value), all = allStatus(value), scalar = value
  )
}

test_that("correctParentSex names a parent whose recordStatus is NA", {
  cases <- statusCases(NA_character_)
  for (nm in names(cases)) {
    report <- statusReport(cases[[nm]])
    expect_identical(report$femaleSires, "s1", info = nm)
    expect_identical(report$maleDams, "d1", info = nm)
  }
})
test_that("correctParentSex never puts an NA into the reported ids", {
  cases <- statusCases(NA_character_)
  for (nm in names(cases)) {
    expect_false(anyNA(unlist(statusReport(cases[[nm]]))), info = nm)
  }
})
test_that("correctParentSex treats a blank or unrecognised status as real", {
  for (value in c("", "weird", "Original")) {
    cases <- statusCases(value)
    for (nm in names(cases)) {
      report <- statusReport(cases[[nm]])
      expect_identical(report$femaleSires, "s1", info = paste(nm, value))
      expect_identical(report$maleDams, "d1", info = paste(nm, value))
    }
  }
})
test_that("control: only the exact status added is set aside", {
  ## a case variant of "added" is an unrecognised status, so a real animal
  for (value in c("Added", "ADDED")) {
    cases <- statusCases(value)
    for (nm in names(cases)) {
      report <- statusReport(cases[[nm]])
      expect_identical(report$femaleSires, "s1", info = paste(nm, value))
      expect_identical(report$maleDams, "d1", info = paste(nm, value))
    }
  }
})
test_that("correctParentSex checks every animal when recordStatus is NULL", {
  report <- statusReport(NULL)
  expect_identical(report$femaleSires, "s1")
  expect_identical(report$maleDams, "d1")
  expect_null(report$sireAndDam)
})
test_that("correctParentSex skips only the added parents of a mixed status", {
  naAndAdded <- statusAt(1L, NA_character_)
  naAndAdded[2L] <- "added"
  report <- statusReport(naAndAdded)
  expect_identical(report$femaleSires, "s1") # NA status: a real animal
  expect_null(report$maleDams) # added: skipped
  addedAndNA <- statusAt(2L, NA_character_)
  addedAndNA[1L] <- "added"
  report <- statusReport(addedAndNA)
  expect_null(report$femaleSires)
  expect_identical(report$maleDams, "d1")
  weirdAndNA <- statusAt(1L, "weird")
  weirdAndNA[2L] <- NA_character_
  report <- statusReport(weirdAndNA)
  expect_identical(report$femaleSires, "s1")
  expect_identical(report$maleDams, "d1")
})
test_that("control: an added parent is still left out of the report", {
  report <- statusReport(statusAt(1L, "added"))
  expect_null(report$femaleSires)
  expect_identical(report$maleDams, "d1")
  report <- statusReport(statusAt(1L:2L, "added"))
  expect_null(report$femaleSires)
  expect_null(report$maleDams)
  report <- statusReport("added")
  expect_null(report$femaleSires)
  expect_null(report$maleDams)
})
test_that("control: a status on a row that is not a parent changes nothing", {
  for (value in list(NA_character_, "weird", "added")) {
    report <- statusReport(statusAt(5L:8L, value))
    expect_identical(report$femaleSires, "s1")
    expect_identical(report$maleDams, "d1")
  }
})
test_that("control: an all-original or scalar original status reports both", {
  for (status in list(allStatus("original"), "original")) {
    report <- statusReport(status)
    expect_identical(report$femaleSires, "s1")
    expect_identical(report$maleDams, "d1")
    expect_null(report$sireAndDam)
  }
})
test_that("control: H and U parents are never reported, whatever the status", {
  statuses <- list(
    original = allStatus("original"), na = allStatus(NA_character_),
    weird = allStatus("weird"), added = allStatus("added"), null = NULL
  )
  for (nm in names(statuses)) {
    reported <- unlist(statusReport(statuses[[nm]]))
    expect_false(any(c("sH", "dU") %in% reported), info = nm)
  }
})
test_that("control: the correction branch and sireAndDam ignore the status", {
  expected <- c("M", "F", "H", "U", "F", "M", "F", "M")
  bothPed <- statusPed
  bothPed$dam[7L] <- "s1" # s1 is now listed as both a sire and a dam
  statuses <- list(
    original = allStatus("original"), na = allStatus(NA_character_),
    weird = allStatus("weird"), null = NULL
  )
  for (nm in names(statuses)) {
    corrected <- correctParentSex(
      statusPed$id, statusPed$sire, statusPed$dam, statusPed$sex,
      statuses[[nm]]
    )
    expect_identical(corrected, expected, info = nm)
    expect_identical(statusReport(statuses[[nm]], bothPed)$sireAndDam, "s1",
      info = nm
    )
  }
})
test_that(paste0(
  "control: qcStudbook still reports a female sire and male dam by id when ",
  "the input recordStatus column holds NA, blank or unrecognised values"
), {
  sb <- data.frame(
    id = c("s1", "d1", "o1", "o2", "o3"),
    sire = c(NA, NA, "s1", "s1", "u1"),
    dam = c(NA, NA, "d1", "d1", NA),
    sex = c("F", "M", "F", "M", "F"),
    birth = as.Date(c(
      "2000-01-01", "2000-01-01", "2010-01-01", "2010-01-01", "2011-01-01"
    )),
    recordStatus = c(NA, "weird", "", NA, "original"),
    stringsAsFactors = FALSE
  )
  errorLst <- qcStudbook(sb, reportErrors = TRUE)
  expect_identical(errorLst$femaleSires, "s1")
  expect_identical(errorLst$maleDams, "d1")
})

## --- Blank, unreadable and space-padded parent sex (S799) --------------------
## convertSexCodes() reads a blank or unrecognized sex as "U" and ignores
## spaces around a code, so qcStudbook() no longer reports such a parent as a
## "female sire" or "male dam". Before S799 it did, and with
## reportErrors = FALSE it silently set the sire to "M" and the dam to "F".
unreadableSexPed <- data.frame(
  id = c("sBlank", "dXyz", "sPad", "dPad", "o1", "o2", "o3"),
  sire = c(NA, NA, NA, NA, "sBlank", "sPad", NA),
  dam = c(NA, NA, NA, NA, "dXyz", "dPad", NA),
  sex = c("", "xyz", "M ", " F", "F", "M", ""),
  birth = as.Date(c(
    "2000-01-01", "2000-01-01", "2000-01-01", "2000-01-01",
    "2010-01-01", "2010-01-01", "2011-01-01"
  )),
  stringsAsFactors = FALSE
)
sexOf <- function(ped, id) as.character(ped$sex[ped$id == id])

test_that("qcStudbook does not report a parent whose sex cannot be read", {
  errorLst <- qcStudbook(unreadableSexPed, reportErrors = TRUE)
  expect_false("sBlank" %in% errorLst$femaleSires)
  expect_false("dXyz" %in% errorLst$maleDams)
})
test_that("qcStudbook does not report a parent whose sex code has spaces", {
  errorLst <- qcStudbook(unreadableSexPed, reportErrors = TRUE)
  expect_false("sPad" %in% errorLst$femaleSires)
  expect_false("dPad" %in% errorLst$maleDams)
  expect_length(errorLst$femaleSires, 0L)
  expect_length(errorLst$maleDams, 0L)
})
test_that("qcStudbook returns an unreadable sex as U, never NA or a guess", {
  ped <- qcStudbook(unreadableSexPed, reportErrors = FALSE)
  expect_identical(sexOf(ped, "sBlank"), "U") # was silently set to "M"
  expect_identical(sexOf(ped, "dXyz"), "U") # was silently set to "F"
  expect_identical(sexOf(ped, "o3"), "U") # a non-parent; was NA
  expect_false(anyNA(ped$sex))
})
## Holds before S799 only because the unreadable padded code became NA and
## the correction step then guessed "M" / "F"; after S799 the code is read.
test_that("control: qcStudbook returns a space-padded parent sex as named", {
  ped <- qcStudbook(unreadableSexPed, reportErrors = FALSE)
  expect_identical(sexOf(ped, "sPad"), "M")
  expect_identical(sexOf(ped, "dPad"), "F")
})
test_that("the app's QC step loads a pedigree with an unreadable parent sex", {
  result <- runQcStudbook(unreadableSexPed)
  expect_false(any(result$qcResult$errors$Error %in%
    c("Female listed as sire", "Male listed as dam")))
  expect_false(is.null(result$cleaned))
  expect_identical(sexOf(result$cleaned, "sBlank"), "U")
})
test_that("control: a sire recorded as female is still reported", {
  femaleSirePed <- unreadableSexPed
  femaleSirePed$sex[femaleSirePed$id == "sBlank"] <- "F"
  errorLst <- qcStudbook(femaleSirePed, reportErrors = TRUE)
  expect_true("sBlank" %in% errorLst$femaleSires)
})

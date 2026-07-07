## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
qcPed <- nprcgenekeepr::qcPed

test_that("checkParentAge identifies the over aged parents", {
  underAgeTwo <- checkParentAge(qcPed, minSireAge = 2L, minDamAge = 2L)
  underAgeThree <- checkParentAge(qcPed, minSireAge = 3L, minDamAge = 3L)
  underAgeFive <- checkParentAge(qcPed, minSireAge = 5L, minDamAge = 5L)
  underAgeSix <- checkParentAge(qcPed, minSireAge = 6L, minDamAge = 6L)
  underAgeTen <- checkParentAge(qcPed, minSireAge = 10L, minDamAge = 10L)
  expect_identical(nrow(underAgeTwo), 0L)
  expect_identical(nrow(underAgeThree), 0L)
  expect_identical(nrow(underAgeFive), 1L)
  expect_identical(nrow(underAgeSix), 6L)
  expect_true(all(underAgeSix$dam %in% c(
    "EX98QB", "L42X7I", "MRGPPA",
    "O4Z4IB", "RY6OPR", "ZYTIYY"
  )))
  expect_true(
    all(underAgeTen$sire[underAgeTen$sireAge < 10L &
      !is.na(underAgeTen$sireAge)] %in%
      c(
        "HRQJQR", "HBEMKY", "0RZ5LL", "F0YSEE", "HP3E04", "716P7O",
        "WMUJC5", "TNAWBK", "QDY8I7", "V8VU31", "H00H7D", "YIAD2N",
        "HRBVOE", "48YAZ5", "CQMWGX", "549AEC", "H0UP6R", "ODSV6N",
        "IZ0ELE"
      ))
  )
})
test_that("checkParentAge requires birth column to be potential date", {
  ped <- qcPed
  ped$birth <- ped$birth > "2000-01-01"
  expect_error(checkParentAge(ped, minSireAge = 3L, minDamAge = 3L))
})
test_that("checkParentAge allows birth column to be character", {
  ped <- qcPed
  ped$birth <- format(ped$birth, format = "%Y-%m-%d")
  expect_equal(nrow(checkParentAge(ped, minSireAge = 6L, minDamAge = 6L)), 6L)
  ped <- qcPed
  ped$birth <- format(ped$birth, format = "%m-%d-%Y")
  expect_equal(nrow(checkParentAge(ped, minSireAge = 6L, minDamAge = 6L)), 6L)
})
test_that(paste0(
  "checkParentAge returns unchanged dataframe if required ",
  "column is missing"
), {
  ped <- checkParentAge(qcPed[, !names(qcPed) == "id"])
  expect_equal(ncol(ped), ncol(qcPed[, !names(qcPed) == "id"]))
  expect_equal(ped, qcPed[, !names(qcPed) == "id"])
})
test_that(paste0(
  "checkParentAge returns NULL if required column is missing ",
  "and reportErrors == TRUE"
), {
  ped <- checkParentAge(qcPed[, !names(qcPed) %in% "id"], reportErrors = TRUE)
  expect_null(ped)
})
test_that(paste0(
  "checkParentAge returns NULL if required dataframe has no ",
  "rows  and reportErrors == TRUE"
), {
  ped <- checkParentAge(qcPed[0L, ], reportErrors = TRUE)
  expect_null(ped)
})
test_that("checkParentAge invalid date field class", {
  qcPed$birth <- as.numeric(qcPed$birth)
  ped <- checkParentAge(qcPed, reportErrors = TRUE)
  expect_null(ped)
})

## Issue #119 Slice 1 -----------------------------------------------------
## A species-bearing fixture: two offspring both born 2010-01-01. OFFA's
## sire was 3 yrs old at its birth (rhesus male floor = 4 -> flagged); OFFA's
## dam was 5 (rhesus female floor = 2.5 -> not flagged). OFFB's sire was 10
## (>= 4) and dam was 3 (>= 2.5) -> not flagged. The floor keys on the
## PARENT's species+sex, so only OFFA is returned when no overrides are given.
speciesFixture <- data.frame(
  id = c("SIREA", "DAMA", "SIREB", "DAMB", "OFFA", "OFFB"),
  sire = c(NA, NA, NA, NA, "SIREA", "SIREB"),
  dam = c(NA, NA, NA, NA, "DAMA", "DAMB"),
  sex = c("M", "F", "M", "F", "F", "M"),
  birth = as.Date(c(
    "2007-01-01", "2005-01-01", "2000-01-01", "2007-01-01",
    "2010-01-01", "2010-01-01"
  )),
  exit = as.Date(NA),
  species = rep("RHESUS", 6L),
  stringsAsFactors = FALSE
)

test_that("checkParentAge applies sex- and species-specific floors", {
  flagged <- checkParentAge(speciesFixture)
  expect_identical(nrow(flagged), 1L)
  expect_identical(flagged$id, "OFFA")
})

test_that("checkParentAge minSireAge overrides only the sire floor", {
  ## Lower the sire floor to 2 -> the 3-yr sire is no longer flagged, and no
  ## dam is under 2.5, so nothing is returned.
  flagged <- checkParentAge(speciesFixture, minSireAge = 2L)
  expect_identical(nrow(flagged), 0L)
})

test_that("checkParentAge minDamAge overrides only the dam floor", {
  ## Raise the dam floor to 4 -> OFFB's 3-yr dam is now flagged too, in
  ## addition to OFFA (3-yr sire, floor 4).
  flagged <- checkParentAge(speciesFixture, minDamAge = 4L)
  expect_identical(nrow(flagged), 2L)
  expect_true(all(c("OFFA", "OFFB") %in% flagged$id))
})

test_that("checkParentAge degrades to floor 2 when species is absent", {
  noSpecies <- speciesFixture[, setdiff(names(speciesFixture), "species")]
  expect_identical(nrow(checkParentAge(noSpecies)), 0L)
})

test_that("checkParentAge minParentAge alias reproduces result and warns", {
  lifecycle::expect_deprecated(
    res <- checkParentAge(qcPed, minParentAge = 6L)
  )
  expect_identical(nrow(res), 6L)
})

test_that("checkParentAge minParentAge = NULL disables the check (legacy)", {
  ## Back-compat: minParentAge = NULL historically disabled the age check.
  ## The species default would flag OFFA, but the legacy alias must not.
  suppressWarnings(
    res <- checkParentAge(speciesFixture, minParentAge = NULL)
  )
  expect_identical(nrow(res), 0L)
})

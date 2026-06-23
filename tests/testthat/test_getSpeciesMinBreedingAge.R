#' Copyright(c) 2017-2026 R. Mark Sharp
#' This file is part of nprcgenekeepr
##
## Tests for getSpeciesMinBreedingAge() and the minMaleBreedingAge /
## minFemaleBreedingAge columns added to the speciesGestation lookup table
## (issue #9 Slice 2, plan section 8-D): a per-species, per-sex minimum
## breeding-age lookup with a case/whitespace-insensitive species key and a
## 2-year fallback for any species not present in the table (or any sex that is
## not "M"/"F"). The shipped table is seeded with rhesus male = 4, female = 3.
## Generalizing the table to all common colony NHP species and making the
## values user-configurable is tracked as issue #73.

test_that("speciesGestation carries minMaleBreedingAge / minFemaleBreedingAge", {
  tbl <- nprcgenekeepr::speciesGestation
  expect_true(all(c("minMaleBreedingAge", "minFemaleBreedingAge") %in%
    names(tbl)))
  expect_type(tbl$minMaleBreedingAge, "integer")
  expect_type(tbl$minFemaleBreedingAge, "integer")
  ## seeded with rhesus male = 4, female = 3 (owner's v1 choice; fallback 2)
  isRhesus <- toupper(trimws(tbl$species)) == "RHESUS"
  expect_true(any(isRhesus))
  expect_identical(as.integer(tbl$minMaleBreedingAge[isRhesus]), 4L)
  expect_identical(as.integer(tbl$minFemaleBreedingAge[isRhesus]), 3L)
})

test_that("getSpeciesMinBreedingAge returns the seeded rhesus values", {
  expect_identical(getSpeciesMinBreedingAge("RHESUS", "M"), 4L)
  expect_identical(getSpeciesMinBreedingAge("RHESUS", "F"), 3L)
})

test_that("getSpeciesMinBreedingAge is case- and whitespace-insensitive", {
  expect_identical(getSpeciesMinBreedingAge("rhesus", "M"), 4L)
  expect_identical(getSpeciesMinBreedingAge("  Rhesus  ", "F"), 3L)
  ## sex is matched case/whitespace-insensitively too
  expect_identical(getSpeciesMinBreedingAge("RHESUS", " m "), 4L)
  expect_identical(getSpeciesMinBreedingAge("RHESUS", "f"), 3L)
})

test_that("getSpeciesMinBreedingAge falls back to 2 for unknown species", {
  expect_identical(getSpeciesMinBreedingAge("JAPANESE MACAQUE", "M"), 2L)
  expect_identical(getSpeciesMinBreedingAge("UNICORN", "F"), 2L)
})

test_that("getSpeciesMinBreedingAge falls back to 2 for NA / empty species", {
  expect_identical(getSpeciesMinBreedingAge(NA_character_, "M"), 2L)
  expect_identical(getSpeciesMinBreedingAge("", "F"), 2L)
})

test_that("getSpeciesMinBreedingAge falls back to 2 for a sex that is not M/F", {
  ## a known species but an unusable sex still yields the default
  expect_identical(getSpeciesMinBreedingAge("RHESUS", "U"), 2L)
  expect_identical(getSpeciesMinBreedingAge("RHESUS", NA_character_), 2L)
})

test_that("getSpeciesMinBreedingAge is vectorized and preserves length/order", {
  out <- getSpeciesMinBreedingAge(
    c("RHESUS", "RHESUS", "UNICORN", NA_character_),
    c("M", "F", "M", "F")
  )
  expect_identical(out, c(4L, 3L, 2L, 2L))
  expect_length(out, 4L)
})

test_that("getSpeciesMinBreedingAge recycles a scalar sex across species", {
  out <- getSpeciesMinBreedingAge(c("RHESUS", "UNICORN"), "M")
  expect_identical(out, c(4L, 2L))
})

test_that("getSpeciesMinBreedingAge uses an injected breedingTable", {
  tbl <- data.frame(
    species = c("RHESUS", "TESTSP"),
    minMaleBreedingAge = c(4L, 7L),
    minFemaleBreedingAge = c(3L, 6L),
    stringsAsFactors = FALSE
  )
  expect_identical(
    getSpeciesMinBreedingAge("TESTSP", "M", breedingTable = tbl), 7L
  )
  expect_identical(
    getSpeciesMinBreedingAge("testsp", "F", breedingTable = tbl), 6L
  )
  expect_identical(
    getSpeciesMinBreedingAge("RHESUS", "M", breedingTable = tbl), 4L
  )
  ## a species absent from the injected table falls back to the default
  expect_identical(
    getSpeciesMinBreedingAge("OTHER", "M", breedingTable = tbl), 2L
  )
})

test_that("getSpeciesMinBreedingAge honors a custom default", {
  tbl <- data.frame(
    species = "TESTSP",
    minMaleBreedingAge = 7L,
    minFemaleBreedingAge = 6L,
    stringsAsFactors = FALSE
  )
  expect_identical(
    getSpeciesMinBreedingAge("OTHER", "M", breedingTable = tbl, default = 5L),
    5L
  )
})

test_that("getSpeciesMinBreedingAge returns integer(0) for empty input", {
  expect_identical(
    getSpeciesMinBreedingAge(character(0L), character(0L)), integer(0L)
  )
})

test_that("getSpeciesMinBreedingAge returns an integer vector", {
  expect_type(getSpeciesMinBreedingAge("RHESUS", "M"), "integer")
  expect_type(
    getSpeciesMinBreedingAge(c("RHESUS", "UNICORN"), c("M", "F")), "integer"
  )
})

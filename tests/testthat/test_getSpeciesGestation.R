#' Copyright(c) 2017-2026 R. Mark Sharp
#' This file is part of nprcgenekeepr
##
## Tests for getSpeciesGestation() and the speciesGestation lookup table
## (issue #46 item 2): a per-species maximum-gestation lookup with a
## case/whitespace-insensitive key and a 210-day fallback for any species not
## present in the table. The shipped table is seeded with rhesus = 210 (the
## conservative upper bound; typical rhesus gestation ~165 d). A custom
## gestationTable can be injected to exercise differentiation.

test_that("speciesGestation is a shipped lookup with species and gestation columns", {
  tbl <- nprcgenekeepr::speciesGestation
  expect_s3_class(tbl, "data.frame")
  expect_true(all(c("species", "gestation") %in% names(tbl)))
  expect_type(tbl$species, "character")
  expect_type(tbl$gestation, "integer")
  ## seeded with rhesus = 210 (owner's v1 choice; fallback also 210)
  isRhesus <- toupper(trimws(tbl$species)) == "RHESUS"
  expect_true(any(isRhesus))
  expect_identical(as.integer(tbl$gestation[isRhesus]), 210L)
})

test_that("getSpeciesGestation returns the shipped value for a known species", {
  expect_identical(getSpeciesGestation("RHESUS"), 210L)
})

test_that("getSpeciesGestation is case- and whitespace-insensitive", {
  expect_identical(getSpeciesGestation("rhesus"), 210L)
  expect_identical(getSpeciesGestation("  Rhesus  "), 210L)
})

test_that("getSpeciesGestation falls back to the default for unknown species", {
  expect_identical(getSpeciesGestation("JAPANESE MACAQUE"), 210L)
  expect_identical(getSpeciesGestation("UNICORN"), 210L)
})

test_that("getSpeciesGestation falls back to the default for NA and empty strings", {
  expect_identical(getSpeciesGestation(NA_character_), 210L)
  expect_identical(getSpeciesGestation(""), 210L)
})

test_that("getSpeciesGestation is vectorized and preserves length and order", {
  out <- getSpeciesGestation(c("RHESUS", "UNICORN", NA_character_))
  expect_identical(out, c(210L, 210L, 210L))
  expect_length(out, 3L)
})

test_that("getSpeciesGestation uses an injected gestationTable when supplied", {
  tbl <- data.frame(
    species = c("RHESUS", "TESTSP"),
    gestation = c(210L, 99L),
    stringsAsFactors = FALSE
  )
  expect_identical(getSpeciesGestation("TESTSP", gestationTable = tbl), 99L)
  ## case-insensitive against the injected table too
  expect_identical(getSpeciesGestation("testsp", gestationTable = tbl), 99L)
  expect_identical(getSpeciesGestation("RHESUS", gestationTable = tbl), 210L)
  ## a species absent from the injected table falls back to the default
  expect_identical(getSpeciesGestation("OTHER", gestationTable = tbl), 210L)
})

test_that("getSpeciesGestation honors a custom default for unknown species", {
  tbl <- data.frame(species = "TESTSP", gestation = 99L, stringsAsFactors = FALSE)
  expect_identical(
    getSpeciesGestation("OTHER", gestationTable = tbl, default = 150L), 150L
  )
})

test_that("getSpeciesGestation returns integer(0) for empty input", {
  expect_identical(getSpeciesGestation(character(0L)), integer(0L))
})

test_that("getSpeciesGestation returns an integer vector", {
  expect_type(getSpeciesGestation("RHESUS"), "integer")
  expect_type(getSpeciesGestation(c("RHESUS", "UNICORN")), "integer")
})

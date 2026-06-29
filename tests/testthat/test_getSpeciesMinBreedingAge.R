## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Tests for getSpeciesMinBreedingAge() and the minMaleBreedingAge /
## minFemaleBreedingAge columns of the speciesGestation lookup table (issue #9
## Slice 2, plan section 8-D; generalized to all common colony NHP species in
## issue #73): a per-species, per-sex minimum breeding-age lookup with a
## case/whitespace-insensitive species key and a 2-year fallback for any species
## not present in the table (or any sex that is not "M"/"F"). The breeding-age
## columns are NUMERIC (years) so fractional minima such as 2.5 are represented
## exactly. Issue #73 populates the table for all common colony NHP species; the
## user-configurable override path is a separate slice.

test_that("speciesGestation carries numeric minMale/minFemale breeding ages", {
  tbl <- nprcgenekeepr::speciesGestation
  expect_true(all(c("minMaleBreedingAge", "minFemaleBreedingAge") %in%
    names(tbl)))
  ## breeding-age columns are numeric so fractional minima (e.g. 2.5) are exact
  expect_type(tbl$minMaleBreedingAge, "double")
  expect_type(tbl$minFemaleBreedingAge, "double")
  ## rhesus: male 4, female 2.5 (issue #73 values; fallback 2)
  isRhesus <- toupper(trimws(tbl$species)) == "RHESUS"
  expect_true(any(isRhesus))
  expect_identical(tbl$minMaleBreedingAge[isRhesus], 4)
  expect_identical(tbl$minFemaleBreedingAge[isRhesus], 2.5)
})

test_that("speciesGestation carries all common colony NHP species (issue #73)", {
  tbl <- nprcgenekeepr::speciesGestation
  allSpeciesKeys <- c(
    "RHESUS", "CYNOMOLGUS", "JAPANESE MACAQUE", "PIG-TAILED MACAQUE", "BABOON",
    "VERVET", "AFRICAN GREEN MONKEY", "SQUIRREL MONKEY", "COMMON MARMOSET",
    "COTTON-TOP TAMARIN", "OWL MONKEY", "CAPUCHIN", "CHIMPANZEE", "BONOBO"
  )
  present <- toupper(trimws(tbl$species))
  expect_true(all(allSpeciesKeys %in% present))
})

test_that("getSpeciesMinBreedingAge returns the seeded rhesus values", {
  expect_identical(getSpeciesMinBreedingAge("RHESUS", "M"), 4)
  expect_identical(getSpeciesMinBreedingAge("RHESUS", "F"), 2.5)
})

test_that("getSpeciesMinBreedingAge returns the issue #73 species values", {
  ## a spread of species, including the fractional minima
  expect_identical(getSpeciesMinBreedingAge("CYNOMOLGUS", "F"), 2.5)
  expect_identical(getSpeciesMinBreedingAge("JAPANESE MACAQUE", "M"), 5)
  expect_identical(getSpeciesMinBreedingAge("JAPANESE MACAQUE", "F"), 4)
  expect_identical(getSpeciesMinBreedingAge("BABOON", "M"), 6)
  expect_identical(getSpeciesMinBreedingAge("BABOON", "F"), 4)
  expect_identical(getSpeciesMinBreedingAge("SQUIRREL MONKEY", "M"), 3.5)
  expect_identical(getSpeciesMinBreedingAge("SQUIRREL MONKEY", "F"), 2.5)
  expect_identical(getSpeciesMinBreedingAge("COMMON MARMOSET", "M"), 1)
  expect_identical(getSpeciesMinBreedingAge("COMMON MARMOSET", "F"), 1)
  expect_identical(getSpeciesMinBreedingAge("COTTON-TOP TAMARIN", "F"), 1.5)
  expect_identical(getSpeciesMinBreedingAge("OWL MONKEY", "M"), 2)
  expect_identical(getSpeciesMinBreedingAge("CAPUCHIN", "M"), 6)
  expect_identical(getSpeciesMinBreedingAge("CHIMPANZEE", "M"), 12)
  expect_identical(getSpeciesMinBreedingAge("CHIMPANZEE", "F"), 8)
  expect_identical(getSpeciesMinBreedingAge("BONOBO", "F"), 8)
})

test_that("getSpeciesMinBreedingAge is case- and whitespace-insensitive", {
  expect_identical(getSpeciesMinBreedingAge("rhesus", "M"), 4)
  expect_identical(getSpeciesMinBreedingAge("  Rhesus  ", "F"), 2.5)
  ## sex is matched case/whitespace-insensitively too
  expect_identical(getSpeciesMinBreedingAge("RHESUS", " m "), 4)
  expect_identical(getSpeciesMinBreedingAge("RHESUS", "f"), 2.5)
  ## a multi-word key matches case/whitespace-insensitively
  expect_identical(getSpeciesMinBreedingAge("japanese macaque", "m"), 5)
})

test_that("getSpeciesMinBreedingAge falls back to 2 for unknown species", {
  expect_identical(getSpeciesMinBreedingAge("UNICORN", "F"), 2)
  expect_identical(getSpeciesMinBreedingAge("TYRANNOSAURUS", "M"), 2)
})

test_that("getSpeciesMinBreedingAge falls back to 2 for NA / empty species", {
  expect_identical(getSpeciesMinBreedingAge(NA_character_, "M"), 2)
  expect_identical(getSpeciesMinBreedingAge("", "F"), 2)
})

test_that("getSpeciesMinBreedingAge falls back to 2 for a sex that is not M/F", {
  ## a known species but an unusable sex still yields the default
  expect_identical(getSpeciesMinBreedingAge("RHESUS", "U"), 2)
  expect_identical(getSpeciesMinBreedingAge("RHESUS", NA_character_), 2)
})

test_that("getSpeciesMinBreedingAge is vectorized and preserves length/order", {
  out <- getSpeciesMinBreedingAge(
    c("RHESUS", "RHESUS", "UNICORN", NA_character_),
    c("M", "F", "M", "F")
  )
  expect_identical(out, c(4, 2.5, 2, 2))
  expect_length(out, 4L)
})

test_that("getSpeciesMinBreedingAge recycles a scalar sex across species", {
  out <- getSpeciesMinBreedingAge(c("RHESUS", "UNICORN"), "M")
  expect_identical(out, c(4, 2))
})

test_that("getSpeciesMinBreedingAge uses an injected breedingTable", {
  tbl <- data.frame(
    species = c("RHESUS", "TESTSP"),
    minMaleBreedingAge = c(4, 7),
    minFemaleBreedingAge = c(3, 6),
    stringsAsFactors = FALSE
  )
  expect_identical(
    getSpeciesMinBreedingAge("TESTSP", "M", breedingTable = tbl), 7
  )
  expect_identical(
    getSpeciesMinBreedingAge("testsp", "F", breedingTable = tbl), 6
  )
  expect_identical(
    getSpeciesMinBreedingAge("RHESUS", "M", breedingTable = tbl), 4
  )
  ## a species absent from the injected table falls back to the default
  expect_identical(
    getSpeciesMinBreedingAge("OTHER", "M", breedingTable = tbl), 2
  )
})

test_that("getSpeciesMinBreedingAge honors a custom default", {
  tbl <- data.frame(
    species = "TESTSP",
    minMaleBreedingAge = 7,
    minFemaleBreedingAge = 6,
    stringsAsFactors = FALSE
  )
  expect_identical(
    getSpeciesMinBreedingAge("OTHER", "M", breedingTable = tbl, default = 5),
    5
  )
})

test_that("getSpeciesMinBreedingAge returns numeric(0) for empty input", {
  expect_identical(
    getSpeciesMinBreedingAge(character(0L), character(0L)), numeric(0L)
  )
})

test_that("getSpeciesMinBreedingAge returns a numeric vector", {
  expect_type(getSpeciesMinBreedingAge("RHESUS", "M"), "double")
  expect_type(
    getSpeciesMinBreedingAge(c("RHESUS", "UNICORN"), c("M", "F")), "double"
  )
})

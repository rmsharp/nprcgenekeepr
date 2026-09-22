## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# Issue #168 Slice 1: integrity guard for the hand-authored ancestry-bearing
# example pedigree (plan section 5 Slice 1; Dragon 6 -- the shipped data
# objects examplePedigree/qcPed are never edited, so ancestry-rule tests get
# their own fixture, which Slice 2 uses as its enforcement test vehicle). The
# fixture's free-form ancestry strings must survive qcStudbook()'s
# convertAncestry() standardization covering ALL six levels -- including the
# two easy-to-lose ones: a blank (NA) -> UNKNOWN and an unrecognized string
# ("mauritius") -> OTHER (convertAncestry() is not idempotent; plan section
# 1.3). NOTE (declared at RED): the two pure-integrity blocks below test
# fixture DATA, not the new functions, so they pass at RED by design; the
# cross-fixture block at the end fails until readAncestryRules()/
# checkAncestryRules() exist.

exampleAncestryPedPath <- function() {
  system.file("extdata", "examples", "example_ancestry_pedigree.csv",
              package = "nprcgenekeepr")
}

readExampleAncestryPed <- function() {
  read.csv(exampleAncestryPedPath(), stringsAsFactors = FALSE,
           na.strings = c("", "NA"))
}

test_that("the example ancestry pedigree ships and QCs cleanly", {
  f <- exampleAncestryPedPath()
  expect_true(nzchar(f))
  raw <- readExampleAncestryPed()
  expect_true(all(c("id", "sire", "dam", "sex", "birth", "ancestry") %in%
                    names(raw)))
  ped <- qcStudbook(raw, minParentAge = 2, reportChanges = FALSE,
                    reportErrors = FALSE)
  expect_true("ancestry" %in% names(ped))
  expect_identical(nrow(ped), 10L)
})

test_that("post-QC ancestry covers all six standardized levels", {
  ped <- qcStudbook(readExampleAncestryPed(), minParentAge = 2,
                    reportChanges = FALSE, reportErrors = FALSE)
  counts <- table(ped$ancestry)
  levelsAll <- c("CHINESE", "INDIAN", "HYBRID", "JAPANESE", "OTHER",
                 "UNKNOWN")
  expect_setequal(names(counts), levelsAll)
  # >= 1 of each is the real coverage claim (table() lists empty factor
  # levels too, so setequal alone would pass vacuously).
  expect_true(all(counts[levelsAll] >= 1L))
})

test_that("every level the example rules file names exists in the example pedigree", {
  rules <- checkAncestryRules(readAncestryRules(system.file(
    "extdata", "examples", "example_ancestry_rules.csv",
    package = "nprcgenekeepr"
  )))
  ped <- qcStudbook(readExampleAncestryPed(), minParentAge = 2,
                    reportChanges = FALSE, reportErrors = FALSE)
  named <- unique(c(rules$ancestry1, rules$ancestry2))
  present <- as.character(unique(ped$ancestry))
  expect_true(all(named %in% present))
})

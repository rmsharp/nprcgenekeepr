## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (issue #130 Slice 1): checkMarkerGenotypeFile() validates the D1
## long-format multi-locus marker genotype table (id, locus, allele1,
## allele2) -- a new, sibling schema to the existing single-locus
## checkGenotypeFile()/addGenotype() path, which this slice does not touch.
##
## Fixture: a hand-built, Mendelian-consistent parent (P) / offspring (C)
## pair plus one unrelated founder (U), across 10 biallelic loci. Exact
## KING-robust kinship values for this fixture are derived and hand-verified
## in test_markerKinship.R; this file exercises validation only.

markerGenotype <- data.frame(
  id = c(rep("P", 10L), rep("C", 10L), rep("U", 10L)),
  locus = rep(paste0("L", 1L:10L), 3L),
  allele1 = c(
    "A", "A", "A", "B", "A", "A", "B", "A", "A", "A",
    "A", "A", "B", "A", "A", "A", "B", "A", "A", "A",
    "A", "B", "A", "A", "A", "A", "A", "B", "A", "B"
  ),
  allele2 = c(
    "A", "B", "B", "B", "A", "B", "B", "B", "A", "B",
    "B", "A", "B", "B", "A", "B", "B", "B", "B", "A",
    "B", "B", "A", "B", "B", "A", "B", "B", "B", "B"
  ),
  stringsAsFactors = FALSE
)

test_that("checkMarkerGenotypeFile allows correctly-formed long-format table", {
  checked <- checkMarkerGenotypeFile(markerGenotype)
  expect_s3_class(checked, "data.frame")
  expect_identical(names(checked), c("id", "locus", "allele1", "allele2"))
  expect_identical(nrow(checked), 30L)
})

test_that("checkMarkerGenotypeFile requires exactly four columns", {
  expect_error(
    checkMarkerGenotypeFile(markerGenotype[, c("id", "locus", "allele1")]),
    "Marker genotype file must have exactly four columns",
    fixed = TRUE
  )
})

test_that("checkMarkerGenotypeFile requires 'id' as the first column", {
  badGenotype <- markerGenotype
  names(badGenotype) <- c("animal", "locus", "allele1", "allele2")
  expect_error(
    checkMarkerGenotypeFile(badGenotype),
    "Marker genotype file must have 'id' as the first column.",
    fixed = TRUE
  )
})

test_that("checkMarkerGenotypeFile rejects a locus with more than two alleles (P1)", {
  ## A third distinct allele ("C") at L1 makes that locus non-biallelic --
  ## the exact constraint Dragon P1's research resolved: the KING-robust
  ## formula is structurally biallelic-only, so this must fail loudly, not
  ## silently produce a wrong kinship estimate.
  triallelic <- rbind(
    markerGenotype,
    data.frame(id = "X", locus = "L1", allele1 = "C", allele2 = "C",
               stringsAsFactors = FALSE)
  )
  expect_error(
    checkMarkerGenotypeFile(triallelic),
    "L1",
    fixed = TRUE
  )
})

test_that("checkMarkerGenotypeFile rejects a duplicate id x locus row", {
  dupGenotype <- rbind(markerGenotype, markerGenotype[1L, ])
  expect_error(
    checkMarkerGenotypeFile(dupGenotype),
    "duplicate",
    ignore.case = TRUE
  )
})

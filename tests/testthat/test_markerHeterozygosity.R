## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (issue #130 Slice 2): markerObservedHeterozygosity() and
## markerExpectedHeterozygosity() compute the heterozygosity diagnostic
## (observed vs. expected) directly from marker genotypes, reusing the same
## wide id x locus genotypeMatrix buildMarkerGenotypeMatrix() already
## produces for markerKinship() -- no new data shape.
##
## Observed heterozygosity (Ho), per animal: the fraction of that animal's
## genotyped (non-missing) loci at which it is heterozygous. A raw empirical
## proportion -- no bias-correction analog applies (Ho is not estimating a
## hidden population parameter the way He is).
##
## Expected heterozygosity (He), a.k.a. Nei's gene diversity, per locus:
##   He_L = 1 - sum(p_i^2)
## where p_i is the population frequency of allele i at locus L (computed
## from all non-missing genotype calls at that locus). Reported per locus,
## plus the unweighted mean across loci as a population-wide summary. This
## is the PLAIN/biased form -- matching design decision D3 as ratified
## (docs/planning/issue130-marker-kinship-crosscenter-identity-plan.md),
## not the Nei & Roychoudhury (1974) small-sample-corrected (2n/(2n-1))
## variant, which this slice's Pre-RED scope decision explicitly deferred
## as a documented future enhancement, not silently dropped.
##
## Citation: Nei, M. (1973). Analysis of gene diversity in subdivided
## populations. PNAS, 70(12), 3321-3323 -- sourced and cross-verified at
## this slice's Pre-RED directly from the primary literature (via
## DeGiorgio, Jankovic & Rosenberg 2010, Genetics 186:1367-1387, which
## quotes and attributes the formula) and independently confirmed as a
## Hardy-Weinberg consequence in a UNESCO-EOLSS Population Genetics
## reference citing Hartl & Clark (1997) and Weir (1996). This slice's
## Pre-RED found the ratified plan's own D3/2G text ("the standard
## VCFtools/PLINK --het approach") is factually imprecise -- neither tool
## reports columns named Ho/He, both report O(HOM)/E(HOM)/F (an inbreeding
## coefficient) instead -- so the direct Nei (1973) citation is used here
## rather than propagating that imprecision into this function's own
## roxygen @references.
##
## Expected values below were derived with a standalone reference script
## (plain base-R arithmetic over allele lists, run independently of any
## implementation), so they are an independent oracle, not a copy of any
## planned implementation:
##   Ho: X = 0.75, Y = 1/3 (0.3333...), Z = 0.25
##   He by locus: L1 = 0.5, L2 = 5/18 (0.27778), L3 = 4/9 (0.44444),
##                L4 = 3/8 = 0.375
##   Mean He across loci: 115/288 (0.39931)

genotypeMatrix <- matrix(
  c(
    "A/A", "A/B", "A/B", "A/B",
    "A/B", "A/A", "B/B", NA_character_,
    "B/B", "A/A", "A/B", "A/A"
  ),
  nrow = 3L, byrow = TRUE,
  dimnames = list(c("X", "Y", "Z"), paste0("L", 1L:4L))
)

test_that("markerObservedHeterozygosity computes per-animal Ho, excluding an animal's own missing loci", {
  ho <- markerObservedHeterozygosity(genotypeMatrix)
  expect_true(is.numeric(ho))
  expect_identical(names(ho), c("X", "Y", "Z"))

  expect_equal(ho[["X"]], 0.75)
  ## Y is missing L4 entirely -- Y's denominator must be 3 (its own
  ## non-missing loci), not 4, so Ho_Y = 1/3, not 1/4.
  expect_equal(ho[["Y"]], 1 / 3)
  expect_equal(ho[["Z"]], 0.25)
})

test_that("markerObservedHeterozygosity returns 0 for a fully homozygous animal and NA for one with no genotyped loci", {
  mat <- matrix(
    c("A/A", "B/B",
      NA_character_, NA_character_),
    nrow = 2L, byrow = TRUE,
    dimnames = list(c("H", "M"), c("L1", "L2"))
  )
  ho <- markerObservedHeterozygosity(mat)
  expect_equal(ho[["H"]], 0)
  expect_true(is.na(ho[["M"]]))
})

test_that("markerExpectedHeterozygosity computes per-locus He from population allele frequencies", {
  he <- markerExpectedHeterozygosity(genotypeMatrix)
  expect_type(he, "list")
  expect_identical(sort(names(he)), c("meanHe", "perLocus"))

  expect_true(is.numeric(he$perLocus))
  expect_identical(names(he$perLocus), paste0("L", 1L:4L))
  expect_equal(he$perLocus[["L1"]], 0.5)
  expect_equal(he$perLocus[["L2"]], 5 / 18)
  expect_equal(he$perLocus[["L3"]], 4 / 9)
  ## L4: Y is missing, so only X and Z (4 allele copies) contribute.
  expect_equal(he$perLocus[["L4"]], 0.375)

  ## Population-wide summary: unweighted mean across loci.
  expect_equal(he$meanHe, 115 / 288)
})

test_that("markerExpectedHeterozygosity returns 0 for a monomorphic locus", {
  mat <- matrix(
    c("A/A", "A/A", "A/A"),
    nrow = 3L, byrow = TRUE,
    dimnames = list(c("A1", "A2", "A3"), "L1")
  )
  he <- markerExpectedHeterozygosity(mat)
  expect_equal(he$perLocus[["L1"]], 0)
  expect_equal(he$meanHe, 0)
})

## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (issue #130 Slice 1): markerKinship() estimates pairwise kinship
## directly from marker genotypes, independent of pedigree, via the
## "between-family" KING-robust estimator (Manichaikul, Mychaleckyj, Rich,
## Daly, Sale & Chen 2010, Bioinformatics 26(22):2867-2873, Equation 11) --
## the estimator KING, PLINK2, SNPRelate, and GENESIS all implement under
## the name "KING-robust" (confirmed by this slice's Pre-RED cross-check of
## the primary paper against independent software documentation):
##
##   phi_hat(i,j) = 0.5 + (2*N_AaAa - 4*N_AAaa - N_Aa(i) - N_Aa(j)) /
##                        (4 * min(N_Aa(i), N_Aa(j)))
##
## computed over loci genotyped in BOTH i and j, where N_AaAa = both
## heterozygous, N_AAaa = opposite homozygotes (IBS0), N_Aa(i)/N_Aa(j) =
## each individual's own heterozygous-locus count over that shared set.
##
## Input is the wide id x locus character matrix produced by
## buildMarkerGenotypeMatrix() (cell = sorted "allele1/allele2" string, or
## NA). This file constructs that matrix directly as a literal, independent
## of buildMarkerGenotypeMatrix()'s own (separately tested) correctness.
##
## Expected values below were derived with a standalone reference
## implementation of the formula above (not this package's code), so they
## are an independent oracle, not a copy of any planned implementation.

genotypeMatrix <- matrix(
  c(
    "A/A", "A/B", "A/B", "B/B", "A/A", "A/B", "B/B", "A/B", "A/A", "A/B",
    "A/B", "A/A", "B/B", "A/B", "A/A", "A/B", "B/B", "A/B", "A/B", "A/A",
    "A/B", "B/B", "A/A", "A/B", "A/B", "A/A", "A/B", "B/B", "A/B", "B/B"
  ),
  nrow = 3L, byrow = TRUE,
  dimnames = list(c("P", "C", "U"), paste0("L", 1L:10L))
)

test_that("markerKinship matches hand-verified values for a parent/offspring/unrelated trio", {
  kmat <- markerKinship(genotypeMatrix)
  expect_true(is.matrix(kmat))
  expect_identical(dim(kmat), c(3L, 3L))
  expect_identical(dimnames(kmat), list(c("P", "C", "U"), c("P", "C", "U")))

  ## Diagonal: self-kinship is always 0.5 by definition, not computed from
  ## the pairwise formula (which divides by zero when N_Aa(i) = 0).
  expect_equal(kmat["P", "P"], 0.5)
  expect_equal(kmat["C", "C"], 0.5)
  expect_equal(kmat["U", "U"], 0.5)

  ## Parent/offspring: clearly higher than either pair involving the
  ## unrelated founder.
  expect_equal(kmat["P", "C"], 0.2)
  expect_equal(kmat["C", "P"], 0.2)

  ## Unrelated founder vs. parent: exactly 0 for this fixture.
  expect_equal(kmat["P", "U"], 0.0)
  expect_equal(kmat["U", "P"], 0.0)

  ## Unrelated founder vs. offspring: negative for this fixture -- KING-robust
  ## is not bounded below by 0, and should not be clipped (per the Pre-RED
  ## research: a negative estimate is informative, not an error).
  expect_equal(kmat["C", "U"], -0.3)
  expect_equal(kmat["U", "C"], -0.3)

  ## The matrix must be exactly symmetric.
  expect_identical(kmat, t(kmat))
})

test_that("markerKinship restricts each pair to their shared non-missing loci", {
  ## A1 has no record at M4 at all (NA in the matrix); A2 is genotyped there.
  ## M4 must be excluded from A1-A2's counts entirely -- a naive
  ## implementation that does not check for NA before classifying a locus
  ## would silently miscount and fail this exact value.
  sparseMatrix <- matrix(
    c("A/A", "A/B", "B/B", NA_character_,
      "A/B", "A/B", "A/B", "A/B"),
    nrow = 2L, byrow = TRUE,
    dimnames = list(c("A1", "A2"), c("M1", "M2", "M3", "M4"))
  )
  kmat <- markerKinship(sparseMatrix)
  expect_equal(kmat["A1", "A2"], 0.0)
})

test_that("markerKinship returns NA with a warning when neither individual has a heterozygous shared locus", {
  ## Both individuals are homozygous at every locus (N_Aa = 0 for both), so
  ## the formula's denominator (4 * min(N_Aa(i), N_Aa(j))) is 0 -- undefined,
  ## not zero-kinship.
  homozygousMatrix <- matrix(
    c("A/A", "A/A",
      "A/A", "B/B"),
    nrow = 2L, byrow = TRUE,
    dimnames = list(c("H1", "H2"), c("M1", "M2"))
  )
  expect_warning(
    kmat <- markerKinship(homozygousMatrix),
    "heterozygous"
  )
  expect_true(is.na(kmat["H1", "H2"]))
})

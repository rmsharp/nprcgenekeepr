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

## ---------------------------------------------------------------------------
## RED (issue #152 Slice 2, D5): markerKinship()'s O(n^2*L) nested-pair loop
## is being rewritten as vectorized matrix algebra. Two new blocks below --
## a golden-master regression proof and a benchmark -- per this session's
## PRE-RED AskUserQuestion round (RED scoped to the benchmark only; the
## golden-master test is a characterization safety net that passes
## immediately, matching test_markerParentageExclusion.R's own
## "byte-identical after refactor" precedent, not a failing test itself).
## ---------------------------------------------------------------------------

test_that("markerKinship's output is byte-identical to its pre-D5-rewrite implementation", {
  ## Golden-master snapshot: captured via dput(x, control = c(..., "digits17"))
  ## from the real, CURRENT (still unrewritten) markerKinship() on this
  ## file's own P/C/U fixture, before any code changed this session
  ## (2026-08-11). "digits17" is load-bearing, not cosmetic -- this
  ## session's own Pre-RED found that a plain dput() prints just enough
  ## digits to round-trip to *some* double (e.g. "-0.3"), which is NOT
  ## necessarily the exact double markerKinship() actually returns
  ## (verified: the real value is -0.30000000000000004, one ULP off
  ## "-0.3"'s own nearest-double parse) -- an expect_identical() built from
  ## a plain dput() capture would have spuriously failed on a correct,
  ## unmodified implementation. If this test ever needs updating to pass,
  ## the D5 rewrite changed real behavior and is NOT behavior-preserving --
  ## stop and investigate rather than "fixing" this expected value.
  golden <- structure(
    c(0.5, 0.20000000000000001, 0, 0.20000000000000001,
      0.5, -0.30000000000000004, 0, -0.30000000000000004, 0.5),
    dim = c(3L, 3L),
    dimnames = list(c("P", "C", "U"), c("P", "C", "U"))
  )
  actual <- markerKinship(genotypeMatrix)
  expect_identical(actual, golden)
})

test_that("markerKinship completes well under its pre-D5-rewrite runtime on the committed sequence-scale fixture (issue #152 Slice 2 benchmark)", {
  ## No skip_if() guard: system.file() returns "" when the fixture doesn't
  ## exist, and read.csv("") errors -- matches
  ## test_checkSequenceGenotypeFile.R's own committed-fixture test pattern.
  ## Threshold (0.10s) is deliberately tighter than the pre-rewrite
  ## implementation's measured runtime on this exact fixture (~0.12-0.13s
  ## steady-state after JIT warm-up, ~0.24-0.26s cold -- this session's own
  ## PRE-RED measurement) -- this test is expected to FAIL until the D5
  ## vectorized rewrite lands (precedent-setting: no system.time()-based
  ## benchmark test exists anywhere in this package before this slice). An
  ## untimed warm-up call precedes 3 timed reps, and the MEDIAN of those 3
  ## (not a single call) is compared against the threshold -- this
  ## session's own PRE-RED found a single warm timed call still varies
  ## between ~0.07s and ~0.09s run-to-run (system noise, not JIT), enough
  ## to flake against a tight single-call threshold; the median is far more
  ## stable (this session measured 0.071-0.073s across repeated median-of-3
  ## checks) while the rewrite still needs to be genuinely faster than the
  ## pre-rewrite implementation to pass, not just "usually" faster.
  ## skip_on_ci() (found S540, 2026-08-12): GitHub Actions' shared ubuntu/
  ## windows runners consistently measure 0.133-0.190s on this exact
  ## fixture -- 30-90% over the 0.10s threshold, on every push since this
  ## test was added (S526), a deterministic hardware-speed mismatch, not
  ## occasional flakiness. macOS CI matches local timing and passes. Kept as
  ## a real local/interactive regression guard; not CI-portable as an
  ## absolute wall-clock assertion. See CHANGELOG.md.
  testthat::skip_on_ci()
  path <- system.file(
    "extdata", "examples", "example_sequence_genotypes.csv",
    package = "nprcgenekeepr"
  )
  genotype <- read.csv(path, stringsAsFactors = FALSE)
  checked <- checkSequenceGenotypeFile(genotype)
  mat <- buildMarkerGenotypeMatrix(checked)
  expect_identical(dim(mat), c(50L, 1000L))

  invisible(markerKinship(mat)) # warm-up, untimed
  kmat <- NULL # so <<- below binds here, not in the global environment
  timings <- vapply(seq_len(3L), function(i) {
    system.time(kmat <<- markerKinship(mat))[["elapsed"]]
  }, numeric(1L))
  expect_identical(dim(kmat), c(50L, 50L))
  expect_true(all(diag(kmat) == 0.5))
  expect_lt(stats::median(timings), 0.10)
})

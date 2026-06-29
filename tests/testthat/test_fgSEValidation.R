## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# Issue #82 Slice 2: the "validate before expose" gate for calcFGSE(). Before the
# founder-genome-equivalent sampling SE is surfaced (Slice 3), it must be shown to
# be CALIBRATED -- the reported SE must match the run-to-run spread of FG, cover a
# high-iteration reference FG ~95% of the time, shrink as 1/sqrt(K), never emit a
# finite SE for a collapsed FG, and agree with an independent column bootstrap --
# on a REAL deep/bottlenecked pedigree, not just the well-retained lacy1989.
#
# The slow B>=300-seed study runs once in data-raw/fgSEValidation.R and its numbers
# are recorded in vignettes/articles/fg-se-validation.qmd. These unit tests instead
# pin the HARNESS the study is built from: the pure scorer functions (agreement
# ratio, coverage, 1/sqrt(K) scaling, diagonal vs full SE, column bootstrap), the
# per-check verdict logic against the ratified bands, and the orchestrator's shape
# and determinism. They run on tiny synthetic inputs with hand-computed answers so
# they are fast, isolated, and deterministic (the TDD contract), while the bands
# they encode are exactly the ones the recorded study is judged against.
#
# The harness functions live in tests/testthat/helper-fgSEValidation.R (GREEN);
# they do not exist yet, so every assertion below fails with "could not find
# function" -- the correct RED reason.

# Slice 1's fixtures/oracle (fgRetentionMatrix, makeFgPed, makeFgAlleles) are
# auto-loaded under test_dir/test_local but not test_file -- source on demand.
if (!exists("fgRetentionMatrix")) {
  source(testthat::test_path("helper-fgSEFixtures.R"))
}

# --------------------------------------------------------------------------
# (a) Agreement ratio = mean(SE_b) / sd(FG_b). This is the core calibration
# statistic: across B independent seeds the average reported SE should equal the
# Monte Carlo spread of the FG point estimates. A value near 1 means calibrated.
# Pinned to a hand-computed answer; an implementation that used var() instead of
# sd(), or divided the other way, would miss it.
# --------------------------------------------------------------------------
test_that("fgSEAgreementRatio is mean(SE) over sd(FG)", {
  fg <- c(2.0, 2.2, 1.8, 2.4, 1.6) # mean 2.0, var 0.1, sd sqrt(0.1)
  se <- rep(0.1, 5L)
  expect_equal(fgSEAgreementRatio(fg, se), 0.1 / sqrt(0.1))
  expect_equal(fgSEAgreementRatio(fg, rep(0.2, 5L)), 0.2 / sqrt(0.1))
  # definitional cross-check against an inline independent recompute
  expect_equal(fgSEAgreementRatio(fg, se), mean(se) / stats::sd(fg))
})

# --------------------------------------------------------------------------
# (b) Coverage = fraction of FG_b +/- z*SE_b intervals that contain the reference
# FG. The ratified band is [0.93, 0.97] around the nominal 0.95 for z = 1.96. The
# boundary must be inclusive (<=), so an interval whose half-width exactly reaches
# the reference counts as covering.
# --------------------------------------------------------------------------
test_that("fgSECoverage counts the fraction of intervals covering the reference", {
  fg <- c(10.5, 11.5, 8.5, 12.5)
  se <- rep(1.0, 4L)
  # z = 1.96 -> half-width 1.96: |0.5|,|1.5|,|1.5| in; |2.5| out -> 3/4
  expect_equal(fgSECoverage(fg, se, refFG = 10, z = 1.96), 0.75)
  # z = 1 -> half-width 1: only |0.5| in -> 1/4
  expect_equal(fgSECoverage(fg, se, refFG = 10, z = 1), 0.25)
  # inclusive boundary: a point exactly z*se away covers (proves <=, not <), a
  # point past it does not. Exactly-representable values avoid floating-point
  # fuzz at the boundary (11.96 - 10 is not exactly 1.96).
  expect_equal(fgSECoverage(11.5, 1.0, refFG = 10, z = 1.5), 1)
  expect_equal(fgSECoverage(11.6, 1.0, refFG = 10, z = 1.5), 0)
})

# --------------------------------------------------------------------------
# (c) Scaling ratio = se(coarse) / se(fine). Quadrupling the iteration count must
# halve the SE (1/sqrt(K)); 4x iterations -> ratio ~ 2. The ratified band is
# [1.8, 2.2]. The helper is the bare ratio so both the empirical-sd scaling and
# the delta-SE scaling reuse it.
# --------------------------------------------------------------------------
test_that("fgSEScalingRatio is the coarse-over-fine SE ratio", {
  expect_equal(fgSEScalingRatio(0.04, 0.02), 2)
  expect_equal(fgSEScalingRatio(0.066, 0.033), 2)
})

# --------------------------------------------------------------------------
# (d) Diagonal vs full SE on a founder-by-iteration retention matrix. The full
# (influence) SE folds in the within-iteration founder covariance; the diagonal
# SE drops the off-diagonals. When the founders' retention patterns are
# uncorrelated the two MUST agree; when they are correlated they must differ
# (proving the diagonal form genuinely ignores the off-diagonals -- the Dragon
# D-4 approximation whose cost Slice 2 measures on the real pedigree).
# --------------------------------------------------------------------------
test_that("diagonal and full SE agree iff founders are uncorrelated", {
  # Orthogonal centered rows: cov(A, B) = 0 exactly.
  #   A = (1,1,0,0) centered (.5,.5,-.5,-.5); B = (1,0,1,0) centered (.5,-.5,.5,-.5)
  #   p = r = 0.5 -> FG = 1, g = (1,1); var = (1)/3 each; SE = sqrt(((1/3)*2)/4)
  clean <- matrix(c(1, 1, 0, 0, 1, 0, 1, 0), nrow = 2L, byrow = TRUE)
  rownames(clean) <- c("A", "B")
  p <- c(A = 0.5, B = 0.5)
  expect_equal(fgSEDiagFromMatrix(clean, p), sqrt(1 / 6))
  expect_equal(fgSEFullFromMatrix(clean, p), sqrt(1 / 6))
  expect_equal(fgSEFullFromMatrix(clean, p), fgSEDiagFromMatrix(clean, p))

  # Correlated rows: A = (1,1,1,0), B = (1,1,0,0) -> positive cov(A, B), so the
  # full SE exceeds the diagonal SE by a material amount.
  corr <- matrix(c(1, 1, 1, 0, 1, 1, 0, 0), nrow = 2L, byrow = TRUE)
  rownames(corr) <- c("A", "B")
  seFull <- fgSEFullFromMatrix(corr, p)
  seDiag <- fgSEDiagFromMatrix(corr, p)
  expect_gt(seFull, seDiag)
  expect_gt(abs(seFull - seDiag), 0.05)
})

# --------------------------------------------------------------------------
# (e) The harness measures the SHIPPED estimator. fgSEFullFromMatrix(R, p) must
# equal calcFGSE(ped, alleles) on lacy1989 to machine precision -- otherwise the
# study would validate a re-implementation that could silently diverge from what
# the package reports. Also pins the Slice 1 golden SE on the bundled alleles.
# --------------------------------------------------------------------------
test_that("fgSEFullFromMatrix reproduces calcFGSE on lacy1989", {
  rmat <- fgRetentionMatrix(lacy1989Ped, lacy1989PedAlleles)
  p <- calcFounderContributions(lacy1989Ped, "calcFG")$p
  expect_equal(
    calcFGSE(lacy1989Ped, lacy1989PedAlleles), 0.00621305577,
    tolerance = 1e-7
  )
  expect_equal(
    fgSEFullFromMatrix(rmat, p),
    calcFGSE(lacy1989Ped, lacy1989PedAlleles)
  )
})

# --------------------------------------------------------------------------
# (f) Column bootstrap: resample the K iteration columns of R with replacement,
# recompute FG per resample (dropping any non-finite), and take the sd of the
# finite replicates. It is the mandatory independent cross-check on the delta SE
# (a large disagreement flags a thin-retention founder where the linearization
# fails). Must be deterministic under a fixed seed, report a zero dropped fraction
# on a healthy fixture, and land within 15% of the delta SE there.
# --------------------------------------------------------------------------
test_that("fgSEBootstrapFromMatrix is deterministic and tracks the delta SE", {
  ped <- makeFgPed()
  al <- makeFgAlleles(ped, k = 600L)
  rmat <- fgRetentionMatrix(ped, al)
  p <- calcFounderContributions(ped, "calcFG")$p
  delta <- fgSEFullFromMatrix(rmat, p)

  b1 <- fgSEBootstrapFromMatrix(rmat, p, B = 2000L, seed = 42L)
  b2 <- fgSEBootstrapFromMatrix(rmat, p, B = 2000L, seed = 42L)
  expect_identical(b1$se, b2$se) # fixed seed -> byte-identical
  expect_equal(b1$dropped, 0) # healthy fixture: no non-finite resample
  expect_true(is.finite(b1$se) && b1$se > 0)

  ratio <- b1$se / delta
  expect_gt(ratio, 0.85)
  expect_lt(ratio, 1.15)
})

# --------------------------------------------------------------------------
# (g) Verdict logic. fgSEVerdict() maps a study SUMMARY to a per-check PASS/FAIL
# and an overall verdict, against the bands ratified in plan Section 5.1 / 9:
# agreement [0.92, 1.08], coverage [0.93, 0.97], scaling [1.8, 2.2] (BOTH the
# empirical and delta scalings), degeneracy fraction exactly 0, bootstrap-vs-delta
# ratio within 15% ([0.85, 1.15]). Any single failed check fails the whole gate.
# --------------------------------------------------------------------------
test_that("fgSEVerdict passes an in-band summary and fails any out-of-band check", {
  good <- list(
    agreementRatio = 1.00, coverage = 0.95, scalingEmp = 1.95,
    scalingDelta = 2.02, degeneracyFraction = 0, bootstrapRatio = 1.02
  )
  v <- fgSEVerdict(good)
  expect_true(v$agreement)
  expect_true(v$coverage)
  expect_true(v$scaling)
  expect_true(v$degeneracy)
  expect_true(v$bootstrap)
  expect_true(v$overall)

  expect_false(fgSEVerdict(modifyList(good, list(agreementRatio = 1.30)))$agreement)
  expect_false(fgSEVerdict(modifyList(good, list(coverage = 0.80)))$coverage)
  expect_false(fgSEVerdict(modifyList(good, list(scalingDelta = 1.50)))$scaling)
  expect_false(fgSEVerdict(modifyList(good, list(degeneracyFraction = 0.01)))$degeneracy)
  expect_false(fgSEVerdict(modifyList(good, list(bootstrapRatio = 1.30)))$bootstrap)
  # any single failed check sinks the overall verdict
  expect_false(fgSEVerdict(modifyList(good, list(coverage = 0.80)))$overall)
})

# --------------------------------------------------------------------------
# (h) Orchestrator shape + determinism. fgSEValidate() runs the seeded replicate
# study on a pedigree and returns the per-seed (FG, SE) table, the computed
# summary, and the verdict. Under a fixed seed list it is byte-identical run to
# run (the gene drop is the only RNG and each seed pins it). The unit test asserts
# WIRING and determinism on lacy1989 at a tiny budget -- it does not assert a PASS
# verdict (the real bands are exercised by the recorded B>=300 study, not here).
# --------------------------------------------------------------------------
test_that("fgSEValidate returns a well-formed, deterministic result", {
  seeds <- 1:15
  res <- fgSEValidate(lacy1989Ped, seeds = seeds, k = 150L,
                      refK = 600L, bootstrapB = 500L)

  expect_type(res, "list")
  expect_true(is.data.frame(res$replicates))
  expect_named(res$replicates, c("seed", "FG", "SE", "degenerate"))
  expect_equal(nrow(res$replicates), length(seeds))
  expect_true(is.numeric(res$replicates$FG))
  expect_true(is.numeric(res$replicates$SE))
  expect_true(is.numeric(res$summary$agreementRatio))
  expect_true(is.numeric(res$summary$coverage))
  expect_true(is.list(res$verdict))
  expect_true(is.logical(res$verdict$overall))

  res2 <- fgSEValidate(lacy1989Ped, seeds = seeds, k = 150L,
                       refK = 600L, bootstrapB = 500L)
  expect_equal(res$replicates, res2$replicates)
  expect_equal(res$summary, res2$summary)
})

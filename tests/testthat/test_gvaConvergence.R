## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# Issue #2 Slice 2: gvaConvergence() is a diagnostic that answers the issue's
# literal ask -- "how many gene-drop iterations does THIS pedigree need?". Genome
# uniqueness (gu) is the only Monte Carlo output that carries sampling noise, so
# the needed iteration count is pedigree-dependent. gvaConvergence() runs ONE
# gene drop at nMax, recomputes gu on nested column prefixes (the i.i.d. columns
# make this exact and cheap -- one calcA() call, see calcGU/calcA), and for each
# candidate iteration count N splits the columns into two disjoint N-halves,
# ranks each half through the real orderReport() pipeline, and measures whether
# the two independent half-runs agree on the SELECTION ORDER (the ratified D1
# definition of "reproducible"): top-k set overlap AND a Kendall rank-agreement
# (tau-b). It reports the metric-vs-N curve and the smallest N at which BOTH
# criteria hold (the recommended iteration count).
#
# THE FIXTURE (Dragon #2 / Finding 4): no bundled pedigree can validate this.
# qcPed / pedWithGenotype / rhesusPedigree have ZERO rankable gu signal (after
# the issue #76 de-inflation every animal is gu = 0), and examplePedigree's
# gu-bearing animals are structurally fixed (order stable at N = 5). A test on
# bundled data would be tautological. makeConvergenceFixture() therefore builds a
# deterministic half-sib web in which founders (the private-allele sources) are
# EXCLUDED from the proband population, so their gene-drop alleles among probands
# are carried only by descendants. A descendant who is intermittently the SOLE
# proband carrier of a rare founder allele gets rankable MID-RANGE gu (and, having
# known parents, is NOT zeroed by issue #76). Overlapping sire/dam windows give the
# probands distinct-but-close true gu straddling the gu = 10 highGu cutoff, so the
# gene-drop estimate randomly crosses the cutoff at low N (selection order churns)
# and settles as N grows (order converges). This was found by a parameter search
# and re-validated firsthand: at seed 11 the order is unstable at N = 25
# (top-20 overlap ~0.75) and converges by N ~ 800, with a monotone curve -- while
# qcPed is reproducible at the grid floor. The RED tests assert ROBUST properties
# (fixture needs finitely MANY MORE iterations than qcPed; small-N instability;
# determinism), never a brittle exact recommended-N, which varies by seed.

# A deterministic dense-mid-range pedigree: 14 founder sires, each siring a
# contiguous, wrapping window of 5 founder dams (one offspring per sire-dam pair)
# over 15 founder dams. Windows overlap (start advances by 4), so dam fan-sizes
# vary (4 or 5) -> probands get distinct mean-kinship z-scores AND founder-allele
# dilution that places true gu just around the 10% cutoff. Founders are excluded
# from `pop`; the 70 offspring are the probands. The pedigree is identical for
# every seed (only the gene drop consumes the seed), so a fixed seed gives a
# byte-identical convergence curve. IDs are unique and contain no period.
makeConvergenceFixture <- function() {
  w <- rep(5L, 14L) # sire window widths (sire fan sizes)
  b <- 15L # number of founder dams
  a <- length(w)
  sids <- sprintf("S%03d", seq_len(a))
  dids <- sprintf("D%03d", seq_len(b))
  id <- c(sids, dids)
  sire <- rep(NA_character_, a + b)
  dam <- rep(NA_character_, a + b)
  sex <- c(rep("M", a), rep("F", b))
  off <- character(0L)
  ocount <- 0L
  start <- 1L
  for (i in seq_len(a)) {
    for (j in seq_len(w[i])) {
      dj <- ((start + j - 2L) %% b) + 1L
      ocount <- ocount + 1L
      o <- sprintf("O%04d", ocount)
      id <- c(id, o)
      sire <- c(sire, sids[i])
      dam <- c(dam, dids[dj])
      sex <- c(sex, if (ocount %% 2L == 0L) "F" else "M")
      off <- c(off, o)
    }
    start <- start + max(1L, w[i] - 1L) # overlap windows so dam fans vary
  }
  ped <- data.frame(
    id = id, sire = sire, dam = dam, sex = sex,
    stringsAsFactors = FALSE
  )
  ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
  list(ped = ped, pop = off)
}

# --------------------------------------------------------------------------
# Contract / shape: gvaConvergence() returns an nprcgenekeeprGVConv object with
# a convergence-curve data.frame, a recommended iteration count, a converged
# flag, the criteria used, and the rankable / Undetermined diagnostics.
# --------------------------------------------------------------------------
test_that("gvaConvergence returns a well-formed convergence object", {
  fx <- makeConvergenceFixture()
  res <- gvaConvergence(fx$ped, pop = fx$pop, nMax = 3000L, seed = 11L)

  expect_s3_class(res, "nprcgenekeeprGVConv")
  expect_true(is.data.frame(res$convergence))
  expect_named(
    res$convergence, c("iterations", "topOverlap", "rankAgreement")
  )
  expect_true(nrow(res$convergence) >= 3L)
  expect_true(is.integer(res$convergence$iterations))
  # half-split at N uses 2N columns, so every assessed N satisfies 2N <= nMax
  expect_true(all(2L * res$convergence$iterations <= 3000L))

  # topOverlap is a set-overlap fraction in [0, 1]; rankAgreement is a Kendall
  # correlation in [-1, 1]
  expect_true(all(res$convergence$topOverlap >= 0 &
    res$convergence$topOverlap <= 1))
  expect_true(all(res$convergence$rankAgreement >= -1 &
    res$convergence$rankAgreement <= 1))

  expect_true(is.na(res$recommendedIter) || is.numeric(res$recommendedIter))
  expect_true(is.logical(res$converged))
  expect_named(res$criteria, c("k", "oMin", "rhoMin"))
  expect_true(is.numeric(res$nRankable))
  expect_true(is.numeric(res$nUndetermined))
})

# --------------------------------------------------------------------------
# Determinism: a fixed seed pins the gene drop, so the whole convergence curve
# and the recommended iteration count are byte-identical run to run. Tests must
# be deterministic (TDD contract); the diagnostic must not be flaky.
# --------------------------------------------------------------------------
test_that("gvaConvergence is deterministic under a fixed seed", {
  fx <- makeConvergenceFixture()
  a <- gvaConvergence(fx$ped, pop = fx$pop, nMax = 3000L, seed = 11L)
  b <- gvaConvergence(fx$ped, pop = fx$pop, nMax = 3000L, seed = 11L)
  expect_equal(a$convergence, b$convergence)
  expect_identical(a$recommendedIter, b$recommendedIter)
})

# --------------------------------------------------------------------------
# Discrimination (the anti-tautology guarantee, Finding 4): on the dense fixture
# the selection order is genuinely iteration-dependent -- unstable at a small N
# and converging only after many more iterations -- so gvaConvergence recommends
# a FINITE iteration count strictly greater than it does on qcPed, whose rankable
# order is deterministic mean-kinship (no rankable gu signal) and is therefore
# reproducible at the grid floor. A diagnostic that recommended the same tiny N
# for both would be useless; this is the test bundled data cannot exercise.
# --------------------------------------------------------------------------
test_that("gvaConvergence recommends more iterations for the hard pedigree than for qcPed", {
  fx <- makeConvergenceFixture()
  hard <- gvaConvergence(fx$ped, pop = fx$pop, nMax = 3000L, seed = 11L)
  easy <- gvaConvergence(nprcgenekeepr::qcPed, nMax = 3000L, seed = 11L)

  # qcPed: every half-split agrees perfectly at every N (deterministic order)
  expect_true(all(easy$convergence$topOverlap == 1))
  expect_true(all(easy$convergence$rankAgreement == 1))
  expect_true(easy$converged)
  # ... so qcPed is reproducible at the smallest assessed iteration count
  expect_identical(
    easy$recommendedIter, min(easy$convergence$iterations)
  )

  # the hard fixture: order is unstable at the smallest N (below the overlap
  # criterion) but DOES converge -- at a finite count well above qcPed's floor
  expect_lt(hard$convergence$topOverlap[1L], hard$criteria$oMin)
  expect_true(hard$converged)
  expect_false(is.na(hard$recommendedIter))
  expect_gt(hard$recommendedIter, easy$recommendedIter)
})

# --------------------------------------------------------------------------
# Recommendation logic: "reproducible at N" requires BOTH primary D1 criteria --
# top-k overlap >= oMin AND Kendall rank-agreement >= rhoMin. recommendedIter is
# the SMALLEST assessed N meeting both; every smaller N must fail at least one.
# --------------------------------------------------------------------------
test_that("recommendedIter is the smallest iteration count meeting both criteria", {
  fx <- makeConvergenceFixture()
  res <- gvaConvergence(fx$ped, pop = fx$pop, nMax = 3000L, seed = 11L)
  skip_if(is.na(res$recommendedIter))

  cv <- res$convergence
  bothHold <- cv$topOverlap >= res$criteria$oMin &
    cv$rankAgreement >= res$criteria$rhoMin

  recRow <- which(cv$iterations == res$recommendedIter)
  expect_length(recRow, 1L)
  # the recommended row meets both criteria ...
  expect_true(bothHold[recRow])
  # ... and it is the FIRST such row (every earlier N fails at least one)
  expect_identical(recRow, which(bothHold)[1L])
  if (recRow > 1L) {
    expect_false(any(bothHold[seq_len(recRow - 1L)]))
  }
})

# --------------------------------------------------------------------------
# Issue #76 exclusion: the de-inflated gu = 0 "Undetermined" set (both parents
# unknown, no recorded origin) is a policy constant with rank NA -- it is
# excluded from the ranked selection order the metric is computed on, and its
# count is reported separately (2C). On qcPed that set is the 124 both-unknown
# founders, leaving 156 rankable animals (matches test_reportGV.R).
# --------------------------------------------------------------------------
test_that("gvaConvergence excludes the issue #76 Undetermined set and reports its count", {
  res <- gvaConvergence(nprcgenekeepr::qcPed, nMax = 3000L, seed = 11L)
  expect_identical(as.integer(res$nUndetermined), 124L)
  expect_identical(
    as.integer(res$nRankable), nrow(nprcgenekeepr::qcPed) - 124L
  )
})

# --------------------------------------------------------------------------
# Convergence shape: more iterations cannot hurt agreement on balance -- both
# metrics are at least as high at the largest assessed N as at the smallest
# (the validated curve is monotone non-decreasing). This is the "higher
# iterations -> smaller variation in the estimates" relationship from issue #2.
# --------------------------------------------------------------------------
test_that("gvaConvergence agreement improves from the smallest to the largest iteration count", {
  fx <- makeConvergenceFixture()
  cv <- gvaConvergence(fx$ped, pop = fx$pop, nMax = 3000L, seed = 11L)$convergence
  n <- nrow(cv)
  expect_gte(cv$topOverlap[n], cv$topOverlap[1L])
  expect_gte(cv$rankAgreement[n], cv$rankAgreement[1L])
})

# --------------------------------------------------------------------------
# Robustness: a candidate iteration count must be a positive integer. A 0 in
# `grid` would yield colsB = 1:0 (R's ':' reversal) and a divide-by-zero NaN
# row; a negative count would error in seq_len(). Both must be filtered out
# before assessment (alongside the upper 2 * N <= nMax bound), not leak a
# garbage row into the convergence curve.
# --------------------------------------------------------------------------
test_that("gvaConvergence filters out non-positive iteration counts in grid", {
  res <- gvaConvergence(nprcgenekeepr::qcPed,
    nMax = 200L, grid = c(0L, 25L, 50L, 100L), seed = 1L
  )
  expect_false(0L %in% res$convergence$iterations)
  expect_identical(res$convergence$iterations, c(25L, 50L, 100L))
  expect_true(all(is.finite(res$convergence$topOverlap)))

  # a negative count is dropped, not propagated into seq_len()
  resNeg <- gvaConvergence(nprcgenekeepr::qcPed,
    nMax = 200L, grid = c(-5L, 50L), seed = 1L
  )
  expect_identical(resNeg$convergence$iterations, 50L)
})


#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#
# Validation harness for the founder-genome-equivalent sampling SE (issue #82,
# Slice 2 -- the "validate before expose" gate). These functions live only in the
# test harness; they are unit-tested in test_fgSEValidation.R on tiny synthetic
# inputs and driven by data-raw/fgSEValidation.R on lacy1989 + examplePedigree to
# produce the recorded numbers in vignettes/articles/fg-se-validation.qmd.
#
# Layering:
#   * pure scorers     -- fgSEAgreementRatio / fgSECoverage / fgSEScalingRatio
#   * matrix forms     -- fgSEFullFromMatrix (== calcFGSE) / fgSEDiagFromMatrix /
#                         fgSEBootstrapFromMatrix, all from a founder x iteration
#                         retention matrix (fgRetentionMatrix in helper-fgSEFixtures)
#   * verdict          -- fgSEVerdict, the ratified PASS/FAIL bands
#   * orchestrator     -- fgSEOneSeed / fgSEValidate, the seeded replicate study

# ---- pure scorers ---------------------------------------------------------

# Calibration statistic: across B independent seeds, the mean reported SE should
# equal the Monte Carlo spread (sd) of the FG point estimates. ~1 means calibrated.
fgSEAgreementRatio <- function(fgVec, seVec) {
  mean(seVec) / stats::sd(fgVec)
}

# Fraction of FG_b +/- z*SE_b intervals that contain the reference FG. The
# boundary is inclusive (<=).
fgSECoverage <- function(fgVec, seVec, refFG, z = 1.96) {
  mean(abs(fgVec - refFG) <= z * seVec)
}

# SE shrinks as 1/sqrt(K): quadrupling iterations should halve the SE, so the
# coarse-over-fine ratio is ~2.
fgSEScalingRatio <- function(seCoarse, seFine) {
  seCoarse / seFine
}

# ---- matrix forms ---------------------------------------------------------

# Shared pieces of the delta-method SE from a founder x iteration retention
# matrix R (rows id-sorted, entries in {0, 0.5, 1}; rowMeans(R) == calcRetention).
# Name-aligns p to the rows and applies the same hard-fail degeneracy rule as
# calcFG/calcFGSE (a contributing founder retained in zero columns).
fgMatrixComponents <- function(rmat, p) {
  rhat <- rowMeans(rmat)
  p <- p[names(rhat)] # align by NAME (Dragon D-3)
  k <- ncol(rmat)
  degenerate <- checkFgDegeneracy(p, rhat)
  keep <- !is.na(rhat) & rhat > 0 & !is.na(p)
  fg <- if (degenerate) NA_real_ else 1 / sum((p[keep]^2) / rhat[keep])
  g <- numeric(length(rhat))
  if (!degenerate) {
    g[keep] <- fg^2 * (p[keep]^2) / (rhat[keep]^2)
  }
  list(rhat = rhat, p = p, k = k, keep = keep, fg = fg, g = g,
       degenerate = degenerate)
}

# Full (influence-form) delta SE -- identical to calcFGSE(), but taking the
# retention matrix directly so it shares one gene drop with the diagonal and
# bootstrap forms. Folds in the within-iteration founder covariance.
fgSEFullFromMatrix <- function(rmat, p) {
  cmp <- fgMatrixComponents(rmat, p)
  if (cmp$degenerate) {
    return(NA_real_)
  }
  influence <- as.numeric(crossprod(cmp$g, rmat)) # length K
  stats::sd(influence) / sqrt(cmp$k)
}

# Diagonal-only SE: drops the off-diagonals of the founder covariance. Generally
# an OVERESTIMATE (founders compete -> negative off-diagonals); the full-vs-diag
# gap is the cost of the independence approximation (Dragon D-4), measured on the
# real pedigree.
fgSEDiagFromMatrix <- function(rmat, p) {
  cmp <- fgMatrixComponents(rmat, p)
  if (cmp$degenerate) {
    return(NA_real_)
  }
  sigma <- stats::cov(t(rmat)) # F x F within-iteration covariance (denom K - 1)
  sqrt(sum(cmp$g^2 * diag(sigma)) / cmp$k)
}

# Column bootstrap of FG: resample the K iteration columns with replacement,
# recompute FG per resample, drop any degenerate resample (a contributing founder
# at zero retention), and take the sd of the finite replicates. Independent
# cross-check on the delta SE; a large disagreement flags a thin-retention pole.
fgSEBootstrapFromMatrix <- function(rmat, p, B = 2000L, seed = 1L) {
  set.seed(seed)
  k <- ncol(rmat)
  p <- p[rownames(rmat)] # align to rows by NAME
  reps <- numeric(B)
  for (b in seq_len(B)) {
    idx <- sample.int(k, k, replace = TRUE)
    rb <- rowMeans(rmat[, idx, drop = FALSE])
    if (any(!is.na(p) & p > 0 & !is.na(rb) & rb == 0)) {
      reps[b] <- NA_real_ # degenerate resample -> drop
      next
    }
    keepb <- !is.na(rb) & rb > 0 & !is.na(p)
    reps[b] <- 1 / sum((p[keepb]^2) / rb[keepb])
  }
  finite <- is.finite(reps)
  list(se = stats::sd(reps[finite]), dropped = mean(!finite))
}

# ---- verdict --------------------------------------------------------------

# Map a study summary to per-check PASS/FAIL against the ratified bands
# (plan Section 5.1 / 9). Any single failed check fails the whole gate.
fgSEVerdict <- function(summary) {
  inBand <- function(x, lo, hi) isTRUE(x >= lo & x <= hi)
  agreement <- inBand(summary$agreementRatio, 0.92, 1.08)
  coverage <- inBand(summary$coverage, 0.93, 0.97)
  scaling <- inBand(summary$scalingEmp, 1.8, 2.2) &&
    inBand(summary$scalingDelta, 1.8, 2.2)
  degeneracy <- isTRUE(summary$degeneracyFraction == 0)
  bootstrap <- inBand(summary$bootstrapRatio, 0.85, 1.15)
  list(
    agreement = agreement, coverage = coverage, scaling = scaling,
    degeneracy = degeneracy, bootstrap = bootstrap,
    overall = agreement && coverage && scaling && degeneracy && bootstrap
  )
}

# ---- orchestrator ---------------------------------------------------------

# One seeded replicate: a fresh gene drop at K iterations, then the shipped FG
# (calcFEFG) and its shipped SE (calcFGSE). degenerate is TRUE when either is NA
# (the hard-fail zero-retention case).
fgSEOneSeed <- function(ped, seed, k) {
  set.seed(seed)
  alleles <- geneDrop(ped$id, ped$sire, ped$dam, ped$gen,
                      genotype = NULL, n = k)
  fefg <- calcFEFG(ped, alleles)
  se <- suppressWarnings(calcFGSE(ped, alleles))
  list(
    FG = fefg$FG, SE = se,
    degenerate = is.na(fefg$FG) || is.na(se)
  )
}

# The validation study for one pedigree: B replicates at K (and B at 4K for the
# scaling check), a high-iteration reference FG for coverage, and the off-diagonal
# / bootstrap cross-checks on one representative gene drop. Deterministic under a
# fixed seed list. Returns the per-seed table, the summary statistics, and the
# verdict. (Slow on a deep pedigree -- driven by data-raw/fgSEValidation.R; the
# unit test calls it on lacy1989 at a tiny budget for shape + determinism only.)
fgSEValidate <- function(ped, seeds, k, kFine = 4L * k, refK = 20000L,
                         refSeed = 99991L, bootstrapB = 2000L) {
  one <- function(s, kk) fgSEOneSeed(ped, s, kk)

  rep1 <- lapply(seeds, one, kk = k)
  replicates <- data.frame(
    seed = seeds,
    FG = vapply(rep1, function(r) r$FG, numeric(1L)),
    SE = vapply(rep1, function(r) r$SE, numeric(1L)),
    degenerate = vapply(rep1, function(r) r$degenerate, logical(1L))
  )
  ok <- !replicates$degenerate
  degeneracyFraction <- mean(replicates$degenerate)

  # Reference FG at high K (best estimate of truth) for coverage.
  refFG <- fgSEOneSeed(ped, refSeed, refK)$FG

  agreementRatio <- fgSEAgreementRatio(replicates$FG[ok], replicates$SE[ok])
  coverage <- fgSECoverage(replicates$FG[ok], replicates$SE[ok], refFG, z = 1.96)

  # Scaling: independent replicates at 4K (offset seed stream), SE and empirical
  # sd should both halve relative to K.
  rep4 <- lapply(seeds + 1000000L, one, kk = kFine)
  fgFine <- vapply(rep4, function(r) r$FG, numeric(1L))
  seFine <- vapply(rep4, function(r) r$SE, numeric(1L))
  okFine <- !vapply(rep4, function(r) r$degenerate, logical(1L))
  scalingEmp <- fgSEScalingRatio(
    stats::sd(replicates$FG[ok]), stats::sd(fgFine[okFine])
  )
  scalingDelta <- fgSEScalingRatio(
    mean(replicates$SE[ok]), mean(seFine[okFine])
  )

  # Off-diagonal materiality + bootstrap, on one representative gene drop at K.
  set.seed(seeds[1L])
  al1 <- geneDrop(ped$id, ped$sire, ped$dam, ped$gen, genotype = NULL, n = k)
  rmat1 <- fgRetentionMatrix(ped, al1)
  p1 <- calcFounderContributions(ped, "calcFG")$p
  seFull <- fgSEFullFromMatrix(rmat1, p1)
  seDiag <- fgSEDiagFromMatrix(rmat1, p1)
  boot <- fgSEBootstrapFromMatrix(rmat1, p1, B = bootstrapB, seed = seeds[1L])

  summary <- list(
    agreementRatio = agreementRatio,
    coverage = coverage,
    scalingEmp = scalingEmp,
    scalingDelta = scalingDelta,
    degeneracyFraction = degeneracyFraction,
    bootstrapRatio = boot$se / seFull,
    bootDropped = boot$dropped,
    seFull = seFull,
    seDiag = seDiag,
    offDiagRatio = seFull / seDiag,
    refFG = refFG,
    k = k, kFine = kFine, refK = refK, B = length(seeds)
  )

  list(
    replicates = replicates,
    summary = summary,
    verdict = fgSEVerdict(summary)
  )
}

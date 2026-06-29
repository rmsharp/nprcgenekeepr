## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# Issue #13 item-3 follow-up (S220), revised for the issue #95 keep-all revert
# (S234): gvaConvergence() must honor outside-information kinship overrides the
# SAME way reportGV() does -- apply them to the (proband-filtered) kinship matrix
# before mean kinship via the shared prepareKinshipOverrides() helper. The
# override REFINES a kinship cell (issue #13); it never suppresses a focal's
# +sexMean/2 unknown-parent prior -- every one-unknown animal keeps its
# correction (keep-all). gvaConvergence ranks on the same mean-kinship z-scores
# reportGV uses; an override that did not reach this pipeline would make the
# convergence diagnostic disagree with the report it is meant to characterize.
#
# Testability note: the override's effect on gvaConvergence's OUTPUT (the
# convergence curve) is visible only through gene-drop "churn" near the top-k
# boundary. On a no-gu pedigree (qcPed) every half-split agrees (overlap == 1,
# rankAgreement == 1) regardless of the mean-kinship order, so the override is
# output-invisible there. Therefore the "override reaches the ranking" assertion
# uses the gu-bearing convergence fixture; the one-unknown #9 interaction (no
# per-animal mean kinship is returned by gvaConvergence) is exercised on qcPed,
# and its NUMERIC correctness is covered by construction-parity with reportGV
# plus the reportGV D10/D5/keep-all tests in test_reportGV.R, because
# gvaConvergence reuses the identical correctUnknownParentMeanKinship() call.

# Exact copy of the convergence fixture (see test_gvaConvergence.R), renamed to
# avoid a cross-file clash, so this file also runs in isolation. A deterministic
# dense-mid-range half-sib web: founders are excluded from the proband
# population, the 70 offspring are the probands, and the gene drop is the only
# seed consumer, so a fixed seed gives a byte-identical convergence curve.
makeConvFixtureOv <- function() {
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
# (1) D10 regression: a NULL or zero-row override leaves the convergence result
# byte-identical to the no-override run -- the default code path is untouched.
# --------------------------------------------------------------------------
test_that("gvaConvergence with NULL or zero-row overrides equals the no-override run", {
  fx <- makeConvFixtureOv()
  base <- gvaConvergence(fx$ped, pop = fx$pop, nMax = 800L, seed = 11L)

  nullOv <- gvaConvergence(fx$ped,
    pop = fx$pop, nMax = 800L, seed = 11L,
    kinshipOverrides = NULL
  )
  expect_equal(nullOv$convergence, base$convergence)
  expect_identical(nullOv$recommendedIter, base$recommendedIter)

  zero <- data.frame(
    id1 = character(0), id2 = character(0), kinship = numeric(0),
    stringsAsFactors = FALSE
  )
  zeroOv <- gvaConvergence(fx$ped,
    pop = fx$pop, nMax = 800L, seed = 11L,
    kinshipOverrides = zero
  )
  expect_equal(zeroOv$convergence, base$convergence)
})

# --------------------------------------------------------------------------
# (2) An override that shifts mean-kinship z-scores reaches the ranking pipeline
# and changes the convergence curve; the change is deterministic under a fixed
# seed. The override is five offspring pairs at near-max kinship (0.49), chosen
# so the perturbation is robust (verified to move the curve at this nMax/seed).
# --------------------------------------------------------------------------
test_that("gvaConvergence applies kinship overrides to the ranking (deterministic)", {
  fx <- makeConvFixtureOv()
  off <- fx$pop
  ov <- data.frame(
    id1 = off[c(1, 3, 5, 7, 9)],
    id2 = off[c(2, 4, 6, 8, 10)],
    kinship = 0.49,
    stringsAsFactors = FALSE
  )
  base <- gvaConvergence(fx$ped, pop = fx$pop, nMax = 800L, seed = 11L)
  over <- suppressMessages(gvaConvergence(fx$ped,
    pop = fx$pop, nMax = 800L, seed = 11L, kinshipOverrides = ov
  ))

  # the override reaches the ranking: the convergence curve is NOT identical
  expect_false(isTRUE(all.equal(base$convergence, over$convergence)))

  # deterministic under a fixed seed: a second identical run matches the first
  over2 <- suppressMessages(gvaConvergence(fx$ped,
    pop = fx$pop, nMax = 800L, seed = 11L, kinshipOverrides = ov
  ))
  expect_equal(over$convergence, over2$convergence)
})

# --------------------------------------------------------------------------
# (3) D5 soft warn-drop: an override row referencing an id outside the proband
# set warns and the run completes -- the strict applyKinshipOverrides leaf never
# aborts the diagnostic. With only an out-of-set row, the result equals baseline.
# --------------------------------------------------------------------------
test_that("gvaConvergence warn-drops an out-of-set override id without aborting", {
  fx <- makeConvFixtureOv()
  # founders (e.g. S001) are excluded from the proband population
  expect_false("S001" %in% fx$pop)

  badOv <- data.frame(
    id1 = fx$pop[1], id2 = "S001", kinship = 0.1,
    stringsAsFactors = FALSE
  )
  base <- gvaConvergence(fx$ped, pop = fx$pop, nMax = 800L, seed = 11L)
  expect_warning(
    res <- gvaConvergence(fx$ped,
      pop = fx$pop, nMax = 800L, seed = 11L, kinshipOverrides = badOv
    ),
    "not in the analysis set"
  )
  expect_equal(res$convergence, base$convergence)
})

# --------------------------------------------------------------------------
# (4) Strict validation propagates: an override above the positive-semidefinite
# bound sqrt(self-kinship product) stops -- applyKinshipOverrides is the strict
# leaf and gvaConvergence must not swallow that error.
# --------------------------------------------------------------------------
test_that("gvaConvergence errors on an override above the PSD bound", {
  fx <- makeConvFixtureOv()
  # an offspring pair's self-kinship is ~0.5, so the bound is ~0.5; 0.9 exceeds it
  badVal <- data.frame(
    id1 = fx$pop[1], id2 = fx$pop[2], kinship = 0.9,
    stringsAsFactors = FALSE
  )
  expect_error(
    suppressMessages(gvaConvergence(fx$ped,
      pop = fx$pop, nMax = 800L, seed = 11L, kinshipOverrides = badVal
    )),
    "above the maximum"
  )
})

# --------------------------------------------------------------------------
# (5) reportGV fidelity -- the keep-all / issue-#9 path: an override on a real
# one-unknown-parent rankable animal runs clean and is honored (the
# "N kinship override(s) applied." message fires). On qcPed the convergence
# metrics are gu-free (always 1.0), so the override cannot change the OUTPUT
# curve there; the keep-all NUMERIC is covered by reportGV's tests
# (test_reportGV.R) and test_correctUnknownParentMeanKinship.R, since
# gvaConvergence reuses the identical correctUnknownParentMeanKinship() call and
# returns no per-animal mean kinship of its own.
# --------------------------------------------------------------------------
test_that("gvaConvergence honors an override on a one-unknown-parent animal", {
  ped <- nprcgenekeepr::qcPed
  X <- "0K7VJN" # male, one-unknown (sire missing) -- see test_reportGV.R
  Y <- "N2XF08" # known parentage
  isU <- function(x) is.na(x) | nprcgenekeepr:::isGeneratedUnknownId(x)
  # fixture guards: fail loudly if qcPed changes instead of mis-testing
  expect_true(all(c(X, Y) %in% as.character(ped$id)))
  expect_true(xor(isU(ped$sire[ped$id == X]), isU(ped$dam[ped$id == X])))

  ov <- data.frame(id1 = X, id2 = Y, kinship = 0.25, stringsAsFactors = FALSE)
  res <- NULL
  expect_message(
    res <- gvaConvergence(ped,
      nMax = 200L, grid = c(25L, 50L, 100L), seed = 1L, kinshipOverrides = ov
    ),
    "kinship override"
  )
  expect_s3_class(res, "nprcgenekeeprGVConv")

  # qcPed is gu-free -> the override cannot change the (always-1.0) curve; it
  # must still converge at the grid floor exactly as the no-override run does
  base <- gvaConvergence(ped, nMax = 200L, grid = c(25L, 50L, 100L), seed = 1L)
  expect_equal(res$convergence, base$convergence)
})

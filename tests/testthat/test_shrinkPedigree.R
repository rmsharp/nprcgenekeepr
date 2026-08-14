## Copyright(c) 2017-2026 R. Mark Sharp
# This file is part of nprcgenekeepr
library(testthat)

## Track B of the ratified kinship2 supplement full-reproduction plan
## (docs/planning/kinship2-supplement-full-reproduction-plan.md §4) --
## shrinkPedigree(), a pedigree.shrink() equivalent. Per the plan's own §1
## scope caveat, the PDF has no reachable worked example for this track, so
## every fixture below was independently cross-validated against the
## installed kinship2::pedigree.shrink() (1.9.6.2) live during Pre-RED --
## the same evidence standard S564 used for Table S2 (docs/planning/
## kinship2-supplement-full-reproduction-plan.md's own precedent) -- and the
## resulting values are hardcoded here, matching Track A's own established
## precedent (kinship2 is not a Suggests dependency; test_kinship.R never
## calls kinship2:: live either). All 8 of kinship2's own internal helpers
## (pedigree.shrink, bitSize, findUnavailable, excludeUnavailFounders,
## excludeStrayMarryin, findAvailNonInform, findAvailAffected,
## pedigree.trim) were deparsed directly from the installed namespace, not
## assumed from the Rd docs or the plan's own summary.

## ---- Validation -----------------------------------------------------

test_that("shrinkPedigree() requires id/sire/dam columns", {
  ped <- data.frame(id = "A", stringsAsFactors = FALSE)
  expect_error(
    shrinkPedigree(ped, genotyped = TRUE),
    "sire"
  )
})

test_that("shrinkPedigree() requires genotyped to be the same length as
  nrow(ped)", {
  ped <- data.frame(id = c("A", "B"), sire = c(NA, "A"), dam = c(NA, NA),
    stringsAsFactors = FALSE)
  expect_error(
    shrinkPedigree(ped, genotyped = TRUE),
    "genotyped"
  )
})

test_that("shrinkPedigree() rejects NA values in genotyped, matching
  kinship2's own avail validation", {
  ped <- data.frame(id = c("A", "B"), sire = c(NA, "A"), dam = c(NA, NA),
    stringsAsFactors = FALSE)
  expect_error(
    shrinkPedigree(ped, genotyped = c(TRUE, NA)),
    "NA"
  )
})

## ---- Phase 1: unavailable-terminal trim (findUnavailable, no cascade) --

test_that("shrinkPedigree() removes an ungenotyped terminal leaf while
  preserving a genotyped sibling and both parents", {
  ped <- data.frame(
    id   = c("F1", "F2", "C1", "C2"),
    sire = c(NA, NA, "F1", "F1"),
    dam  = c(NA, NA, "F2", "F2"),
    stringsAsFactors = FALSE
  )
  genotyped <- c(TRUE, TRUE, FALSE, TRUE)
  # affected = TRUE for C2 keeps it immune from the (separately-tested)
  # non-informative-trim tier, isolating this test to the terminal-
  # unavailable mechanism alone.
  affected <- c(NA, NA, TRUE, TRUE)
  result <- shrinkPedigree(ped, genotyped, affected = affected)
  expect_setequal(result$ped$id, c("F1", "F2", "C2"))
  expect_identical(result$idTrimmed, "C1")
  expect_identical(result$idList$unavail, "C1")
  expect_equal(result$bitSize, c(2, 0))
})

## ---- Phase 1b: excludeUnavailFounders (single-child founder couple) ----

test_that("shrinkPedigree() removes an unavailable founder couple with
  exactly one child and no other mate, promoting the child to founder
  status -- the child survives because it is itself a parent", {
  ped <- data.frame(
    id   = c("P3", "P4", "C4", "G3", "C4a"),
    sire = c(NA, NA, "P3", NA, "C4"),
    dam  = c(NA, NA, "P4", NA, "G3"),
    stringsAsFactors = FALSE
  )
  genotyped <- c(FALSE, FALSE, TRUE, TRUE, TRUE)
  affected <- c(NA, NA, TRUE, NA, TRUE)
  result <- shrinkPedigree(ped, genotyped, affected = affected)
  expect_setequal(result$ped$id, c("C4", "G3", "C4a"))
  expect_setequal(result$idList$unavail, c("P3", "P4"))
  # C4 is promoted to founder status: both its own parents are cleared.
  c4Row <- result$ped[result$ped$id == "C4", ]
  expect_true(is.na(c4Row$sire))
  expect_true(is.na(c4Row$dam))
  # C4a's parentage (C4, G3) is untouched.
  c4aRow <- result$ped[result$ped$id == "C4a", ]
  expect_identical(c4aRow$sire, "C4")
  expect_identical(c4aRow$dam, "G3")
})

test_that("shrinkPedigree() does NOT apply the unavailable-founder-couple
  rule when one parent has remarried", {
  ped <- data.frame(
    id   = c("P3", "P4", "P5", "C1", "C2"),
    sire = c(NA, NA, NA, "P3", "P3"),
    dam  = c(NA, NA, NA, "P4", "P5"),
    stringsAsFactors = FALSE
  )
  # P3 has two mates (P4, P5) -- disqualifies both P3:P4 and P3:P5 from the
  # single-marriage rule, matching kinship2's own nmarr.dad/nmarr.mom skip.
  genotyped <- c(FALSE, FALSE, FALSE, TRUE, TRUE)
  affected <- c(NA, NA, NA, TRUE, TRUE)
  result <- shrinkPedigree(ped, genotyped, affected = affected)
  expect_setequal(result$ped$id, ped$id)
  expect_length(result$idTrimmed, 0L)
})

## ---- Phase 1c: excludeStrayMarryin (unconditional on genotyped) -------

test_that("shrinkPedigree() removes a childless, unconnected founder
  ('stray marry-in') even when it IS genotyped", {
  ped <- data.frame(
    id   = c("F1", "F2", "C1", "X"),
    sire = c(NA, NA, "F1", NA),
    dam  = c(NA, NA, "F2", NA),
    stringsAsFactors = FALSE
  )
  genotyped <- c(TRUE, TRUE, TRUE, TRUE)
  affected <- c(NA, NA, TRUE, TRUE)
  result <- shrinkPedigree(ped, genotyped, affected = affected)
  expect_setequal(result$ped$id, c("F1", "F2", "C1"))
  expect_identical(result$idTrimmed, "X")
  expect_identical(result$idList$unavail, "X")
})

## ---- Phase 2: findAvailNonInform ---------------------------------------

test_that("shrinkPedigree() removes a genotyped, unaffected, non-parent
  individual whose both parents are genotyped (non-informative)", {
  ped <- data.frame(
    id   = c("F1", "F2", "C1", "C2"),
    sire = c(NA, NA, "F1", "F1"),
    dam  = c(NA, NA, "F2", "F2"),
    stringsAsFactors = FALSE
  )
  genotyped <- c(TRUE, TRUE, TRUE, TRUE)
  affected <- c(NA, NA, FALSE, TRUE)
  result <- shrinkPedigree(ped, genotyped, affected = affected)
  expect_setequal(result$ped$id, c("F1", "F2", "C2"))
  expect_identical(result$idTrimmed, "C1")
  expect_identical(result$idList$noninform, "C1")
})

test_that("shrinkPedigree() treats NA affected status the same as
  unaffected (0) for non-informative trimming, matching kinship2's own
  all(x == 0, na.rm = TRUE) rule", {
  ped <- data.frame(
    id   = c("F1", "F2", "C1", "C2"),
    sire = c(NA, NA, "F1", "F1"),
    dam  = c(NA, NA, "F2", "F2"),
    stringsAsFactors = FALSE
  )
  genotyped <- c(TRUE, TRUE, TRUE, TRUE)
  affected <- c(NA, NA, NA, TRUE)
  result <- shrinkPedigree(ped, genotyped, affected = affected)
  expect_setequal(result$ped$id, c("F1", "F2", "C2"))
  expect_identical(result$idTrimmed, "C1")
})

test_that("shrinkPedigree() does NOT trim a non-informative candidate when
  one of its own parents is not genotyped", {
  ped <- data.frame(
    id   = c("F1", "F2", "C1"),
    sire = c(NA, NA, "F1"),
    dam  = c(NA, NA, "F2"),
    stringsAsFactors = FALSE
  )
  genotyped <- c(TRUE, FALSE, TRUE)
  affected <- c(NA, NA, FALSE)
  result <- shrinkPedigree(ped, genotyped, affected = affected)
  expect_setequal(result$ped$id, ped$id)
  expect_length(result$idTrimmed, 0L)
})

test_that("shrinkPedigree() never marks a single-known-parent individual as
  non-informative and does not error -- a package-specific divergence from
  kinship2, whose own pedigree() constructor forbids this input shape
  entirely ('Subjects must have both a father and mother, or have
  neither', confirmed live against the installed namespace)", {
  ped <- data.frame(
    id   = c("F1", "C1"),
    sire = c(NA, "F1"),
    dam  = c(NA, NA),
    stringsAsFactors = FALSE
  )
  genotyped <- c(TRUE, TRUE)
  affected <- c(NA, FALSE)
  expect_no_error(result <- shrinkPedigree(ped, genotyped, affected = affected))
  expect_setequal(result$ped$id, c("F1", "C1"))
  expect_length(result$idTrimmed, 0L)
})

## ---- Phase 3: findAvailAffected (priority-ordered bitSize reduction) ---

test_that("shrinkPedigree() reduces bitSize past maxBits one individual at
  a time, trying NA-affected candidates before unaffected before affected
  (kinship2's own priority order), with a unique bitSize-minimizing
  candidate at each step (no tie-break needed)", {
  ped <- data.frame(
    id   = c("G1", "G2", "M1", "L1", "L2", "L3", "G3"),
    sire = c(NA, NA, "G1", "M1", "M1", "M1", NA),
    dam  = c(NA, NA, "G2", "G3", "G3", "G3", NA),
    stringsAsFactors = FALSE
  )
  genotyped <- c(G1 = TRUE, G2 = FALSE, M1 = TRUE, L1 = TRUE, L2 = TRUE,
    L3 = TRUE, G3 = FALSE)[ped$id]
  affected <- c(G1 = NA, G2 = NA, M1 = TRUE, L1 = NA, L2 = FALSE, L3 = TRUE,
    G3 = NA)[ped$id]
  result <- shrinkPedigree(ped, genotyped, affected = affected, maxBits = 1)
  expect_setequal(result$ped$id, c("G1", "G2", "M1", "L3", "G3"))
  expect_identical(result$idList$affected, c("L1", "L2"))
  expect_equal(result$bitSize, c(5, 5, 3, 1))
})

test_that("shrinkPedigree() breaks a genuine bitSize tie deterministically
  by lowest id, string-sorted -- '10' sorts below '9' as a string even
  though it is numerically larger (D-B2, ratified). Confirmed live against
  kinship2::pedigree.shrink() that this exact fixture IS a genuine tie
  there (its own runif() tie-break picks '9' or '10' roughly 50/50 across
  seeds) -- shrinkPedigree() must not inherit that non-determinism.", {
  ped <- data.frame(
    id   = c("F1", "F2", "9", "10"),
    sire = c(NA, NA, "F1", "F1"),
    dam  = c(NA, NA, "F2", "F2"),
    stringsAsFactors = FALSE
  )
  genotyped <- c(TRUE, FALSE, TRUE, TRUE)
  affected <- c(NA, NA, FALSE, FALSE)
  for (i in 1:5) {
    result <- shrinkPedigree(ped, genotyped, affected = affected, maxBits = 1)
    expect_setequal(result$ped$id, c("F1", "F2", "9"))
    expect_identical(result$idList$affected, "10")
  }
})

## ---- Absent affected data ----------------------------------------------

test_that("shrinkPedigree() treats a completely absent affected column/
  argument as all-unaffected, not an error -- confirmed live against
  kinship2::pedigree.shrink() with an explicit all-FALSE affected vector
  (the closest faithful analogue kinship2 itself accepts) that this exact
  symmetric fixture fully collapses: both C1 and C2 are simultaneously
  genotyped/non-parent/both-parents-genotyped/unaffected, so both are
  marked non-informative in the same pass, and F1/F2 then become childless
  founders removed as stray marry-ins -- not a bug, the algorithm's own
  real behavior for a fixture with no informative structure at all", {
  ped <- data.frame(
    id   = c("F1", "F2", "C1", "C2"),
    sire = c(NA, NA, "F1", "F1"),
    dam  = c(NA, NA, "F2", "F2"),
    stringsAsFactors = FALSE
  )
  genotyped <- c(TRUE, TRUE, TRUE, TRUE)
  expect_no_error(result <- shrinkPedigree(ped, genotyped))
  expect_identical(nrow(result$ped), 0L)
  expect_setequal(result$idTrimmed, ped$id)
})

test_that("shrinkPedigree() records EVERY id actually removed by a
  cascading affected-priority round, not just the single trial candidate --
  a deliberate, documented fix to a confirmed real gap in kinship2's own
  bookkeeping: a live test against kinship2::pedigree.shrink() on this
  exact fixture shows pedSizeFinal drops by 2 (L and G both vanish -- G is
  a stray marry-in once L, its only descendant path, is gone) while
  kinship2's own idTrimmed/idList$affect records only 'L', silently
  omitting G. shrinkPedigree()'s idTrimmed/idList$affected must stay
  consistent with pedSizeOriginal - pedSizeFinal -- the surviving ped
  (F1, F2, M) is identical to kinship2's own, only the audit trail is
  more complete.", {
  ped <- data.frame(
    id   = c("F1", "F2", "G", "M", "L"),
    sire = c(NA, NA, NA, "F1", "M"),
    dam  = c(NA, NA, NA, "F2", "G"),
    stringsAsFactors = FALSE
  )
  genotyped <- c(TRUE, TRUE, TRUE, TRUE, TRUE)
  affected <- c(NA, NA, NA, TRUE, TRUE)
  result <- shrinkPedigree(ped, genotyped, affected = affected, maxBits = 0)
  expect_setequal(result$ped$id, c("F1", "F2", "M"))
  expect_identical(result$pedSizeFinal, 3L)
  expect_setequal(result$idTrimmed, c("L", "G"))
  expect_setequal(result$idList$affected, c("L", "G"))
  expect_identical(
    result$pedSizeOriginal - result$pedSizeFinal,
    length(result$idTrimmed)
  )
})

## ---- Full pipeline, cross-validated against kinship2::pedigree.shrink() -

## Composite fixture exercising every removal phase in one pedigree,
## reused (verbatim structure) from the Pre-RED cross-validation run
## against the installed kinship2 1.9.6.2, confirmed identical across 4
## independent seeds (no tie-sensitivity anywhere in this fixture -- every
## step has a unique bitSize-minimizing candidate, confirmed by hand-tracing
## the cascade: e.g. removing "C3" (the only remaining child of P1/P2 by
## that point) drops the resulting bitSize to 1, strictly lower than
## removing "L3" (whose own removal cascades to also strip "G3" as a new
## stray marry-in, landing at bitSize 2) -- so kinship2's own runif()
## tie-break is never actually invoked on this fixture, and both it and
## shrinkPedigree()'s deterministic tie-break necessarily agree).
test_that("shrinkPedigree() reproduces kinship2::pedigree.shrink()'s own
  output (id set, bitSize trajectory, and per-phase idList grouping) on a
  composite fixture exercising unavailable-terminal, unavailable-founder-
  couple, stray-marry-in, non-informative, and affected-priority removal
  together", {
  ped <- data.frame(
    id   = c("P1", "P2", "P3", "P4", "P5", "P6",
             "C1", "C2", "C3", "C4", "C4a",
             "G3", "M1", "L1", "L2", "L3"),
    sire = c(NA, NA, NA, NA, NA, NA,
             "P1", "P1", "P1", "P3", "C4",
             NA, "P1", "M1", "M1", "M1"),
    dam  = c(NA, NA, NA, NA, NA, NA,
             "P2", "P2", "P2", "P4", "P6",
             NA, "P2", "G3", "G3", "G3"),
    stringsAsFactors = FALSE
  )
  genotyped <- c(P1 = TRUE, P2 = TRUE, P3 = FALSE, P4 = FALSE, P5 = TRUE,
    P6 = TRUE, C1 = TRUE, C2 = FALSE, C3 = TRUE, C4 = TRUE, C4a = TRUE,
    G3 = FALSE, M1 = TRUE, L1 = TRUE, L2 = TRUE, L3 = TRUE)[ped$id]
  affected <- c(P1 = NA, P2 = NA, P3 = NA, P4 = NA, P5 = NA, P6 = NA,
    C1 = FALSE, C2 = NA, C3 = TRUE, C4 = TRUE, C4a = TRUE, G3 = NA,
    M1 = TRUE, L1 = NA, L2 = FALSE, L3 = TRUE)[ped$id]

  result <- shrinkPedigree(ped, genotyped, affected = affected, maxBits = 1)

  # -- Ground truth from a live, set.seed()-pinned kinship2::pedigree.shrink()
  # run on the identical fixture (Pre-RED, confirmed stable across 4 seeds):
  expect_setequal(result$ped$id,
    c("P1", "P2", "P6", "C4", "C4a", "G3", "M1", "L3"))
  expect_setequal(result$idList$unavail, c("P3", "P4", "P5", "C2"))
  expect_identical(result$idList$noninform, "C1")
  expect_identical(result$idList$affected, c("L1", "L2", "C3"))
  expect_equal(result$bitSize, c(11, 7, 5, 3, 1))
  expect_identical(result$pedSizeOriginal, 16L)
  expect_identical(result$pedSizeIntermed, 11L)
  expect_identical(result$pedSizeFinal, 8L)
})

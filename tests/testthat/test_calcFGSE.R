## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#
# Issue #82 Slice 1: calcFGSE() returns the Monte Carlo sampling standard error
# of the founder-genome-equivalent statistic FG = 1 / sum(p^2 / r). FG is a
# nonlinear functional of the random per-founder retention vector r, so its SE
# comes from a delta-method (influence-form) linearization, not a column
# variance. Fixtures and an independent sandwich-form reference SE are in
# helper-fgSEFixtures.R.

data("lacy1989Ped")
data("lacy1989PedAlleles")

# (a) Exact value: matches an INDEPENDENT influence/sandwich recompute --------
test_that("calcFGSE matches an independent delta-method recompute on lacy1989", {
  ped <- lacy1989Ped
  alleles <- lacy1989PedAlleles

  expected <- fgSEReference(ped, alleles) # explicit F x F sandwich (helper)
  se <- calcFGSE(ped, alleles)

  expect_type(se, "double")
  expect_length(se, 1L)
  expect_equal(se, expected)
})

# (b) Deterministic shrinkage via the column-doubling trick (RNG-free) --------
test_that("calcFGSE shrinks by the exact column-doubling factor", {
  ped <- lacy1989Ped
  alleles <- lacy1989PedAlleles
  vCols <- !(colnames(alleles) %in% c("id", "parent"))
  k <- sum(vCols)

  meta <- alleles[, c("id", "parent")]
  vDat <- alleles[, vCols, drop = FALSE]
  doubled <- cbind(meta, vDat, vDat) # K -> 2K, identical per-column values
  names(doubled) <- c("id", "parent", paste0("V", seq_len(2L * k)))

  base <- calcFGSE(ped, alleles)
  dub <- calcFGSE(ped, doubled)

  # SE_2K = SE_K * sqrt((K - 1) / (2K - 1)) -- same factor as calcGUSE.
  expect_equal(dub, base * sqrt((k - 1L) / (2L * k - 1L)))
  expect_lt(dub, base)
})

# (c) Shape: a single, non-negative, finite number when retention is healthy --
test_that("calcFGSE returns one finite non-negative number on lacy1989", {
  se <- calcFGSE(lacy1989Ped, lacy1989PedAlleles)
  expect_length(se, 1L)
  expect_false(is.na(se))
  expect_true(is.finite(se))
  expect_gte(se, 0)
  expect_gt(se, 0) # lacy retention varies across iterations
})

# (d) Founder-order alignment (Dragon D-3) ------------------------------------
# On an unsorted-founder pedigree the contribution vector p (pedigree-row order)
# and the retention vector r (id-sorted) are in DIFFERENT orders, so a
# position-based combination would silently misalign them. The FIRST assertion
# is the real alignment guard: calcFGSE must equal the name-aligned reference; a
# position-based calcFGSE would not. The SECOND assertion only checks that the
# factor->character coercion is order-stable (both pedigrees coerce to the same
# getFounders order), so on its own it would NOT catch a position bug.
test_that("calcFGSE aligns founders by name when founder ids are unsorted", {
  ped <- makeFgPed(unsorted = TRUE)
  alleles <- makeFgAlleles(ped, k = 600L)
  pedFactor <- makeFgPed(unsorted = TRUE, asFactor = TRUE)

  expect_equal(calcFGSE(ped, alleles), fgSEReference(ped, alleles)) # alignment guard
  expect_equal(calcFGSE(pedFactor, alleles), calcFGSE(ped, alleles)) # coercion-stability
})

# (e) Degeneracy handling on the crafted fixtures (D5) ------------------------
test_that("calcFGSE hard-fails (NA + warning) on a contributing founder with zero retention", {
  ped <- makeFgPed()
  hf <- makeFgAlleles(ped, k = 300L, hardFail = TRUE)

  expect_warning(se <- calcFGSE(ped, hf), regexp = "retained in 0")
  expect_true(is.na(se))
})

test_that("calcFGSE drops a p==0,r==0 founder cleanly and reports over the same founder set as FG", {
  ped <- makeFgPed() # P0 isolated: p == 0, r == 0
  alleles <- makeFgAlleles(ped, k = 600L)

  se <- calcFGSE(ped, alleles)
  expect_true(is.finite(se))
  expect_gt(se, 0)
  expect_equal(se, fgSEReference(ped, alleles))

  # Removing the non-contributing founder must change neither FG nor its SE:
  # the SE refers to exactly the founder set FG is computed from.
  pedNoIso <- ped[ped$id != "P0", ]
  pedNoIso["gen"] <- findGeneration(pedNoIso$id, pedNoIso$sire, pedNoIso$dam)
  pedNoIso$population <- getGVPopulation(pedNoIso, NULL)
  allelesNoIso <- alleles[alleles$id != "P0", ]
  expect_equal(calcFGSE(pedNoIso, allelesNoIso), se)
  expect_equal(calcFG(pedNoIso, allelesNoIso), calcFG(ped, alleles))
})

# (f) Cross-check: the delta SE agrees with an independent column bootstrap ----
test_that("calcFGSE (delta) agrees with a seeded column bootstrap on a mid-range fixture", {
  ped <- makeFgPed()
  alleles <- makeFgAlleles(ped, k = 600L)

  se <- calcFGSE(ped, alleles)

  rmat <- fgRetentionMatrix(ped, alleles)
  fc <- calcFounderContributions(ped, "calcFG")
  p <- fc$p[rownames(rmat)]
  k <- ncol(rmat)
  set.seed(42L)
  reps <- vapply(seq_len(2000L), function(b) {
    idx <- sample.int(k, k, replace = TRUE)
    rb <- rowMeans(rmat[, idx, drop = FALSE])
    keep <- rb > 0 & !is.na(p) & p > 0
    1 / sum((p[keep]^2) / rb[keep])
  }, numeric(1L))
  reps <- reps[is.finite(reps)]
  seBoot <- stats::sd(reps)

  # Delta and bootstrap are different estimators; they agree to first order when
  # retention is mid-range. Deterministic given the seed.
  expect_lt(abs(seBoot / se - 1), 0.15)
})

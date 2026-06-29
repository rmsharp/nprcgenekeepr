## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#
# Issue #2 Slice 1: calcGUSE() returns the per-animal Monte Carlo sampling
# standard error of the genome-uniqueness (gu) estimate, computed from the same
# rare-allele matrix calcGU()/calcA() build. For animal i with per-column value
# m_ik = rare[i, k] / 2 (so mean_k m_ik = gu_i / 100), the exact column-variance
# SE is 100 * sqrt(var(m_i.) / K) with K = number of gene-drop iterations. The
# helper mirrors calcGU(): a single-column data.frame named "guSE" with rownames
# set to the animal ids.
data("ped1Alleles")

test_that("calcGUSE matches the exact column-variance standard error", {
  alleles <- nprcgenekeepr::ped1Alleles

  # Independent recomputation straight from calcA (no reuse of the helper's code)
  rare <- calcA(alleles, threshold = 3L, byID = FALSE)
  k <- sum(!(colnames(alleles) %in% c("id", "parent")))
  perColumn <- rare / 2
  expectedSE <- sqrt(apply(perColumn, 1L, stats::var) / k) * 100

  guSE <- calcGUSE(alleles, threshold = 3L, byID = FALSE)

  expect_true(is.data.frame(guSE))
  expect_named(guSE, "guSE")
  expect_identical(rownames(guSE), names(expectedSE))
  expect_equal(guSE$guSE, unname(expectedSE))
  expect_true(all(guSE$guSE >= 0))
})

test_that("calcGUSE honors threshold, byID, and the pop filter like calcGU", {
  alleles <- nprcgenekeepr::ped1Alleles

  recompute <- function(a, threshold, byID) {
    rare <- calcA(a, threshold = threshold, byID = byID)
    k <- sum(!(colnames(a) %in% c("id", "parent")))
    unname(sqrt(apply(rare / 2, 1L, stats::var) / k) * 100)
  }

  # byID = TRUE, threshold = 2
  se1 <- calcGUSE(alleles, threshold = 2L, byID = TRUE)
  expect_equal(se1$guSE, recompute(alleles, 2L, TRUE))

  # pop filter: restrict to a subset of ids, then recompute on the same subset
  pop <- alleles$id[20L:60L]
  sub <- alleles[alleles$id %in% pop, ]
  se2 <- calcGUSE(alleles, threshold = 3L, byID = FALSE, pop = pop)
  expect_equal(se2$guSE, recompute(sub, 3L, FALSE))
  expect_identical(nrow(se2), length(unique(sub$id)))
})

test_that("calcGUSE shrinks with more iterations (exact var-of-mean scaling)", {
  alleles <- nprcgenekeepr::ped1Alleles
  vCols <- !(colnames(alleles) %in% c("id", "parent"))
  k <- sum(vCols)

  base <- calcGUSE(alleles, threshold = 3L, byID = FALSE)

  # Duplicate every gene-drop column: K -> 2K with the SAME per-column values
  # (each per-animal column value now appears exactly twice). The sample
  # variance-of-the-mean SE then scales by an exact, RNG-free factor, so this
  # demonstrates "more iterations -> smaller SE" deterministically.
  meta <- alleles[, c("id", "parent")]
  vDat <- alleles[, vCols, drop = FALSE]
  doubled <- cbind(meta, vDat, vDat)
  names(doubled) <- c("id", "parent", paste0("V", seq_len(2L * k)))
  dub <- calcGUSE(doubled, threshold = 3L, byID = FALSE)

  # SE_2K = SE_K * sqrt((K - 1) / (2K - 1))
  scaleFactor <- sqrt((k - 1L) / (2L * k - 1L))
  expect_equal(dub$guSE, base$guSE * scaleFactor)

  # strictly smaller wherever there is any sampling variation
  pos <- base$guSE > 0
  expect_true(any(pos))
  expect_true(all(dub$guSE[pos] < base$guSE[pos]))
})

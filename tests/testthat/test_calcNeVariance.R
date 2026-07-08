## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# ---------------------------------------------------------------------------
# Issue #118 Slice 3 (E3): calcNeVariance(ped) is the variance effective
# population size over the CURRENT LIVING BREEDERS (getLivingBreeders()) --
# the diversity loss from unequal family sizes (the dominant Ne-reducer in a
# harem colony). Owner-ratified formula (decision D-d, Session 312): the
# mean-adjusted Crow & Kimura (1970) form
#
#     Ne = (N * kbar - 1) / (kbar - 1 + Vk / kbar)
#
# where N is the number of living breeders, kbar the mean lifetime offspring
# count among them (findOffspring()), and Vk the sample variance (R var(),
# denominator N - 1) of those counts. This general form makes NO constant-size
# assumption and reduces to the classic (4N - 2)/(Vk + 2) at replacement
# (kbar == 2); it was chosen over the bare (4N - 4)/(Vk + 2), which assumes
# kbar ~ 2 and would report a materially different (artifactually low) value
# when kbar != 2. It is a deterministic pure function of the pedigree (no gene
# drop, no seed). Degeneracy (D-d): fewer than 2 living breeders -> NA (Vk is
# undefined for < 2 observations).
# ---------------------------------------------------------------------------

test_that("calcNeVariance implements the ratified Crow-Kimura form (kbar != 2)", {
  ## Living breeders S1 (4 offspring) and D1 (2 offspring); the U-id co-parents
  ## (U0001 / U0002) are auto-generated-unknown and excluded, and the six kids
  ## are not breeders. So N = 2, counts = {4, 2}, kbar = 3, Vk = var(4, 2) = 2.
  ##   Ne = (2*3 - 1) / (3 - 1 + 2/3) = 5 / (8/3) = 15/8 = 1.875
  ## The bare (4N-4)/(Vk+2) form would give (4)/(4) = 1.0, so pinning 1.875
  ## distinguishes the ratified general form from the bare one. kbar = 3 != 2
  ## is essential: at kbar == 2 the two forms coincide and this would not test
  ## the variant.
  discPed <- data.frame(
    id   = c("S1", "D1", "K1", "K2", "K3", "K4", "K5", "K6"),
    sire = c(NA, NA, "S1", "S1", "S1", "S1", "U0001", "U0001"),
    dam  = c(NA, NA, "U0002", "U0002", "U0002", "U0002", "D1", "D1"),
    sex  = c("M", "F", "M", "F", "M", "F", "M", "F"),
    exit = c(NA, NA, NA, NA, NA, NA, NA, NA),
    stringsAsFactors = FALSE
  )
  expect_equal(calcNeVariance(discPed), 1.875)
})

test_that("calcNeVariance is maximal at equal families (Vk = 0) and falls with skew", {
  ## equalPed: S1 (3 offspring) and D1 (3 offspring), same U-id co-parent trick.
  ## N = 2, counts = {3, 3}, kbar = 3, Vk = 0 -> Ne = (2*3-1)/(3-1) = 5/2 = 2.5.
  ## This is the maximum for a two-breeder pool at kbar = 3 (Vk = 0 minimizes
  ## the denominator).
  equalPed <- data.frame(
    id   = c("S1", "D1", "K1", "K2", "K3", "K4", "K5", "K6"),
    sire = c(NA, NA, "S1", "S1", "S1", "U0001", "U0001", "U0001"),
    dam  = c(NA, NA, "U0002", "U0002", "U0002", "D1", "D1", "D1"),
    sex  = c("M", "F", "M", "F", "M", "F", "M", "F"),
    exit = c(NA, NA, NA, NA, NA, NA, NA, NA),
    stringsAsFactors = FALSE
  )
  ## skewPed: same N = 2 and kbar = 3, but counts = {4, 2} (Vk = 2) -> Ne = 1.875.
  ## Only the variance differs, so it isolates the reproductive-skew effect.
  skewPed <- data.frame(
    id   = c("S1", "D1", "K1", "K2", "K3", "K4", "K5", "K6"),
    sire = c(NA, NA, "S1", "S1", "S1", "S1", "U0001", "U0001"),
    dam  = c(NA, NA, "U0002", "U0002", "U0002", "U0002", "D1", "D1"),
    sex  = c("M", "F", "M", "F", "M", "F", "M", "F"),
    exit = c(NA, NA, NA, NA, NA, NA, NA, NA),
    stringsAsFactors = FALSE
  )
  equalNe <- calcNeVariance(equalPed)
  skewNe <- calcNeVariance(skewPed)
  expect_equal(equalNe, 2.5)
  expect_equal(skewNe, 1.875)
  ## reproductive skew lowers the variance effective size
  expect_gt(equalNe, skewNe)
})

test_that("calcNeVariance returns NA when there are fewer than 2 living breeders", {
  ## onePed: only S1 is a living breeder (U0001 excluded, kids not breeders).
  ## N = 1 -> Vk undefined -> NA.
  onePed <- data.frame(
    id   = c("S1", "K1", "K2"),
    sire = c(NA, "S1", "S1"),
    dam  = c(NA, "U0001", "U0001"),
    sex  = c("M", "M", "F"),
    exit = c(NA, NA, NA),
    stringsAsFactors = FALSE
  )
  ## noBreederPed: two founders, nobody appears as a parent. N = 0 -> NA.
  noBreederPed <- data.frame(
    id   = c("A", "B"),
    sire = c(NA, NA),
    dam  = c(NA, NA),
    sex  = c("M", "F"),
    exit = c(NA, NA),
    stringsAsFactors = FALSE
  )
  expect_true(is.na(calcNeVariance(onePed)))
  expect_true(is.na(calcNeVariance(noBreederPed)))
})

test_that("calcNeVariance counts only living, non-U, breeding animals (getLivingBreeders)", {
  ## Same living breeders as discPed (S1 = 4, D1 = 2 -> Ne = 1.875), plus a DEAD
  ## breeder Sdead with 3 offspring (via U0003) that must be excluded. If Sdead
  ## were counted, N = 3, counts = {4, 2, 3}, kbar = 3, Vk = 1 -> Ne = 3.43, so
  ## pinning 1.875 confirms the living-breeder filter is applied.
  exclPed <- data.frame(
    id   = c("S1", "D1", "Sdead",
             "K1", "K2", "K3", "K4", "K5", "K6", "K7", "K8", "K9"),
    sire = c(NA, NA, NA,
             "S1", "S1", "S1", "S1", "U0001", "U0001",
             "Sdead", "Sdead", "Sdead"),
    dam  = c(NA, NA, NA,
             "U0002", "U0002", "U0002", "U0002", "D1", "D1",
             "U0003", "U0003", "U0003"),
    sex  = c("M", "F", "M",
             "M", "F", "M", "F", "M", "F", "M", "F", "M"),
    exit = c(NA, NA, "2019-01-01",
             NA, NA, NA, NA, NA, NA, NA, NA, NA),
    stringsAsFactors = FALSE
  )
  expect_equal(calcNeVariance(exclPed), 1.875)
})

test_that("calcNeVariance returns a length-1 numeric scalar", {
  discPed <- data.frame(
    id   = c("S1", "D1", "K1", "K2", "K3", "K4", "K5", "K6"),
    sire = c(NA, NA, "S1", "S1", "S1", "S1", "U0001", "U0001"),
    dam  = c(NA, NA, "U0002", "U0002", "U0002", "U0002", "D1", "D1"),
    sex  = c("M", "F", "M", "F", "M", "F", "M", "F"),
    exit = c(NA, NA, NA, NA, NA, NA, NA, NA),
    stringsAsFactors = FALSE
  )
  ne <- calcNeVariance(discPed)
  expect_type(ne, "double")
  expect_length(ne, 1L)
})

test_that("calcNeVariance on qcPed is a finite positive effective size", {
  ## Deterministic pure function of the bundled pedigree (no RNG). qcPed has 18
  ## living breeders whose family sizes are more even than Poisson (Vk < kbar),
  ## so the variance effective size exceeds the census count -- a legitimate
  ## feature of Ne_v, not a bug.
  ne <- calcNeVariance(nprcgenekeepr::qcPed)
  expect_length(ne, 1L)
  expect_true(is.finite(ne))
  expect_gt(ne, 0)
  expect_equal(ne, 26.405868, tolerance = 1e-6)
})

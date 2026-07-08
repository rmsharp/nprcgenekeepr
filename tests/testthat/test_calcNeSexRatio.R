## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# ---------------------------------------------------------------------------
# Issue #118 Slice 2 (E2): calcNeSexRatio(ped) is the demographic sex-ratio
# effective size, Ne_sr = 4 * Nm * Nf / (Nm + Nf), where Nm and Nf are the
# counts of CURRENT LIVING BREEDERS (getLivingBreeders()) that are known male
# (sex == "M") and known female (sex == "F"). It measures the diversity loss
# from an unequal breeding sex ratio and is a deterministic pure function of the
# pedigree (no gene drop, no seed). Degeneracy (owner decision D-c): when either
# sex is absent among living breeders (Nm == 0 or Nf == 0, including no living
# breeders at all, where the raw formula is 0/0), Ne_sr = 0 -- a single breeding
# sex contributes no effective diversity from sex balance.
# ---------------------------------------------------------------------------

test_that("calcNeSexRatio returns 2k for a balanced pool (Nm == Nf == k)", {
  ## 3 male + 3 female living breeders: 4*3*3/(3+3) = 6 = 2 * 3
  balancedPed <- data.frame(
    id   = c("S1", "S2", "S3", "D1", "D2", "D3", "K1", "K2", "K3"),
    sire = c(NA, NA, NA, NA, NA, NA, "S1", "S2", "S3"),
    dam  = c(NA, NA, NA, NA, NA, NA, "D1", "D2", "D3"),
    sex  = c("M", "M", "M", "F", "F", "F", "F", "M", "F"),
    exit = c(NA, NA, NA, NA, NA, NA, NA, NA, NA),
    stringsAsFactors = FALSE
  )
  expect_equal(calcNeSexRatio(balancedPed), 6)
})

test_that("calcNeSexRatio drops toward the rarer sex in a harem (Nm=1, Nf=9)", {
  ## one breeding male over nine breeding females: 4*1*9/(1+9) = 3.6
  haremPed <- data.frame(
    id   = c("S1", paste0("D", 1:9), paste0("K", 1:9)),
    sire = c(NA, rep(NA, 9L), rep("S1", 9L)),
    dam  = c(NA, rep(NA, 9L), paste0("D", 1:9)),
    sex  = c("M", rep("F", 9L), rep("M", 9L)),
    exit = rep(NA, 19L),
    stringsAsFactors = FALSE
  )
  expect_equal(calcNeSexRatio(haremPed), 3.6)
})

test_that("calcNeSexRatio is 0 when one breeding sex is absent (D-c)", {
  ## two breeding males, no breeding females: Nf == 0 -> Ne_sr = 0
  oneSexPed <- data.frame(
    id   = c("S1", "S2", "K1", "K2"),
    sire = c(NA, NA, "S1", "S2"),
    dam  = c(NA, NA, NA, NA),
    sex  = c("M", "M", "F", "F"),
    exit = c(NA, NA, NA, NA),
    stringsAsFactors = FALSE
  )
  expect_equal(calcNeSexRatio(oneSexPed), 0)
})

test_that("calcNeSexRatio is 0 when there are no living breeders (0/0 guard)", {
  ## nobody is a parent: Nm == Nf == 0 (the raw formula is 0/0) -> Ne_sr = 0
  emptyBreederPed <- data.frame(
    id   = c("A", "B"),
    sire = c(NA, NA),
    dam  = c(NA, NA),
    sex  = c("M", "F"),
    exit = c(NA, NA),
    stringsAsFactors = FALSE
  )
  expect_equal(calcNeSexRatio(emptyBreederPed), 0)
})

test_that("calcNeSexRatio counts only living, known-sex, real breeders", {
  ## Only S1 (living M breeder) and D1 (living F breeder) count -> Nm=1, Nf=1,
  ## Ne_sr = 4*1*1/(1+1) = 2. Each of these would inflate Nm/Nf if not excluded:
  ##  - S2dead: a male sire but dead (exit set)         -> excluded
  ##  - U0001:  a male-typed generated-unknown sire      -> excluded (U-id)
  ##  - Dh:     a living dam but sex "H" (hermaphrodite) -> not counted as F
  ## If any exclusion failed, Ne_sr would be > 2 (2.67 or 3), so the exact value
  ## 2 pins all of them at once.
  exclusionPed <- data.frame(
    id   = c("S1", "S2dead", "D1", "Dh", "U0001",
             "K1", "K2", "K3", "K4"),
    sire = c(NA, NA, NA, NA, NA, "S1", "S2dead", "U0001", "S1"),
    dam  = c(NA, NA, NA, NA, NA, "D1", "D1", "Dh", "D1"),
    sex  = c("M", "M", "F", "H", "M", "F", "M", "F", "M"),
    exit = c(NA, "2019-06-01", NA, NA, NA, NA, NA, NA, NA),
    stringsAsFactors = FALSE
  )
  expect_equal(calcNeSexRatio(exclusionPed), 2)
})

test_that("calcNeSexRatio returns a length-1 numeric scalar", {
  balancedPed <- data.frame(
    id   = c("S1", "D1", "K1"),
    sire = c(NA, NA, "S1"),
    dam  = c(NA, NA, "D1"),
    sex  = c("M", "F", "F"),
    exit = c(NA, NA, NA),
    stringsAsFactors = FALSE
  )
  ne <- calcNeSexRatio(balancedPed)
  expect_type(ne, "double")
  expect_length(ne, 1L)
})

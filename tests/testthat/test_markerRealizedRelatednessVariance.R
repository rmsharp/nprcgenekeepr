## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (issue #153 Slice 3): markerRealizedRelatednessVariance() estimates the
## variance of the ACTUAL (realized) proportion of genome shared IBD around a
## pair's PEDIGREE-EXPECTED relationship R = 2*kinship, for Parent-Offspring,
## Full-Siblings, and Half-Siblings pairs (D3a) -- per
##
##   Hill, W.G. & Weir, B.S. (2011). "Variation in actual relationship as a
##   consequence of Mendelian sampling and linkage." Genetics Research 93(1):
##   47-64. PMC3070763.
##
## Box 1 formulas (derived/verified this session's own PRE-RED, not copied
## from any planned implementation):
##
##   phi_n(l) = 1/(2*l^2) * (1/4)^n * sum_{r=1}^{n} choose(n,r) *
##              (2*r*l - 1 + exp(-2*r*l)) / r^2,   n >= 1;  phi_0(l) = 0
##
##   Var(R-breve)_FullSib(l)    = 2*phi_2(l) - phi_1(l)
##   Var(R-breve)_HalfSib(l)    = phi_2(l) - 0.5*phi_1(l)
##   Var(R-breve)_ParentOff(l)  = phi_0(l) = 0   (exactly 1 allele always IBD)
##
## Multi-chromosome combination: the paper states an explicit weighted-sum
## rule (its eqn 5) only for lineal descendants. For Full-Sib/Half-Sib it
## states in prose only that K equal-length chromosomes (l = mapLength/nChr)
## closely approximates a real heterogeneous-length genome -- this session
## verified that claim numerically against the paper's own Table 2 (a real
## 22-chromosome human map, lengths 0.75-2.75 Morgans, total 35.9 Morgans):
## the equal-length approximation and the exact heterogeneous-length weighted
## sum agree with each other to 4 decimal places (SD_FS 0.03840 vs 0.03842;
## SD_HS 0.02715 vs 0.02717), and both land within ~2% of Table 2's own
## published SD_FS=0.0392 / SD_HS=0.0277 -- the residual gap is attributed to
## Table 2's additional sex-specific-map refinement (lambda), which this
## simpler chromosome-count/map-length interface deliberately does not
## implement.
##
## Reference values in this file were computed independently via a
## standalone R snippet implementing the closed-form equations above (not
## this package's planned implementation), so they are an independent
## oracle. smallPed's Full-Siblings (F/G), Half-Siblings (C/I), and
## Parent-Offspring (D/G) pairs are reused directly from the existing,
## already-verified test_convertRelationships.R fixture rather than a new
## hand-built pedigree.

library(testthat)

ped <- nprcgenekeepr::smallPed
kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)

test_that("markerRealizedRelatednessVariance errors on missing/malformed pedigree", {
  expect_error(
    markerRealizedRelatednessVariance(kmat, ped = NULL, nChr = 20L, mapLength = 28),
    "pedigree"
  )
  badPed <- ped[, c("id", "sire")] # missing 'dam'
  expect_error(
    markerRealizedRelatednessVariance(kmat, badPed, nChr = 20L, mapLength = 28),
    "pedigree"
  )
})

test_that("markerRealizedRelatednessVariance errors on non-positive nChr or mapLength", {
  expect_error(
    markerRealizedRelatednessVariance(kmat, ped, nChr = 0L, mapLength = 28),
    "nChr"
  )
  expect_error(
    markerRealizedRelatednessVariance(kmat, ped, nChr = -1L, mapLength = 28),
    "nChr"
  )
  expect_error(
    markerRealizedRelatednessVariance(kmat, ped, nChr = 20L, mapLength = 0),
    "mapLength"
  )
  expect_error(
    markerRealizedRelatednessVariance(kmat, ped, nChr = 20L, mapLength = -5),
    "mapLength"
  )
})

test_that(".hillWeirPhi matches hand-derived closed-form values at l = 1.6 Morgans", {
  expect_equal(.hillWeirPhi(1.6, 0L), 0)
  expect_equal(.hillWeirPhi(1.6, 1L), 0.1094122, tolerance = 1e-6)
  expect_equal(.hillWeirPhi(1.6, 2L), 0.07119067, tolerance = 1e-6)
})

test_that("single-chromosome Full-Sib/Half-Sib varR matches hand-derived values", {
  ## nChr = 1, mapLength = 1.6 -> the equal-length approximation collapses to
  ## the single-chromosome formula evaluated at l = mapLength directly.
  res <- markerRealizedRelatednessVariance(kmat, ped, nChr = 1L, mapLength = 1.6)
  fs <- res[res$id1 == "F" & res$id2 == "G", ]
  hs <- res[res$id1 == "C" & res$id2 == "I", ]
  expect_equal(fs$varR, 0.03296913, tolerance = 1e-6)
  expect_equal(hs$varR, 0.01648456, tolerance = 1e-6)
})

test_that("Parent-Offspring varR is exactly zero regardless of nChr/mapLength", {
  res1 <- markerRealizedRelatednessVariance(kmat, ped, nChr = 1L, mapLength = 1.6)
  res2 <- markerRealizedRelatednessVariance(kmat, ped, nChr = 22L, mapLength = 35.9)
  po1 <- res1[res1$id1 == "D" & res1$id2 == "G", ]
  po2 <- res2[res2$id1 == "D" & res2$id2 == "G", ]
  expect_equal(po1$varR, 0)
  expect_equal(po2$varR, 0)
})

test_that("human-genome-scale Full-Sib/Half-Sib sdR approximately matches Hill & Weir Table 2", {
  ## nChr = 22, mapLength = 35.9 (Kong et al. 2004 human autosomal map,
  ## as tabulated in Hill & Weir 2011 Table 2). Reference values are this
  ## session's own independently-derived numbers (equal-length-chromosome
  ## approximation), not a copy of Table 2's 0.0392/0.0277 -- see the
  ## file-header note on the ~2% documented residual.
  res <- markerRealizedRelatednessVariance(kmat, ped, nChr = 22L, mapLength = 35.9)
  fs <- res[res$id1 == "F" & res$id2 == "G", ]
  hs <- res[res$id1 == "C" & res$id2 == "I", ]
  expect_equal(fs$sdR, 0.03840076, tolerance = 1e-6)
  expect_equal(hs$sdR, 0.02715344, tolerance = 1e-6)
  ## Literature-grounding sanity check: within ~2% of the published Table 2
  ## SDs, not an exact-match assertion.
  expect_true(abs(fs$sdR - 0.0392) / 0.0392 < 0.03)
  expect_true(abs(hs$sdR - 0.0277) / 0.0277 < 0.03)
})

test_that("markerRealizedRelatednessVariance classifies smallPed pairs, NA outside PO/FS/HS", {
  res <- markerRealizedRelatednessVariance(kmat, ped, nChr = 20L, mapLength = 28)

  expect_identical(res$relation[res$id1 == "D" & res$id2 == "G"], "Parent-Offspring")
  expect_identical(res$relation[res$id1 == "F" & res$id2 == "G"], "Full-Siblings")
  expect_identical(res$relation[res$id1 == "C" & res$id2 == "I"], "Half-Siblings")
  expect_false(is.na(res$varR[res$id1 == "D" & res$id2 == "G"]))
  expect_false(is.na(res$varR[res$id1 == "F" & res$id2 == "G"]))
  expect_false(is.na(res$varR[res$id1 == "C" & res$id2 == "I"]))

  ## Out-of-scope relationship categories: varR/sdR are NA, not an error.
  expect_identical(res$relation[res$id1 == "A" & res$id2 == "B"], "No Relation")
  expect_true(is.na(res$varR[res$id1 == "A" & res$id2 == "B"]))
  expect_identical(res$relation[res$id1 == "A" & res$id2 == "F"], "Grandparent-Grandchild")
  expect_true(is.na(res$varR[res$id1 == "A" & res$id2 == "F"]))
})

test_that("markerRealizedRelatednessVariance respects the ids restriction parameter", {
  ids <- c("D", "G", "F", "C", "I")
  res <- markerRealizedRelatednessVariance(kmat, ped, nChr = 20L, mapLength = 28, ids = ids)
  expect_true(all(res$id1 %in% ids))
  expect_true(all(res$id2 %in% ids))
  expect_true(nrow(res) < nrow(markerRealizedRelatednessVariance(
    kmat, ped,
    nChr = 20L, mapLength = 28
  )))
})

test_that("markerRealizedRelatednessVariance returns the documented data frame shape", {
  res <- markerRealizedRelatednessVariance(kmat, ped, nChr = 20L, mapLength = 28)
  expect_s3_class(res, "data.frame")
  expect_identical(
    names(res),
    c("id1", "id2", "kinship", "relation", "R", "varR", "sdR")
  )
  expect_equal(res$R, 2 * res$kinship)
})

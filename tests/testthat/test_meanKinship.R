## Copyright(c) 2017-2026 R. Mark Sharp
# This file is part of nprcgenekeepr
library(testthat)
set_seed(10L)
samp <- c(0.0, 0.5, 0.25, 0.125, 0.0625, 0.03125, 0.015625)
kmat <- sample(samp, 25L, replace = TRUE)
kmat <- matrix(kmat, nrow = 5L)

test_that("meanKinship averages column correctly", {
  expect_identical(kmat[[1L]], mean(kmat[[1L]]))
  expect_identical(kmat[[2L]], mean(kmat[[2L]]))
  expect_identical(kmat[[5L]], mean(kmat[[5L]]))
})

## kinship(sparse = TRUE) returns a Matrix package matrix; meanKinship() takes
## it as it takes the dense one (S1096: base colMeans() refuses it, so the
## package no longer importing Matrix must not change this).
test_that("meanKinship() gives a sparse kinship matrix the dense matrix's means", {
  ped <- nprcgenekeepr::qcPed
  dense <- kinship(ped$id, ped$sire, ped$dam, ped$gen)
  sparse <- kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = TRUE)
  expect_s4_class(sparse, "dgCMatrix")
  expect_identical(meanKinship(sparse), meanKinship(dense))
})

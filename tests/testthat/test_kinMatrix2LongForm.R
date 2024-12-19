#' Copyright(c) 2017-2024 R. Mark Sharp
# This file is part of nprcgenekeepr
context("kinMatrix2LongForm")
library(testthat)

ped <- nprcgenekeepr::lacy1989Ped
ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen)
reformattedKmat <- kinMatrix2LongForm(kmat, removeDups = FALSE)
reformattedNoDupsKmat <- kinMatrix2LongForm(kmat, removeDups = TRUE)

test_that("kinMatrix2LongForm makes correct transformation", {
  expect_equal(reformattedKmat[1, 3], as.numeric(kmat[1, 1]))
  expect_equal(reformattedKmat[3, 3], as.numeric(kmat[1, 3]))
  expect_equal(reformattedKmat[5, 3], as.numeric(kmat[1, 5]))
  expect_equal(reformattedKmat[10, 3], as.numeric(kmat[2, 3]))
  expect_equal(reformattedNoDupsKmat[9, 3], as.numeric(kmat[2, 3]))
})

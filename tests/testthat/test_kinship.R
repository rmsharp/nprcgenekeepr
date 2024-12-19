#' Copyright(c) 2017-2024 R. Mark Sharp
# This file is part of nprcgenekeepr
context("kinship")
library(testthat)
library(stringi)
data("lacy1989Ped")
ped <- lacy1989Ped

test_that("kinship makes correct calculations", {
  kmatSparse <- kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = TRUE)
  kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)
  expect_equal(as.numeric(kmatSparse), as.numeric(kmat))
  expect_equal(kmat[1, 1], 0.5)
  expect_equal(kmat[1, 3], 0.25)
  expect_equal(kmat[1, 5], 0.0)
  expect_equal(kmat[1, 6], 0.125)
  expect_equal(kmat[1, 2], 0.0)
  expect_equal(kmat[6, 2], 0.125)
})
ped <- rbind(ped, ped[1, ])
test_that("kinship detects duplicate record", {
  expect_error(kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = TRUE),
                "All id values must be unique", fixed = TRUE)
})

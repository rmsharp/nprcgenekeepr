#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("filterThreshold")
library(testthat)
data("lacy1989Ped")
ped <- lacy1989Ped

ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen)
kin <- kinMatrix2LongForm(kmat, removeDups = FALSE)
threshold <- 0.1
kinFiltered <- filterThreshold(kin, threshold = threshold)

test_that("filterThreshold makes correct transformation", {
  expect_equal(nrow(kinFiltered), 39)
  expect_equal(kinFiltered[1, 3], kin[1, 3])
  expect_equal(kinFiltered[2, 3], kin[3, 3])
  expect_equal(kinFiltered[4, 3], kin[6, 3])
  expect_equal(kinFiltered[11, 3], kin[15, 3])
  expect_equal(kinFiltered[24, 3], kin[34, 3])
  expect_equal(kinFiltered[1, 2], kin[1, 2])
  expect_equal(kinFiltered[2, 2], kin[3, 2])
  expect_equal(kinFiltered[4, 2], kin[6, 2])
  expect_equal(kinFiltered[11, 2], kin[15, 2])
  expect_equal(kinFiltered[24, 2], kin[34, 2])
})

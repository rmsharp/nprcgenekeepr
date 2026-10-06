## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)
data("ped1Alleles")

test_that("calcA forms dataframe with correct calculations", {
  rare <- calcA(ped1Alleles, threshold = 3L, byID = FALSE)
  expect_equal(sum(rare[, 1L]), 318L)
  expect_equal(sum(rare[, 2L]), 325L)
  expect_equal(sum(rare[, 3L]), 313L)
  expect_equal(sum(rare[, 4L]), 328L)
})

# S925: with one animal, apply() collapsed calcA()'s one-row result to a bare
# vector and lost the animal's id, so calcGU() and calcGUSE() stopped.
test_that("calcA keeps a one-row table named for a single animal (S925)", {
  oneId <- ped1Alleles$id[1L]
  one <- ped1Alleles[ped1Alleles$id == oneId, ]
  iterations <- setdiff(names(ped1Alleles), c("id", "parent"))
  ## Alone, an animal's two alleles at an iteration are rare (frequency 1)
  ## unless they are the same allele (frequency 2).
  expected <- ifelse(
    unlist(one[1L, iterations]) != unlist(one[2L, iterations]), 2L, 0L
  )

  rare <- calcA(one, threshold = 1L, byID = FALSE)
  expect_true(is.matrix(rare))
  expect_identical(dim(rare), c(1L, length(iterations)))
  expect_identical(rownames(rare), oneId)
  expect_identical(colnames(rare), iterations)
  expect_identical(rare[1L, ], expected)

  ## byID counts each distinct allele once per animal, so both copies are rare.
  rareByID <- calcA(one, threshold = 1L, byID = TRUE)
  expect_true(is.matrix(rareByID))
  expect_identical(rownames(rareByID), oneId)
  expect_identical(unname(rareByID[1L, ]), rep(2L, length(iterations)))
})

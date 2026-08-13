## Copyright(c) 2017-2026 R. Mark Sharp
# This file is part of nprcgenekeepr
library(testthat)
data("lacy1989Ped")
ped <- lacy1989Ped

test_that("kinship makes correct calculations", {
  kmatSparse <- kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = TRUE)
  kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)
  expect_identical(as.numeric(kmatSparse), as.numeric(kmat))
  expect_equal(kmat[1L, 1L], 0.5)
  expect_equal(kmat[1L, 3L], 0.25)
  expect_equal(kmat[1L, 5L], 0.0)
  expect_equal(kmat[1L, 6L], 0.125)
  expect_equal(kmat[1L, 2L], 0.0)
  expect_equal(kmat[6L, 2L], 0.125)
})
ped <- rbind(ped, ped[1L, ])
test_that("kinship detects duplicate record", {
  expect_error(kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = TRUE),
    "All id values must be unique",
    fixed = TRUE
  )
})

## Fixture reconstructed from the kinship2 supplementary-material PDF's Figure
## S1 (docs/audits/KINSHIP2_SUPPLEMENT_REPRODUCIBILITY_AUDIT_2026-08-13.md):
## subjects 8 and 9 are full siblings declared as an MZ-twin pair; subject 10
## is a child of twin 8 (not a twin themself), the load-bearing
## propagates-to-a-descendant case.
fam1 <- data.frame(
  id   = as.character(1:10),
  sire = c(NA, NA, "1", "1", NA, NA, "3", "6", "6", "8"),
  dam  = c(NA, NA, "2", "2", NA, NA, "5", "4", "4", "7"),
  stringsAsFactors = FALSE
)
fam1$gen <- findGeneration(fam1$id, fam1$sire, fam1$dam)

test_that("kinship() with twinRelations corrects MZ-twin identity and
  propagates to a non-twin descendant", {
  twins <- data.frame(id1 = "8", id2 = "9", code = "MZ twin",
    stringsAsFactors = FALSE)
  kmat <- kinship(fam1$id, fam1$sire, fam1$dam, fam1$gen, twinRelations = twins)
  expect_equal(kmat["8", "9"], 0.5)
  expect_equal(kmat["9", "10"], 0.28125)
})

test_that("kinship() with twinRelations gives identical results for
  sparse = TRUE and sparse = FALSE", {
  twins <- data.frame(id1 = "8", id2 = "9", code = "MZ twin",
    stringsAsFactors = FALSE)
  kmatDense <- kinship(fam1$id, fam1$sire, fam1$dam, fam1$gen,
    sparse = FALSE, twinRelations = twins)
  kmatSparse <- kinship(fam1$id, fam1$sire, fam1$dam, fam1$gen,
    sparse = TRUE, twinRelations = twins)
  expect_identical(as.numeric(kmatSparse), as.numeric(kmatDense))
})

test_that("kinship() without twinRelations is unaffected (backward
  compatibility)", {
  kmat <- kinship(fam1$id, fam1$sire, fam1$dam, fam1$gen)
  expect_equal(kmat["8", "9"], 0.25)
  expect_equal(kmat["9", "10"], 0.15625)
})

## 3-sibling trio exercising mzgrp's transitive union-find grouping: A-B
## declared MZ, B-C declared MZ should also identity-correct the undeclared
## A-C pair, not just the 2 declared pairs.
trio <- data.frame(
  id   = c("P1", "P2", "A", "B", "C"),
  sire = c(NA, NA, "P1", "P1", "P1"),
  dam  = c(NA, NA, "P2", "P2", "P2"),
  stringsAsFactors = FALSE
)
trio$gen <- findGeneration(trio$id, trio$sire, trio$dam)

test_that("kinship() propagates MZ identity transitively across a chained
  group", {
  twins <- data.frame(
    id1 = c("A", "B"), id2 = c("B", "C"),
    code = c("MZ twin", "MZ twin"), stringsAsFactors = FALSE
  )
  kmat <- kinship(trio$id, trio$sire, trio$dam, trio$gen, twinRelations = twins)
  expect_equal(kmat["A", "C"], kmat["A", "A"])
  expect_equal(kmat["A", "C"], 0.5)
})

test_that("kinship() applies zero correction for DZ/UZ-coded pairs", {
  for (twinCode in c("DZ twin", "UZ twin")) {
    twins <- data.frame(id1 = "A", id2 = "B", code = twinCode,
      stringsAsFactors = FALSE)
    kmat <- kinship(trio$id, trio$sire, trio$dam, trio$gen, twinRelations = twins)
    expect_equal(kmat["A", "B"], 0.25)
  }
})

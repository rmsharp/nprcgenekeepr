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
  sex  = c("M", "F", "M", "F", "F", "M", "F", "M", "M", "F"),
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

## Track A -- X-chromosome kinship (kinship2 supplement Table S2). Values
## transcribed directly from the PDF via `pdftotext -layout` against
## inst/extdata/reference/NIHMS593658-supplement-supplement_1.pdf, then
## cross-validated by hand-running kinship2's own deparsed X-linked algorithm
## (docs/planning/kinship2-supplement-full-reproduction-plan.md §3.1) against
## the fam1 fixture. Table S2's own printed values already embed the MZ-twin
## correction (Figure S1 declares subjects 8/9 identical twins), so this one
## fixture exercises both "reproduce Table S2" and the X-linked/MZ-twin
## interaction the plan calls out as untested by kinship2's own supplement.
test_that("kinship() with chrtype = 'x' reproduces the kinship2 supplement's
  Table S2, including the MZ-twin correction baked into subjects 8/9", {
  twins <- data.frame(id1 = "8", id2 = "9", code = "MZ twin",
    stringsAsFactors = FALSE)
  kmat <- kinship(fam1$id, fam1$sire, fam1$dam, fam1$gen,
    chrtype = "x", sex = fam1$sex, twinRelations = twins)
  expect_equal(kmat["1", "1"], 1.00) # male self-kinship = 1, not 0.5
  expect_equal(kmat["2", "2"], 0.50) # female self-kinship = 0.5, as autosomal
  expect_equal(kmat["1", "3"], 0.00) # father-son: no X transmitted
  expect_equal(kmat["1", "4"], 0.50) # father-daughter: X always transmitted
  expect_equal(kmat["2", "3"], 0.50) # mother-son: X always transmitted
  expect_equal(kmat["8", "9"], 1.00) # MZ twins, X-linked: identity, not 0.5
  expect_equal(kmat["9", "10"], 0.5625) # correction propagates to descendant
})

test_that("kinship() with chrtype = 'x' and no twinRelations differs from the
  twin-corrected matrix only at the twin-affected cells", {
  kmat <- kinship(fam1$id, fam1$sire, fam1$dam, fam1$gen,
    chrtype = "x", sex = fam1$sex)
  expect_equal(kmat["8", "9"], 0.50)
  expect_equal(kmat["9", "10"], 0.3125)
  # Unaffected cells are identical with or without the (absent) correction.
  expect_equal(kmat["1", "4"], 0.50)
  expect_equal(kmat["1", "1"], 1.00)
})

test_that("kinship() with chrtype = 'x' gives identical results for
  sparse = TRUE and sparse = FALSE", {
  kmatDense <- kinship(fam1$id, fam1$sire, fam1$dam, fam1$gen,
    chrtype = "x", sex = fam1$sex, sparse = FALSE)
  kmatSparse <- kinship(fam1$id, fam1$sire, fam1$dam, fam1$gen,
    chrtype = "x", sex = fam1$sex, sparse = TRUE)
  expect_identical(as.numeric(kmatSparse), as.numeric(kmatDense))
})

test_that("kinship() explicit chrtype = 'autosome' is byte-identical to
  omitting chrtype entirely (backward-compatibility pin)", {
  withChrtype <- kinship(fam1$id, fam1$sire, fam1$dam, fam1$gen,
    chrtype = "autosome")
  withoutChrtype <- kinship(fam1$id, fam1$sire, fam1$dam, fam1$gen)
  expect_identical(withChrtype, withoutChrtype)
})

test_that("kinship() with chrtype = 'x' validates its sex argument", {
  expect_error(
    kinship(fam1$id, fam1$sire, fam1$dam, fam1$gen, chrtype = "x"),
    "sex"
  )
  expect_error(
    kinship(fam1$id, fam1$sire, fam1$dam, fam1$gen,
      chrtype = "x", sex = fam1$sex[-1L]),
    "sex"
  )
})

test_that("kinship() rejects an unrecognized chrtype", {
  expect_error(
    kinship(fam1$id, fam1$sire, fam1$dam, fam1$gen,
      chrtype = "y", sex = fam1$sex),
    "should be one of"
  )
})

test_that("kinship() with chrtype = 'x' gives NA kinship for a subject with
  unknown sex", {
  sexUnknown <- fam1$sex
  sexUnknown[10L] <- "U"
  kmat <- kinship(fam1$id, fam1$sire, fam1$dam, fam1$gen,
    chrtype = "x", sex = sexUnknown)
  expect_true(all(is.na(kmat["10", ])))
  expect_true(all(is.na(kmat[, "10"])))
  # Unrelated cells elsewhere in the matrix are unaffected.
  expect_equal(kmat["1", "4"], 0.50)
})

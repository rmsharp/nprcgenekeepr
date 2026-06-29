## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# Issue #13 / issue #95 keep-all revert (S234): prepareKinshipOverrides() is the
# shared override-preparation helper that reportGV() and gvaConvergence() both
# use, so the two ranking paths cannot drift. Given a proband-filtered kinship
# matrix and the raw user override frame, it: validates the frame
# (checkKinshipOverrides), warn-drops rows naming ids outside the matrix (D5),
# and applies the survivors to the matrix (applyKinshipOverrides, the strict PSD
# leaf). It returns list(kmat = <patched>). The override REFINES a kinship cell;
# it never suppresses a focal's +sexMean/2 unknown-parent prior (keep-all), so
# there is no suppress set and no ped / candidateIds arguments.

# Tiny deterministic fixture with one one-unknown proband (C: sire known, dam
# missing) and two both-known probands (A, B). Mean kinship is read straight off
# the matrix, so the helper's behavior is deterministic.
makePrepFixture <- function() {
  ped <- data.frame(
    id   = c("F1", "F2", "F3", "F4", "A", "B", "C"),
    sire = c(NA, NA, NA, NA, "F1", "F1", "F2"),
    dam  = c(NA, NA, NA, NA, "F3", "F4", NA),
    sex  = c("M", "M", "M", "F", "F", "M", "M"),
    stringsAsFactors = FALSE
  )
  ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
  probands <- c("A", "B", "C")
  kmat <- nprcgenekeepr:::filterKinMatrix(
    probands, kinship(ped$id, ped$sire, ped$dam, ped$gen)
  )
  list(ped = ped, probands = probands, kmat = kmat)
}

test_that("prepareKinshipOverrides is a no-op for NULL or zero-row overrides", {
  fx <- makePrepFixture()

  resNull <- nprcgenekeepr:::prepareKinshipOverrides(fx$kmat, NULL)
  expect_equal(resNull$kmat, fx$kmat)
  ## keep-all revert: the return carries only kmat, no suppress set
  expect_named(resNull, "kmat")
  expect_null(resNull$suppressIds)

  zero <- data.frame(
    id1 = character(0), id2 = character(0), kinship = numeric(0),
    stringsAsFactors = FALSE
  )
  resZero <- nprcgenekeepr:::prepareKinshipOverrides(fx$kmat, zero)
  expect_equal(resZero$kmat, fx$kmat)
  expect_named(resZero, "kmat")
  expect_null(resZero$suppressIds)
})

test_that("prepareKinshipOverrides applies the override to the matrix symmetrically", {
  fx <- makePrepFixture()
  ov <- data.frame(id1 = "A", id2 = "C", kinship = 0.1, stringsAsFactors = FALSE)
  res <- nprcgenekeepr:::prepareKinshipOverrides(fx$kmat, ov)
  expect_equal(res$kmat["A", "C"], 0.1)
  expect_equal(res$kmat["C", "A"], 0.1)
  ## keep-all revert: an override produces NO suppress set
  expect_named(res, "kmat")
  expect_null(res$suppressIds)
})

test_that("prepareKinshipOverrides warn-drops an out-of-set id and keeps the survivors (D5)", {
  fx <- makePrepFixture()
  ov <- data.frame(
    id1 = c("A", "A"), id2 = c("B", "ZZZ"), kinship = c(0.1, 0.1),
    stringsAsFactors = FALSE
  )
  expect_warning(
    res <- nprcgenekeepr:::prepareKinshipOverrides(fx$kmat, ov),
    "not in the analysis set"
  )
  expect_equal(res$kmat["A", "B"], 0.1)
  ## keep-all revert: no suppress set in the return
  expect_null(res$suppressIds)
})

test_that("prepareKinshipOverrides propagates the strict PSD-bound error", {
  fx <- makePrepFixture()
  ov <- data.frame(id1 = "A", id2 = "B", kinship = 0.9, stringsAsFactors = FALSE)
  expect_error(
    suppressWarnings(
      nprcgenekeepr:::prepareKinshipOverrides(fx$kmat, ov)
    ),
    "above the maximum"
  )
})

## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# Issue #95 option C, Slice 2: prepareKinshipOverrides() is the shared
# override-preparation helper that reportGV() and gvaConvergence() both use, so
# the two ranking paths cannot drift (the lockstep goal of this slice). Given a
# proband-filtered kinship matrix, the raw user override frame, the pedigree, and
# the candidate ids, it: validates the frame (checkKinshipOverrides), warn-drops
# rows naming ids outside the matrix (D5), applies the survivors to the matrix
# (applyKinshipOverrides, the strict PSD leaf), and computes the option-C
# suppress set -- the one-unknown focals named by a non-blank missingSideFor
# (case a) when that column is present, else the full overridden set (blanket-A,
# D10). It returns list(kmat = <patched>, suppressIds = <to suppress>).

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

  resNull <- nprcgenekeepr:::prepareKinshipOverrides(
    fx$kmat, NULL, fx$ped, fx$probands
  )
  expect_equal(resNull$kmat, fx$kmat)
  expect_length(resNull$suppressIds, 0L)

  zero <- data.frame(
    id1 = character(0), id2 = character(0), kinship = numeric(0),
    stringsAsFactors = FALSE
  )
  resZero <- nprcgenekeepr:::prepareKinshipOverrides(
    fx$kmat, zero, fx$ped, fx$probands
  )
  expect_equal(resZero$kmat, fx$kmat)
  expect_length(resZero$suppressIds, 0L)
})

test_that("prepareKinshipOverrides applies the override to the matrix symmetrically", {
  fx <- makePrepFixture()
  ov <- data.frame(id1 = "A", id2 = "C", kinship = 0.1, stringsAsFactors = FALSE)
  res <- nprcgenekeepr:::prepareKinshipOverrides(fx$kmat, ov, fx$ped, fx$probands)
  expect_equal(res$kmat["A", "C"], 0.1)
  expect_equal(res$kmat["C", "A"], 0.1)
})

test_that("prepareKinshipOverrides with NO missingSideFor column suppresses the full set (blanket-A, D10)", {
  fx <- makePrepFixture()
  ov <- data.frame(id1 = "A", id2 = "C", kinship = 0.1, stringsAsFactors = FALSE)
  res <- nprcgenekeepr:::prepareKinshipOverrides(fx$kmat, ov, fx$ped, fx$probands)
  expect_true(setequal(res$suppressIds, c("A", "C")))
})

test_that("prepareKinshipOverrides suppresses only the missing-side focal (option C, case a)", {
  fx <- makePrepFixture()
  # C is one-unknown (dam missing); the override stands in for its missing side
  ov <- data.frame(
    id1 = "A", id2 = "C", kinship = 0.1, missingSideFor = "C",
    stringsAsFactors = FALSE
  )
  res <- nprcgenekeepr:::prepareKinshipOverrides(fx$kmat, ov, fx$ped, fx$probands)
  expect_true(setequal(res$suppressIds, "C"))
})

test_that("prepareKinshipOverrides keeps the prior for a known-side (blank) override (option C, case b)", {
  fx <- makePrepFixture()
  # blank missingSideFor = known-side: do NOT suppress -- C keeps its +sexMean/2
  ov <- data.frame(
    id1 = "A", id2 = "C", kinship = 0.1, missingSideFor = "",
    stringsAsFactors = FALSE
  )
  res <- nprcgenekeepr:::prepareKinshipOverrides(fx$kmat, ov, fx$ped, fx$probands)
  expect_length(res$suppressIds, 0L)
})

test_that("prepareKinshipOverrides ignores a missingSideFor naming a non-one-unknown id", {
  fx <- makePrepFixture()
  # A and B are both-known; naming A as the missing-side focal must not suppress
  ov <- data.frame(
    id1 = "A", id2 = "B", kinship = 0.1, missingSideFor = "A",
    stringsAsFactors = FALSE
  )
  res <- nprcgenekeepr:::prepareKinshipOverrides(fx$kmat, ov, fx$ped, fx$probands)
  expect_length(res$suppressIds, 0L)
})

test_that("prepareKinshipOverrides warn-drops an out-of-set id and keeps the survivors (D5)", {
  fx <- makePrepFixture()
  ov <- data.frame(
    id1 = c("A", "A"), id2 = c("B", "ZZZ"), kinship = c(0.1, 0.1),
    stringsAsFactors = FALSE
  )
  expect_warning(
    res <- nprcgenekeepr:::prepareKinshipOverrides(
      fx$kmat, ov, fx$ped, fx$probands
    ),
    "not in the analysis set"
  )
  expect_equal(res$kmat["A", "B"], 0.1)
  expect_true(setequal(res$suppressIds, c("A", "B")))
})

test_that("prepareKinshipOverrides propagates the strict PSD-bound error", {
  fx <- makePrepFixture()
  ov <- data.frame(id1 = "A", id2 = "B", kinship = 0.9, stringsAsFactors = FALSE)
  expect_error(
    suppressWarnings(
      nprcgenekeepr:::prepareKinshipOverrides(fx$kmat, ov, fx$ped, fx$probands)
    ),
    "above the maximum"
  )
})

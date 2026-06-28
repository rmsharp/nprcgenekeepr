#' Copyright(c) 2017-2026 R. Mark Sharp
#' This file is part of nprcgenekeepr
library(testthat)

# Issue #95 option C, Slice 1 (RATIFIED S227): classifyOverrideMissingSide(
# overrides, ped, candidateIds) returns the subset of candidateIds that are
# one-unknown (exactly one parent missing, via isU(ped$sire/dam)) AND named by a
# non-blank `missingSideFor` cell -- i.e. the focals whose MISSING-side
# relatedness an override stands in for (case a). These are the ids whose
# +sexMean/2 prior reportGV will suppress under option C. A blank / NA
# missingSideFor (known-side, case b), an absent column, a named id that is NOT
# one-unknown, and a NULL / zero-row frame all contribute nothing.

# Minimal pedigree: X, Z are one-unknown (sire missing); Y, W are both-known.
ovmsPed <- data.frame(
  id   = c("X", "Y", "Z", "W"),
  sire = c(NA, "sY", NA, "sW"),
  dam  = c("dX", "dY", "dZ", "dW"),
  stringsAsFactors = FALSE
)
ovmsCandidates <- c("X", "Y", "Z", "W")

ovmsFrame <- function(missingSideFor = NULL) {
  ov <- data.frame(
    id1 = "X", id2 = "Y", kinship = 0.25,
    stringsAsFactors = FALSE
  )
  if (!is.null(missingSideFor)) ov$missingSideFor <- missingSideFor
  ov
}

test_that("classifyOverrideMissingSide returns a one-unknown focal named by missingSideFor (case a)", {
  ov <- ovmsFrame(missingSideFor = "X")
  expect_setequal(
    nprcgenekeepr:::classifyOverrideMissingSide(ov, ovmsPed, ovmsCandidates),
    "X"
  )
})

test_that("classifyOverrideMissingSide excludes a blank missingSideFor (case b)", {
  ov <- ovmsFrame(missingSideFor = "")
  expect_identical(
    nprcgenekeepr:::classifyOverrideMissingSide(ov, ovmsPed, ovmsCandidates),
    character(0L)
  )
})

test_that("classifyOverrideMissingSide excludes an NA missingSideFor (treated as blank)", {
  ov <- ovmsFrame(missingSideFor = NA_character_)
  expect_identical(
    nprcgenekeepr:::classifyOverrideMissingSide(ov, ovmsPed, ovmsCandidates),
    character(0L)
  )
})

test_that("classifyOverrideMissingSide drops a named id that is NOT one-unknown (semantic check)", {
  ## Y is both-known -> naming it is a semantic no-op, must not suppress.
  ov <- ovmsFrame(missingSideFor = "Y")
  expect_identical(
    nprcgenekeepr:::classifyOverrideMissingSide(ov, ovmsPed, ovmsCandidates),
    character(0L)
  )
})

test_that("classifyOverrideMissingSide returns character(0L) when the column is absent", {
  ov <- ovmsFrame(missingSideFor = NULL)
  expect_identical(
    nprcgenekeepr:::classifyOverrideMissingSide(ov, ovmsPed, ovmsCandidates),
    character(0L)
  )
})

test_that("classifyOverrideMissingSide returns character(0L) for NULL or zero-row overrides", {
  expect_identical(
    nprcgenekeepr:::classifyOverrideMissingSide(NULL, ovmsPed, ovmsCandidates),
    character(0L)
  )
  ov0 <- ovmsFrame(missingSideFor = "X")[0L, , drop = FALSE]
  expect_identical(
    nprcgenekeepr:::classifyOverrideMissingSide(ov0, ovmsPed, ovmsCandidates),
    character(0L)
  )
})

test_that("classifyOverrideMissingSide handles multiple rows, returning only one-unknown focals", {
  ov <- data.frame(
    id1 = c("X", "Z"), id2 = c("Y", "W"), kinship = c(0.25, 0.125),
    missingSideFor = c("X", "W"), # X one-unknown (kept); W both-known (dropped)
    stringsAsFactors = FALSE
  )
  expect_setequal(
    nprcgenekeepr:::classifyOverrideMissingSide(ov, ovmsPed, ovmsCandidates),
    "X"
  )
})

## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Issue #13 item-3 follow-up R13 (Session 223): when outside-information
## kinship overrides are supplied, the relationship table's relation LABEL
## stays pedigree-derived while the kinship VALUE is overridden, so a pair can
## self-contradict (e.g. value 0.25 next to "No Relation"/"Other"). The
## display-layer helper flagOverriddenRelationships() marks the overridden
## pairs with a logical `overridden` column; convertRelationships is untouched.
## No override (NULL / zero-row) => output is byte-identical to today (D10).

context("flagOverriddenRelationships (issue #13 item-3 R13)")

makeRelFrame <- function() {
  data.frame(
    id1 = c("A", "A", "B"),
    id2 = c("B", "C", "C"),
    kinship = c(0, 0, 0),
    relation = c("No Relation", "No Relation", "No Relation"),
    stringsAsFactors = FALSE
  )
}

test_that("NULL overrides returns the input unchanged (D10)", {
  rel <- makeRelFrame()
  expect_identical(flagOverriddenRelationships(rel, NULL), rel)
})

test_that("zero-row overrides returns the input unchanged (D10)", {
  rel <- makeRelFrame()
  ov <- data.frame(
    id1 = character(0), id2 = character(0), kinship = numeric(0),
    stringsAsFactors = FALSE
  )
  expect_identical(flagOverriddenRelationships(rel, ov), rel)
})

test_that("overrides append a logical overridden column; originals kept", {
  rel <- makeRelFrame()
  ov <- data.frame(id1 = "A", id2 = "B", kinship = 0.25,
                   stringsAsFactors = FALSE)
  out <- flagOverriddenRelationships(rel, ov)
  expect_true("overridden" %in% names(out))
  expect_type(out$overridden, "logical")
  ## the original four columns are unchanged (values, order, types)
  expect_identical(out[names(rel)], rel)
})

test_that("the overridden pair is flagged TRUE, others FALSE", {
  rel <- makeRelFrame()
  ov <- data.frame(id1 = "A", id2 = "B", kinship = 0.25,
                   stringsAsFactors = FALSE)
  out <- flagOverriddenRelationships(rel, ov)
  expect_equal(out$overridden, c(TRUE, FALSE, FALSE))
})

test_that("an unordered (B, A) override flags the (A, B) row", {
  rel <- makeRelFrame()
  ov <- data.frame(id1 = "B", id2 = "A", kinship = 0.25,
                   stringsAsFactors = FALSE)
  out <- flagOverriddenRelationships(rel, ov)
  expect_equal(out$overridden, c(TRUE, FALSE, FALSE))
})

test_that("an override pair absent from the table flags nothing; no error", {
  rel <- makeRelFrame()
  ov <- data.frame(id1 = "A", id2 = "Z", kinship = 0.1,
                   stringsAsFactors = FALSE)
  out <- flagOverriddenRelationships(rel, ov)
  expect_equal(nrow(out), nrow(rel))
  expect_true("overridden" %in% names(out))
  expect_false(any(out$overridden))
})

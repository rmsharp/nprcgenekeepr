## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Tests for .extractKinship2Structure() -- Track A of the kinship2
## structural/topological comparison design (docs/planning/
## pedigree-diagram-kinship2-structural-comparison-plan.md sections 3.1/4.1).
## A pure, internal function with ZERO kinship2 dependency: it reads only
## plain id/findex/mindex vectors, so any list shaped like a kinship2
## `pedigree` object (or a hand-built stand-in) works without kinship2
## installed. Re-implements kinship2's own align.pedigree() spouselist
## derivation verbatim (plan section 1.1) -- not invented logic.
##
## Track A only: .extractNprcStructure() and .comparePedigreeStructures()
## are out of scope here (Tracks B/C, plan section 5's strict A->B->C->D
## order) and will get their own test_that() blocks in this file, or their
## own files, in a future session.

## ---- test helpers (not exported, local to this file) -------------------

## Combine parentChildEdges rows into one comparable key per row, so
## assertions don't depend on row order (the algorithm builds father rows
## then mother rows; a future refactor is free to change that order).
.pcKeys <- function(pc) paste(pc$child, pc$parent, pc$role, sep = "|")

## Named vector of nChildren by unordered parent pair, for order-independent
## matePairs assertions.
.mateNChildren <- function(mp) {
  key <- paste(pmin(mp$parent1, mp$parent2), pmax(mp$parent1, mp$parent2),
               sep = "|")
  stats::setNames(mp$nChildren, key)
}

## ---- input contract / return shape --------------------------------------

test_that(
  ".extractKinship2Structure returns a list with parentChildEdges/matePairs",
  {
  ped <- list(id = c("F1", "M1", "C1"), findex = c(0L, 0L, 1L),
              mindex = c(0L, 0L, 2L))
  result <- .extractKinship2Structure(ped)
  expect_true(is.list(result))
  expect_setequal(names(result), c("parentChildEdges", "matePairs"))
  expect_true(is.data.frame(result$parentChildEdges))
  expect_true(is.data.frame(result$matePairs))
  expect_setequal(names(result$parentChildEdges), c("child", "parent",
                                                      "role"))
  expect_setequal(names(result$matePairs), c("parent1", "parent2",
                                              "nChildren"))
})

## ---- founder-only: no known parents at all ------------------------------

test_that(
  ".extractKinship2Structure gives a lone founder zero edges and zero
   mate pairs", {
  ped <- list(id = "F1", findex = 0L, mindex = 0L)
  result <- .extractKinship2Structure(ped)
  expect_equal(nrow(result$parentChildEdges), 0L)
  expect_equal(nrow(result$matePairs), 0L)
})

## ---- single-known-parent: father-only and mother-only, never both -------

test_that(
  ".extractKinship2Structure gives a single-known-parent child exactly
   one edge, and contributes no mate pair", {
  ## C1's father (F1) is known, mother is not; C2's mother (M1) is known,
  ## father is not -- neither child has "both" parents known.
  ped <- list(id = c("F1", "M1", "C1", "C2"),
              findex = c(0L, 0L, 1L, 0L),
              mindex = c(0L, 0L, 0L, 2L))
  result <- .extractKinship2Structure(ped)
  expect_setequal(.pcKeys(result$parentChildEdges),
                   c("C1|F1|father", "C2|M1|mother"))
  expect_equal(nrow(result$parentChildEdges), 2L)
  expect_equal(nrow(result$matePairs), 0L)
})

## ---- multi-mate individual + shared-parent nChildren dedup --------------

test_that(
  ".extractKinship2Structure counts nChildren once per distinct mate pair,
   not once per child", {
  ## P1 has two distinct mates: P2 (3 shared children) and P3 (1 child).
  ped <- list(
    id = c("P1", "P2", "P3", "C1", "C2", "C3", "C4"),
    findex = c(0L, 0L, 0L, 1L, 1L, 1L, 1L),
    mindex = c(0L, 0L, 0L, 2L, 2L, 2L, 3L)
  )
  result <- .extractKinship2Structure(ped)
  expect_equal(nrow(result$matePairs), 2L)
  expect_equal(.mateNChildren(result$matePairs),
               c("P1|P2" = 3L, "P1|P3" = 1L))
  expect_equal(nrow(result$parentChildEdges), 8L)  # 4 father + 4 mother rows
})

## ---- combined 7-subject/2-mating fixture --------------------------------

test_that(
  ".extractKinship2Structure handles a combined multi-mating fixture
   (7 subjects, 2 real mate pairs, differing nChildren)", {
  ## Founders A, B, C, D. A x B -> X (1 child). C x D -> Y, Z (2 children).
  ped <- list(
    id = c("A", "B", "C", "D", "X", "Y", "Z"),
    findex = c(0L, 0L, 0L, 0L, 1L, 3L, 3L),
    mindex = c(0L, 0L, 0L, 0L, 2L, 4L, 4L)
  )
  result <- .extractKinship2Structure(ped)

  ## Founders never appear as a child.
  expect_false(any(c("A", "B", "C", "D") %in% result$parentChildEdges$child))

  expect_setequal(.pcKeys(result$parentChildEdges), c(
    "X|A|father", "X|B|mother",
    "Y|C|father", "Y|D|mother",
    "Z|C|father", "Z|D|mother"
  ))
  expect_equal(nrow(result$parentChildEdges), 6L)

  expect_equal(nrow(result$matePairs), 2L)
  expect_equal(.mateNChildren(result$matePairs),
               c("A|B" = 1L, "C|D" = 2L))
})

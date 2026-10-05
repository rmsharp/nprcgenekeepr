## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# getDescendantPedigree is the downward (descendants-only) mirror of
# getProbandPedigree: starting from a set of probands it takes the transitive
# closure over offspring (repeatedly getOffspring()) and returns the subset of
# the pedigree containing the probands and all of their descendants. It does
# NOT include collateral relatives (siblings, cousins, mates) -- that is the
# distinction from getPedDirectRelatives().
#
# lacy1989Ped structure:
#   A, B  founders
#   C     child of A, B
#   D     child of A, B
#   E     founder
#   F     child of D, E
#   G     child of D, E

data("lacy1989Ped")
ped <- lacy1989Ped

test_that("getDescendantPedigree returns probands and their transitive descendants", {
  # D's offspring are F and G; neither F nor G has offspring.
  expect_setequal(getDescendantPedigree(probands = "D", ped)$id,
    c("D", "F", "G"))

  # A's offspring are C and D; D's offspring are F and G. C has no offspring.
  # B and E are NOT descendants of A and must be excluded.
  expect_setequal(getDescendantPedigree(probands = "A", ped)$id,
    c("A", "C", "D", "F", "G"))
})

test_that("getDescendantPedigree returns only the proband when it has no offspring", {
  expect_setequal(getDescendantPedigree(probands = "F", ped)$id, "F")
  expect_setequal(getDescendantPedigree(probands = "C", ped)$id, "C")
})

test_that("getDescendantPedigree unions descendants of multiple probands", {
  # A's descendants {C, D, F, G} union E's descendants {F, G} plus the
  # probands {A, E} == everyone except founder B.
  expect_setequal(getDescendantPedigree(probands = c("A", "E"), ped)$id,
    c("A", "C", "D", "E", "F", "G"))
  expect_false("B" %in% getDescendantPedigree(probands = c("A", "E"), ped)$id)
})

test_that("getDescendantPedigree returns an empty pedigree for empty probands", {
  result <- getDescendantPedigree(probands = character(0L), ped)
  expect_equal(nrow(result), 0L)
})

test_that("getDescendantPedigree returns an empty pedigree for an absent proband", {
  result <- getDescendantPedigree(probands = "ZZZ", ped)
  expect_equal(nrow(result), 0L)
})

test_that("getDescendantPedigree terminates on a circular reference", {
  circ <- data.frame(
    id = c("A", "B"),
    sire = c("B", "A"), # circular!
    dam = c(NA_character_, NA_character_),
    stringsAsFactors = FALSE
  )
  expect_no_error(result <- getDescendantPedigree(probands = "A", circ))
  expect_setequal(result$id, c("A", "B"))
})

## PED-3 (BACKLOG; owner decision S912, Decision record 13; strict TDD, S915):
## the loop that collects the descendants moves into walkPedigree(). The tests
## below record what the function returns today (they pass at the commit that
## adds them) and check it asks walkPedigree() for its ids. The fixtures are in
## helper-walkPedigree.R.

test_that("getDescendantPedigree returns the pedigree's own rows in the pedigree's order", {
  expect_identical(
    getDescendantPedigree(probands = "A", ped),
    ped[ped$id %in% c("A", "C", "D", "F", "G"), ]
  )
  expect_identical(
    getDescendantPedigree(probands = c("E", "A"), ped)$id,
    c("A", "C", "D", "E", "F", "G")
  )
})

test_that("getDescendantPedigree copes with repeated and missing probands", {
  expect_identical(
    getDescendantPedigree(probands = c("D", "D"), ped)$id,
    c("D", "F", "G")
  )
  expect_identical(
    getDescendantPedigree(probands = c("A", NA), ped)$id,
    c("A", "C", "D", "F", "G")
  )
  expect_identical(nrow(getDescendantPedigree(probands = NA_character_, ped)), 0L)
})

test_that("getDescendantPedigree returns a row whose id is missing when it is an offspring", {
  pedMissing <- missingIdPed()
  expect_identical(
    getDescendantPedigree(probands = "A", pedMissing)$id,
    c("A", "C", "D", "F", "G", NA_character_)
  )
  expect_identical(
    getDescendantPedigree(probands = NA_character_, pedMissing)$id,
    NA_character_
  )
})

test_that("getDescendantPedigree stops on an animal that is its own sire", {
  expect_identical(
    withinSeconds(getDescendantPedigree(probands = "A", selfParentPed()))$id,
    "A"
  )
})

test_that("getDescendantPedigree asks walkPedigree() for the descendants of the probands", {
  skip_if_not_installed("mockery")
  ## Control: the real rule gives A and all four of its descendants.
  expect_identical(
    getDescendantPedigree(probands = "A", ped)$id,
    c("A", "C", "D", "F", "G")
  )
  ## A stand-in that finds nothing below A leaves only A.
  walker <- mockery::mock(list("A"))
  mockery::stub(getDescendantPedigree, "walkPedigree", walker)
  result <- getDescendantPedigree(probands = "A", ped)
  expectOneWalk(walker, ids = "A", ped = ped, direction = "descendants")
  expect_identical(result$id, "A")
})

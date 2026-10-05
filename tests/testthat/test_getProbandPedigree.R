## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

data("lacy1989Ped")
ped <- lacy1989Ped
test_that("getProbandPedigree returns the correct pedigree", {
  expect_true(all(getProbandPedigree(probands = c("A", "B"), ped)$id %in%
    c("A", "B")))
  expect_true(all(getProbandPedigree(probands = c("A", "B", "E"), ped)$id %in%
    c("A", "B", "E")))
  expect_true(all(getProbandPedigree(probands = "F", ped)$id %in%
    c("A", "B", "D", "E", "F")))
  expect_true(all(c("A", "B", "D", "E", "F") %in%
    getProbandPedigree(probands = c("F"), ped)$id))
  expect_true(all(getProbandPedigree(probands = "D", ped)$id %in%
    c("A", "B", "D")))
  expect_true(all(c("A", "B", "D") %in%
    getProbandPedigree(probands = "D", ped)$id))
})

## PED-3 (BACKLOG; owner decision S912, Decision record 13; strict TDD, S915):
## the loop that collects the ancestors moves into walkPedigree(). Two kinds of
## test follow. The first group records what the function returns today, so
## the move cannot change it (those pass at the commit that adds them). The
## second group checks the function asks walkPedigree() for its ids. The
## fixtures are in helper-walkPedigree.R.

test_that("getProbandPedigree returns the pedigree's own rows for the probands and their ancestors", {
  expect_identical(
    getProbandPedigree(probands = "F", ped),
    ped[ped$id %in% c("A", "B", "D", "E", "F"), ]
  )
  ## Rows come back in the pedigree's order, not the order the probands or
  ## their parents were found in.
  expect_identical(
    getProbandPedigree(probands = c("G", "C"), ped)$id,
    c("A", "B", "C", "D", "E", "G")
  )
})

test_that("getProbandPedigree copes with repeated, missing and absent probands", {
  expect_identical(
    getProbandPedigree(probands = c("D", "D"), ped)$id,
    c("A", "B", "D")
  )
  expect_identical(
    getProbandPedigree(probands = c("F", NA), ped)$id,
    c("A", "B", "D", "E", "F")
  )
  expect_identical(nrow(getProbandPedigree(probands = NA_character_, ped)), 0L)
  expect_identical(nrow(getProbandPedigree(probands = "ZZZ", ped)), 0L)
  expect_identical(nrow(getProbandPedigree(probands = character(0L), ped)), 0L)
})

test_that("getProbandPedigree leaves out a parent that has no row of its own", {
  expect_identical(
    getProbandPedigree(probands = "L", danglingParentPed())$id,
    c("K", "L")
  )
})

test_that("getProbandPedigree returns a row whose id is missing when asked for it", {
  pedMissing <- missingIdPed()
  expect_identical(
    getProbandPedigree(probands = NA_character_, pedMissing)$id,
    c("A", "B", NA_character_)
  )
  expect_identical(
    getProbandPedigree(probands = "F", pedMissing)$id,
    c("A", "B", "D", "E", "F")
  )
})

test_that("getProbandPedigree stops on circular data", {
  expect_identical(
    withinSeconds(getProbandPedigree(probands = "A", circlePed()))$id,
    c("A", "B")
  )
  expect_identical(
    withinSeconds(getProbandPedigree(probands = "A", selfParentPed()))$id,
    "A"
  )
})

test_that("getProbandPedigree asks walkPedigree() for the ancestors of the probands", {
  skip_if_not_installed("mockery")
  ## Control: the real rule gives D, its two parents.
  expect_identical(getProbandPedigree(probands = "D", ped)$id, c("A", "B", "D"))
  ## A stand-in that finds nothing above D leaves only D.
  walker <- mockery::mock(list("D"))
  mockery::stub(getProbandPedigree, "walkPedigree", walker)
  result <- getProbandPedigree(probands = "D", ped)
  expectOneWalk(walker, ids = "D", ped = ped, direction = "ancestors")
  expect_identical(result$id, "D")
})

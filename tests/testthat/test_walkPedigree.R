## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

## walkPedigree() is the one place that says "keep collecting the parents
## (ancestors), the offspring (descendants) or both of every animal found,
## until nothing new turns up". Four hand-written loops used to say it:
## getProbandPedigree(), getDescendantPedigree(), getPedDirectRelatives() and
## getLkDirectAncestors() (BACKLOG, PED-3; owner decision S912, Decision record
## 13; name, file and the circular-data choice settled at the S915 pre-RED
## gate).
##
## walkPedigree(ids, ped, direction) returns a list of id vectors, one per
## generation. The first is the starting ids (each once, in the order given).
## Each later one holds the ids first reached at that step, in the order
## getParents() and getOffspring() return them. It stops when a step finds
## nothing new, so circular data ends. A missing id (NA) is an id like any
## other. The fixtures are in helper-walkPedigree.R.

lacy <- nprcgenekeepr::lacy1989Ped
allDirections <- c("ancestors", "descendants", "both")

test_that("walkPedigree 'ancestors' lists the parents generation by generation", {
  expect_identical(
    walkPedigree("F", lacy, "ancestors"),
    list("F", c("D", "E"), c("A", "B"))
  )
  expect_identical(
    walkPedigree("D", lacy, "ancestors"),
    list("D", c("A", "B"))
  )
  expect_identical(walkPedigree("A", lacy, "ancestors"), list("A"))
})

test_that("walkPedigree 'descendants' lists the offspring generation by generation", {
  expect_identical(
    walkPedigree("A", lacy, "descendants"),
    list("A", c("C", "D"), c("F", "G"))
  )
  expect_identical(walkPedigree("F", lacy, "descendants"), list("F"))
})

test_that("walkPedigree 'both' reaches the whole connected family, each id once", {
  generations <- walkPedigree("E", lacy, "both")
  found <- unlist(generations)
  expect_identical(generations[[1L]], "E")
  expect_setequal(found, c("A", "B", "C", "D", "E", "F", "G"))
  expect_false(anyDuplicated(found) > 0L)
  expect_true(all(lengths(generations) > 0L))
})

test_that("walkPedigree places an animal at the first generation that reaches it", {
  ## S is O's parent and also O's grandparent (through D): it stays in the
  ## first generation, and the second holds only what is new.
  expect_identical(
    walkPedigree("O", diamondPed(), "ancestors"),
    list("O", c("S", "D"), c("G", "H"))
  )
})

test_that("walkPedigree keeps each starting id once, in the order given", {
  expect_identical(
    walkPedigree(c("D", "D", "A"), lacy, "ancestors"),
    list(c("D", "A"), "B")
  )
})

test_that("walkPedigree returns the starting ids alone when there is nowhere to go", {
  for (direction in allDirections) {
    expect_identical(
      walkPedigree(character(0L), lacy, direction),
      list(character(0L)),
      info = direction
    )
    expect_identical(
      walkPedigree("ZZZ", lacy, direction),
      list("ZZZ"),
      info = direction
    )
  }
})

test_that("walkPedigree stops on two animals that are each other's sire", {
  for (direction in allDirections) {
    expect_identical(
      withinSeconds(walkPedigree("A", circlePed(), direction)),
      list("A", "B"),
      info = direction
    )
  }
})

test_that("walkPedigree stops on an animal that is its own sire", {
  for (direction in allDirections) {
    expect_identical(
      withinSeconds(walkPedigree("A", selfParentPed(), direction)),
      list("A"),
      info = direction
    )
  }
})

test_that("walkPedigree treats a missing id like any other id", {
  ped <- missingIdPed()
  expect_identical(
    withinSeconds(walkPedigree("A", ped, "descendants")),
    list("A", c("C", "D", NA), c("F", "G"))
  )
  expect_identical(
    withinSeconds(walkPedigree(NA_character_, ped, "ancestors")),
    list(NA_character_, c("A", "B"))
  )
  both <- withinSeconds(walkPedigree("A", ped, "both"))
  expect_true(anyNA(unlist(both)))
  expect_setequal(unlist(both), c(lacy$id, NA))
})

test_that("walkPedigree refuses a direction it does not know", {
  expect_error(walkPedigree("A", lacy, "sideways"), "should be one of")
})

test_that("walkPedigree is internal, not exported", {
  expect_true(exists("walkPedigree",
    envir = asNamespace("nprcgenekeepr"), inherits = FALSE
  ))
  expect_false("walkPedigree" %in% getNamespaceExports("nprcgenekeepr"))
})

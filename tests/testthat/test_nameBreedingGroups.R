## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

library(testthat)
library(nprcgenekeepr)

## Attaching the names of the Breeding Groups boxes to the list of groups the
## Genetic Diversity tab is handed (S1000, docs-audit part 2 flag CA3).
## getGeneticDiversityStats() uses names(groups) as the heat map's row labels
## only when every group has a non-empty name, so names that do not fit must
## leave the groups exactly as they were (the rows are then "Group 1", "Group 2"
## and so on, as before) and never stop the tab.

## The call, or the error it raised, so a missing function shows as a failed
## comparison and not as a crash.
nbg <- function(groups, labels) {
  tryCatch(.nameBreedingGroups(groups, labels), error = function(e) e)
}

twoBoxes <- list(c("A1", "A2"), "A3")

test_that("the names go on the boxes in order and the ids are untouched", {
  got <- nbg(twoBoxes, c("Group 1", "Unused animals"))

  expect_identical(names(got), c("Group 1", "Unused animals"))
  expect_identical(unname(got), twoBoxes)
})

test_that("without box names the groups are returned as they were", {
  expect_identical(nbg(twoBoxes, NULL), twoBoxes)
  expect_identical(nbg(twoBoxes, character(0L)), twoBoxes)
})

test_that("groups that are not a list of boxes are returned as given", {
  expect_null(nbg(NULL, c("Group 1", "Group 2")))
  expect_identical(nbg(c("A1", "A2"), c("Group 1", "Group 2")),
                   c("A1", "A2"))
})

test_that("an empty list of groups stays an empty list", {
  expect_identical(nbg(list(), character(0L)), list())
  expect_identical(nbg(list(), NULL), list())
})

test_that("too few box names leave the groups unnamed", {
  expect_identical(nbg(twoBoxes, "Unused animals"), twoBoxes)
})

test_that("too many box names leave the groups unnamed", {
  expect_identical(nbg(twoBoxes, c("Group 1", "Group 2", "Unused animals")),
                   twoBoxes)
})

test_that("a missing or empty box name leaves the groups unnamed", {
  expect_identical(nbg(twoBoxes, c("Group 1", NA_character_)), twoBoxes)
  expect_identical(nbg(twoBoxes, c("Group 1", "")), twoBoxes)
})

test_that("box names that are not text leave the groups unnamed", {
  expect_identical(nbg(twoBoxes, c(1, 2)), twoBoxes)
  expect_identical(nbg(twoBoxes, list("Group 1", "Unused animals")), twoBoxes)
})

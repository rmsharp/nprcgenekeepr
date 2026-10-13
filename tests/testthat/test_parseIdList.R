## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

library(testthat)
library(nprcgenekeepr)

## parseIdList(raw) (S973; BACKLOG.md:149, the Breeding Groups "My own list"
## choice): the one internal rule for reading a box of pasted animal IDs. The
## Mate Pair tab's "Custom list (paste IDs)" box and the Breeding Groups seed
## boxes each carry their own copy of it (R/modMatePair.R:260-266,
## R/modBreedingGroups.R:613-622); the new "Animal IDs:" box is the third
## reader, so the rule gets a name and a test of its own.
##
## The rule, as both copies already apply it: split on a space, comma,
## semicolon, tab or new line; trim; drop what is empty. The result is a
## character vector in the order typed. A repeated id stays repeated: the
## caller decides whether a repeat matters (the Breeding Groups pool counts an
## animal once). A missing or blank box gives character(0), never NA.

test_that("an unset, empty, blank or missing box gives no ids, as a character vector", {
  expect_identical(parseIdList(NULL), character(0L))
  expect_identical(parseIdList(""), character(0L))
  expect_identical(parseIdList("   "), character(0L))
  expect_identical(parseIdList(NA_character_), character(0L))
})

test_that("a box of nothing but separators gives no ids", {
  expect_identical(parseIdList(", ; \t\n,,"), character(0L))
  expect_identical(parseIdList("\n\n\n"), character(0L))
})

test_that("ids are split on commas, spaces, semicolons, tabs and new lines", {
  expect_identical(parseIdList("A1,A2 A3;A4\tA5\nA6"),
                   c("A1", "A2", "A3", "A4", "A5", "A6"))
})

test_that("a column copied from a spreadsheet on Windows leaves no stray line-end characters", {
  expect_identical(parseIdList("A1\r\nA2\r\nA3\r\n"), c("A1", "A2", "A3"))
})

test_that("runs of separators and the space around them make no empty ids", {
  expect_identical(parseIdList("  A1 ,, A2 ;\n\n A3  "),
                   c("A1", "A2", "A3"))
})

test_that("the order typed is kept and a repeated id is kept for the caller to count", {
  expect_identical(parseIdList("B2, A1, B2"), c("B2", "A1", "B2"))
})

test_that("an id keeps its case and its dashes, dots and underscores", {
  expect_identical(parseIdList("a1, A-1, x.y_z"), c("a1", "A-1", "x.y_z"))
})

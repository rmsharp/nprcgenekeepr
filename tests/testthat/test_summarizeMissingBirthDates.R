## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

library(testthat)
library(nprcgenekeepr)

## Tests for summarizeMissingBirthDates() (S931): the counts behind the note the
## Genetic Diversity tab shows when animals in the breeding groups have no birth
## date. Of the females with no birth date, the Production cell counts those the
## pedigree lists as a dam (looked up in the whole pedigree) and leaves out the
## rest.

ped <- data.frame(
  id = c("f1", "f2", "f3", "m1", "o1", "x1"),
  dam = c(NA, NA, NA, NA, "f1", NA),
  sex = c("F", "F", "F", "M", "M", "F"),
  birth = as.Date(c(NA, NA, "2008-01-01", NA, "2018-06-01", NA)),
  stringsAsFactors = FALSE
)
groups <- list(c("f1", "f2", "f3"), c("m1", "o1"))

test_that("summarizeMissingBirthDates counts animals and females with no birth date", {
  res <- summarizeMissingBirthDates(groups, ped)
  expect_named(res, c("animals", "total", "females", "femalesCounted",
                      "femalesLeftOut"))
  expect_identical(res$animals, 3L)          # f1, f2, m1
  expect_identical(res$total, 5L)            # x1 is in no group
  expect_identical(res$females, 2L)          # f1, f2
  expect_identical(res$femalesCounted, 1L)   # f1 is the dam of o1
  expect_identical(res$femalesLeftOut, 1L)   # f2 has no offspring
})

test_that("summarizeMissingBirthDates finds a mother's offspring outside the groups", {
  pedOutside <- rbind(ped, data.frame(
    id = "z1", dam = "f2", sex = "M", birth = as.Date("2019-01-01"),
    stringsAsFactors = FALSE
  ))
  res <- summarizeMissingBirthDates(groups, pedOutside)
  expect_identical(res$femalesCounted, 2L)
  expect_identical(res$femalesLeftOut, 0L)
})

test_that("summarizeMissingBirthDates reports zeros when every birth date is known", {
  pedKnown <- ped
  pedKnown$birth <- as.Date("2010-01-01")
  res <- summarizeMissingBirthDates(groups, pedKnown)
  expect_identical(res$animals, 0L)
  expect_identical(res$total, 5L)
  expect_identical(res$females, 0L)
  expect_identical(res$femalesCounted, 0L)
  expect_identical(res$femalesLeftOut, 0L)
})

test_that("summarizeMissingBirthDates ignores animals that are in no group", {
  res <- summarizeMissingBirthDates(list(c("f3", "o1")), ped)
  expect_identical(res$animals, 0L)
  expect_identical(res$total, 2L)
})

#' Copyright(c) 2017-2022 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("getPedDirectRelatives")

test_that("getPedDirectRelatives throws an error with no pedigree", {
  expect_error(getPedDirectRelatives(),
               'Need to specify IDs')
})

test_that("getPedDirectRelatives throws an error with no pedigree", {
  expect_true(is.null(getPedDirectRelatives(ids = "E", ped = NULL)))
})

ped <- c("A", "B")
test_that("getPedDirectRelatives throws an error with no IDs", {
  expect_error(getPedDirectRelatives(ped = ped),
               'Need to specify IDs')
})

test_that("getPedDirectRelatives throws an error with pedigree argument", {
  expect_error(getPedDirectRelatives(ids = "E"),
               'Need to specify pedigree')
})

test_that(paste0("getPedDirectRelatives throws an error with no data.frame ",
                 "for pedigree"), {
                   expect_error(getPedDirectRelatives(ids = "E", ped = ped),
                                'ped must be a data.frame object')
                 })

ped <- nprcgenekeepr::lacy1989Ped
test_that("getPedDirectRelatives throws an error with no pedigree", {
  expect_error(getPedDirectRelatives(ped = ped),
               'Need to specify IDs')
})

ped <- nprcgenekeepr::lacy1989Ped
ids <- "E"
ancestors <- getPedDirectRelatives(ids = ids, ped = ped,
                                   unrelatedParents = FALSE)
test_that("getPedDirectRelatives creates correct pedigree", {
  expect_setequal(ancestors$id, c("D", "E", "F", "G"))
})

ids <- "B"
ancestors <- getPedDirectRelatives(ids = ids, ped = ped,
                                   unrelatedParents = FALSE)
test_that("getPedDirectRelatives creates correct pedigree", {
  expect_setequal(ancestors$id, c("A", "B", "C", "D", "E", "F", "G"))
})
ids <- "C"
ancestors <- getPedDirectRelatives(ids = ids, ped = ped,
                                   unrelatedParents = FALSE)
test_that("getPedDirectRelatives creates correct pedigree", {
  expect_setequal(ancestors$id, c("A", "B", "C"))
})


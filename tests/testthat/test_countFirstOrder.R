#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("countFirstOrder")
library(testthat)
data("lacy1989Ped")
ped <- lacy1989Ped
ids <- c("A", "B", "D", "E", "F", "G")
countIds <- countFirstOrder(ped, ids)
count <- countFirstOrder(ped, NULL)

test_that("countFirstOrder makes correct transformations", {
  expect_equal(countIds$id[countIds$id %in% count$id], countIds$id)
  expect_true(all(count$id[count$id %in% countIds$id] %in% countIds$id))
  expect_equal(count$parents, c(0, 0, 2, 2, 0, 2, 2))
  expect_equal(count$offspring, c(2, 2, 0, 2, 2, 0, 0))
  expect_equal(count$siblings, c(0, 0, 1, 1, 0, 1, 1))
  expect_equal(count$total, c(2, 2, 3, 5, 2, 3, 3))

})

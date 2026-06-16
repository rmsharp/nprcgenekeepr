#' Copyright(c) 2017-2026 R. Mark Sharp
#' This file is part of nprcgenekeepr
#'
#' Dedicated unit tests for kinshipMatrixToKValues(), which had no direct
#' test coverage. A kValue table has one row per unordered ID pair including
#' self-pairs: n + n(n - 1) / 2 rows, columns id_1, id_2, kinship.

## Orientation-agnostic kinship lookup for an unordered pair.
getK <- function(kv, x, y) {
  kv$kinship[(kv$id_1 == x & kv$id_2 == y) |
    (kv$id_1 == y & kv$id_2 == x)]
}

km3 <- matrix(
  c(
    0.50, 0.25, 0.000,
    0.25, 0.50, 0.125,
    0.00, 0.125, 0.500
  ),
  nrow = 3, byrow = TRUE,
  dimnames = list(c("A", "B", "C"), c("A", "B", "C"))
)
kv3 <- kinshipMatrixToKValues(km3)

test_that("kinshipMatrixToKValues returns the documented shape", {
  expect_s3_class(kv3, "data.frame")
  expect_equal(names(kv3), c("id_1", "id_2", "kinship"))
  expect_type(kv3$id_1, "character")
  expect_type(kv3$id_2, "character")
  expect_type(kv3$kinship, "double")
})

test_that("kinshipMatrixToKValues has n + n(n - 1)/2 rows (n = 3 -> 6)", {
  expect_equal(nrow(kv3), 6L)
})

test_that("kinshipMatrixToKValues lists each unordered pair exactly once", {
  for (pair in list(
    c("A", "A"), c("B", "B"), c("C", "C"),
    c("A", "B"), c("A", "C"), c("B", "C")
  )) {
    expect_length(getK(kv3, pair[[1]], pair[[2]]), 1L)
  }
})

test_that("kinshipMatrixToKValues preserves the matrix coefficients", {
  expect_equal(getK(kv3, "A", "A"), 0.50)
  expect_equal(getK(kv3, "B", "B"), 0.50)
  expect_equal(getK(kv3, "C", "C"), 0.50)
  expect_equal(getK(kv3, "A", "B"), 0.25)
  expect_equal(getK(kv3, "A", "C"), 0.00)
  expect_equal(getK(kv3, "B", "C"), 0.125)
})

test_that("kinshipMatrixToKValues handles an unnamed matrix", {
  km2 <- matrix(c(0.5, 0.1, 0.1, 0.5), nrow = 2)
  kv2 <- kinshipMatrixToKValues(km2)
  expect_equal(nrow(kv2), 3L)
  expect_equal(names(kv2), c("id_1", "id_2", "kinship"))
  expect_equal(sort(kv2$kinship), c(0.1, 0.5, 0.5))
})

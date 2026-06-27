#' Copyright(c) 2017-2026 R. Mark Sharp
#' This file is part of nprcgenekeepr
library(testthat)

# Issue #13 Slice 1: applyKinshipOverrides(kmat, overrides) patches a computed
# kinship matrix with outside-information pair values (id1, id2, kinship),
# REPLACING the named off-diagonal cell and its symmetric twin. It is the strict
# leaf (stop() on bad input / unknown id); soft, run-preserving handling of
# non-member ids lives in reportGV (D5). kinship() itself is never modified.

# small named symmetric kinship matrix fixture: 3 non-inbred animals (diag 0.5)
makeI13Kmat <- function() {
  m <- matrix(c(
    0.50, 0.10, 0.00,
    0.10, 0.50, 0.05,
    0.00, 0.05, 0.50
  ), nrow = 3L, byrow = TRUE)
  dimnames(m) <- list(c("a", "b", "c"), c("a", "b", "c"))
  m
}

test_that("applyKinshipOverrides writes the named pair symmetrically", {
  m <- makeI13Kmat()
  ov <- data.frame(id1 = "a", id2 = "c", kinship = 0.25,
                   stringsAsFactors = FALSE)
  out <- suppressMessages(applyKinshipOverrides(m, ov))
  expect_equal(out["a", "c"], 0.25) # the named cell
  expect_equal(out["c", "a"], 0.25) # the symmetric twin
  ## all other off-diagonal cells are unchanged
  expect_equal(out["a", "b"], 0.10)
  expect_equal(out["b", "c"], 0.05)
})

test_that("applyKinshipOverrides leaves the diagonal untouched (off-diagonal only)", {
  m <- makeI13Kmat()
  ov <- data.frame(id1 = "a", id2 = "b", kinship = 0.30,
                   stringsAsFactors = FALSE)
  out <- suppressMessages(applyKinshipOverrides(m, ov))
  expect_equal(unname(diag(out)), c(0.5, 0.5, 0.5))
})

test_that("applyKinshipOverrides is a no-op for NULL or empty overrides", {
  m <- makeI13Kmat()
  expect_identical(applyKinshipOverrides(m, NULL), m)
  empty <- data.frame(id1 = character(0L), id2 = character(0L),
                      kinship = numeric(0L), stringsAsFactors = FALSE)
  expect_identical(applyKinshipOverrides(m, empty), m)
})

test_that("applyKinshipOverrides stops on an id absent from the matrix (strict leaf, D5)", {
  m <- makeI13Kmat()
  ov <- data.frame(id1 = "a", id2 = "zzz", kinship = 0.25,
                   stringsAsFactors = FALSE)
  expect_error(suppressMessages(applyKinshipOverrides(m, ov)))
})

test_that("applyKinshipOverrides rejects a value above the exact Cauchy-Schwarz bound (D6)", {
  m <- makeI13Kmat() # non-inbred: bound sqrt(0.5 * 0.5) = 0.5
  ov <- data.frame(id1 = "a", id2 = "b", kinship = 0.60,
                   stringsAsFactors = FALSE)
  expect_error(suppressWarnings(applyKinshipOverrides(m, ov)))
})

test_that("applyKinshipOverrides allows a legitimate inbred-pair value within the exact bound (D6)", {
  m <- makeI13Kmat()
  m["a", "a"] <- 0.625 # inbred -> bound sqrt(0.625 * 0.625) = 0.625
  m["b", "b"] <- 0.625
  ## 0.55 exceeds 0.5 but is legitimate for this inbred pair
  ov <- data.frame(id1 = "a", id2 = "b", kinship = 0.55,
                   stringsAsFactors = FALSE)
  out <- suppressWarnings(suppressMessages(applyKinshipOverrides(m, ov)))
  expect_equal(out["a", "b"], 0.55)
  expect_equal(out["b", "a"], 0.55)
})

test_that("applyKinshipOverrides messages the count of overrides applied (D9)", {
  m <- makeI13Kmat()
  ov <- data.frame(id1 = "a", id2 = "c", kinship = 0.25,
                   stringsAsFactors = FALSE)
  expect_message(applyKinshipOverrides(m, ov), "override")
})

#' Copyright(c) 2017-2026 R. Mark Sharp
#' This file is part of nprcgenekeepr
library(testthat)

# Issue #13 Slice 1: checkKinshipOverrides(overrides) validates an outside
# kinship override frame (id1, id2, kinship), mirroring checkGenotypeFile. It
# stop()s on structural / domain errors (missing column, NA / negative kinship,
# self-pair, duplicated unordered pair) and -- per ratified D6 -- WARNS (does not
# stop) on an off-diagonal value > 0.5, since the matrix-aware exact-bound
# rejection (> sqrt(diag_ii * diag_jj)) is applyKinshipOverrides' job. The
# returned frame has id1 / id2 coerced to character.

validI13Overrides <- function() {
  data.frame(
    id1 = c("A1", "A3"),
    id2 = c("A2", "A4"),
    kinship = c(0.25, 0.125),
    stringsAsFactors = FALSE
  )
}

test_that("checkKinshipOverrides accepts a valid overrides frame", {
  expect_error(checkKinshipOverrides(validI13Overrides()), NA)
})

test_that("checkKinshipOverrides returns a data.frame with id columns as character", {
  out <- checkKinshipOverrides(validI13Overrides())
  expect_s3_class(out, "data.frame")
  expect_type(out$id1, "character")
  expect_type(out$id2, "character")
})

test_that("checkKinshipOverrides stops when a required column is missing", {
  bad <- validI13Overrides()
  bad$kinship <- NULL
  expect_error(checkKinshipOverrides(bad))
})

test_that("checkKinshipOverrides stops on an NA kinship value", {
  bad <- validI13Overrides()
  bad$kinship[1L] <- NA_real_
  expect_error(checkKinshipOverrides(bad))
})

test_that("checkKinshipOverrides stops on a negative kinship value", {
  bad <- validI13Overrides()
  bad$kinship[1L] <- -0.1
  expect_error(checkKinshipOverrides(bad))
})

test_that("checkKinshipOverrides stops on a self-pair (id1 == id2, D4)", {
  bad <- validI13Overrides()
  bad$id2[1L] <- bad$id1[1L]
  expect_error(checkKinshipOverrides(bad))
})

test_that("checkKinshipOverrides stops on a duplicated unordered pair", {
  bad <- data.frame(
    id1 = c("A1", "A2"),
    id2 = c("A2", "A1"), # same unordered pair {A1, A2}
    kinship = c(0.25, 0.30),
    stringsAsFactors = FALSE
  )
  expect_error(checkKinshipOverrides(bad))
})

test_that("checkKinshipOverrides warns (does not stop) on an off-diagonal value > 0.5 (D6)", {
  warnFrame <- data.frame(
    id1 = "A1", id2 = "A2", kinship = 0.75,
    stringsAsFactors = FALSE
  )
  expect_warning(checkKinshipOverrides(warnFrame))
})

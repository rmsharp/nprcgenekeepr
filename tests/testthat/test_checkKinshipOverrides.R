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

# Issue #95 option C, Slice 1 (RATIFIED S227): an OPTIONAL `missingSideFor`
# column. Each non-blank cell must name id1 or id2 of its row (the one-unknown
# focal whose missing side this override stands in for); blank / NA = known-side
# (C1.1 per-row default). Validation is STRUCTURAL only (no ped) -- whether the
# named focal is actually one-unknown is the caller's semantic check
# (classifyOverrideMissingSide). The unordered-pair dedup key is UNCHANGED
# (C1.2: two rows for one pair stay a duplicate error).

test_that("checkKinshipOverrides accepts an optional missingSideFor naming id1/id2 or blank", {
  ok <- validI13Overrides()
  ok$missingSideFor <- c("A1", "") # row1 names id1; row2 blank (known-side)
  expect_error(checkKinshipOverrides(ok), NA)
  out <- checkKinshipOverrides(ok)
  expect_true("missingSideFor" %in% names(out))
})

test_that("checkKinshipOverrides rejects a missingSideFor not naming id1 or id2 (C1)", {
  bad <- validI13Overrides()
  bad$missingSideFor <- c("A1", "NOTANID") # row2 names neither A3 nor A4
  expect_error(checkKinshipOverrides(bad))
})

test_that("checkKinshipOverrides treats NA missingSideFor as blank (known-side, C1.1)", {
  ok <- validI13Overrides()
  ok$missingSideFor <- c("A1", NA)
  expect_error(checkKinshipOverrides(ok), NA)
})

test_that("checkKinshipOverrides still rejects a duplicated pair with differing missingSideFor (C1.2)", {
  bad <- data.frame(
    id1 = c("A1", "A2"),
    id2 = c("A2", "A1"), # same unordered pair {A1, A2}
    kinship = c(0.25, 0.25),
    missingSideFor = c("A1", "A2"),
    stringsAsFactors = FALSE
  )
  expect_error(checkKinshipOverrides(bad))
})

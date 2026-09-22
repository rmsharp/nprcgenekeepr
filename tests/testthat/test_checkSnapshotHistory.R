## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# Issue #167 Slice 1: checkSnapshotHistory(history) validates a snapshot-history
# table in the ratified D1 schema (27 columns, three groups of nine), mirroring
# checkKinshipOverrides(). It stop()s with a specific message on each violation
# class named in the plan's interface catalog -- missing columns, non-numeric
# metric fields, unknown schemaVersion, duplicate (snapshotDate, membershipRule)
# pairs, malformed dates -- and returns the coerced history otherwise. Per D3 it
# does NOT enforce a membershipRule enumeration (the field is an open string;
# Slice 2 fixes the generated vocabulary).

snapshotHistoryFixturePath <- function() {
  ## No skip_if() guard: system.file() returns "" when the fixture doesn't
  ## exist yet, and read.csv("") errors -- this test file must genuinely FAIL,
  ## not skip, until the fixture is committed.
  system.file(
    "extdata", "examples", "example_snapshot_history.csv",
    package = "nprcgenekeepr"
  )
}

validSnapshotHistory <- function() {
  read.csv(snapshotHistoryFixturePath(), stringsAsFactors = FALSE)
}

test_that("checkSnapshotHistory accepts the committed example fixture", {
  expect_error(checkSnapshotHistory(validSnapshotHistory()), NA)
})

test_that("checkSnapshotHistory returns the coerced history", {
  out <- checkSnapshotHistory(validSnapshotHistory())
  expect_s3_class(out, "data.frame")
  expect_identical(nrow(out), 4L)
  expect_s3_class(out$snapshotDate, "Date")
  expect_type(out$membershipRule, "character")
  expect_type(out$packageVersion, "character")
  expect_identical(unique(out$schemaVersion), 1L)
  expect_true(is.numeric(out$fe))
  expect_true(is.numeric(out$meanGu))
  expect_true(is.numeric(out$nAnimals))
})

test_that("checkSnapshotHistory accepts a zero-row history with the full schema", {
  empty <- validSnapshotHistory()[0L, ]
  expect_error(checkSnapshotHistory(empty), NA)
  out <- checkSnapshotHistory(empty)
  expect_identical(nrow(out), 0L)
})

test_that("checkSnapshotHistory stops when a required column is missing", {
  bad <- validSnapshotHistory()
  bad$meanGuSE <- NULL
  expect_error(checkSnapshotHistory(bad), "missing")
})

test_that("checkSnapshotHistory stops on a non-numeric metric field", {
  bad <- validSnapshotHistory()
  bad$fg <- as.character(bad$fg)
  bad$fg[1L] <- "high"
  expect_error(checkSnapshotHistory(bad), "must be numeric")
})

test_that("checkSnapshotHistory stops on an unknown schemaVersion", {
  bad <- validSnapshotHistory()
  bad$schemaVersion[2L] <- 99L
  expect_error(checkSnapshotHistory(bad), "schemaVersion")
})

test_that("checkSnapshotHistory stops on a duplicated (snapshotDate, membershipRule) pair", {
  bad <- validSnapshotHistory()
  bad <- rbind(bad, bad[1L, ])
  expect_error(checkSnapshotHistory(bad), "[Dd]uplicate")
})

test_that("checkSnapshotHistory accepts one date shared by two different membership rules", {
  ## Fixture rows 3 and 4 deliberately share 2026-01-15 under wholePedigree
  ## and focalPopulation -- only the (date, rule) PAIR must be unique.
  out <- checkSnapshotHistory(validSnapshotHistory())
  shared <- out[out$snapshotDate == as.Date("2026-01-15"), ]
  expect_identical(nrow(shared), 2L)
  expect_identical(sort(shared$membershipRule),
                   c("focalPopulation", "wholePedigree"))
})

test_that("checkSnapshotHistory stops on a malformed snapshotDate", {
  bad <- validSnapshotHistory()
  bad$snapshotDate[1L] <- "01/15/2025"
  expect_error(checkSnapshotHistory(bad), "snapshotDate")
  badNonsense <- validSnapshotHistory()
  badNonsense$snapshotDate[1L] <- "2026-13-45"
  expect_error(checkSnapshotHistory(badNonsense), "snapshotDate")
})

test_that("checkSnapshotHistory ignores a stray extra column", {
  ## Matches the checkKinshipOverrides() keep-all convention: extra columns
  ## are ignored, not rejected.
  stray <- validSnapshotHistory()
  stray$note <- "hand annotation"
  expect_error(checkSnapshotHistory(stray), NA)
})

## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# Issue #167 Slice 1: appendColonySnapshot(history, snapshot) is a PURE merge
# (D2): validated history (or NULL/empty for a first snapshot) + one-row
# snapshot in, date-ordered merged history out. It writes nothing. It stop()s
# on a schemaVersion mismatch or a duplicate (snapshotDate, membershipRule)
# pair. Script users persist the result themselves (write.csv); the app's only
# write path is a user-initiated downloadHandler (Slice 4).

validatedSnapshotHistory <- function() {
  checkSnapshotHistory(read.csv(system.file(
    "extdata", "examples", "example_snapshot_history.csv",
    package = "nprcgenekeepr"
  ), stringsAsFactors = FALSE))
}

## A plausible next snapshot, dated after every fixture row.
newSnapshotRow <- function() {
  data.frame(
    schemaVersion = 1L,
    snapshotDate = as.Date("2026-07-15"),
    packageVersion = "2.0.0.9000",
    membershipRule = "wholePedigree",
    guIter = 10000L,
    guThresh = 3L,
    nAnimals = 390L,
    nMales = 130L,
    nFemales = 260L,
    fe = 14.9,
    fg = 9.1,
    fgSE = 0.13,
    neGD = 44.2,
    neSexRatio = 231.1,
    neVariance = 198.3,
    nMaleFounders = 12L,
    nFemaleFounders = 24L,
    nFounders = 36L,
    meanIndivMeanKin = 0.0798,
    medianIndivMeanKin = 0.0781,
    skewnessIndivMeanKin = 0.38,
    kurtosisIndivMeanKin = 2.8,
    meanGu = 0.229,
    medianGu = 0.221,
    meanGuSE = 0.0027,
    skewnessGu = 0.3,
    kurtosisGu = 3.0,
    stringsAsFactors = FALSE
  )
}

test_that("appendColonySnapshot appends a new snapshot to a validated history", {
  merged <- appendColonySnapshot(validatedSnapshotHistory(), newSnapshotRow())
  expect_s3_class(merged, "data.frame")
  expect_identical(nrow(merged), 5L)
  expect_true(as.Date("2026-07-15") %in% merged$snapshotDate)
})

test_that("appendColonySnapshot starts a history from NULL", {
  merged <- appendColonySnapshot(NULL, newSnapshotRow())
  expect_identical(nrow(merged), 1L)
  expect_identical(merged$snapshotDate, as.Date("2026-07-15"))
})

test_that("appendColonySnapshot starts a history from a zero-row history", {
  empty <- validatedSnapshotHistory()[0L, ]
  merged <- appendColonySnapshot(empty, newSnapshotRow())
  expect_identical(nrow(merged), 1L)
})

test_that("appendColonySnapshot returns a date-ordered history", {
  ## An out-of-order (earlier) snapshot must land in date order, not last.
  early <- newSnapshotRow()
  early$snapshotDate <- as.Date("2024-06-01")
  merged <- appendColonySnapshot(validatedSnapshotHistory(), early)
  expect_identical(nrow(merged), 5L)
  expect_false(is.unsorted(merged$snapshotDate))
  expect_identical(merged$snapshotDate[1L], as.Date("2024-06-01"))
})

test_that("appendColonySnapshot stops on a schemaVersion mismatch", {
  bad <- newSnapshotRow()
  bad$schemaVersion <- 2L
  expect_error(appendColonySnapshot(validatedSnapshotHistory(), bad),
               "schemaVersion")
})

test_that("appendColonySnapshot stops on a duplicate (snapshotDate, membershipRule) pair", {
  history <- validatedSnapshotHistory()
  dup <- newSnapshotRow()
  dup$snapshotDate <- history$snapshotDate[1L]
  dup$membershipRule <- history$membershipRule[1L]
  expect_error(appendColonySnapshot(history, dup), "[Dd]uplicate")
})

test_that("appendColonySnapshot allows an existing date under a new membership rule", {
  history <- validatedSnapshotHistory()
  sameDateNewRule <- newSnapshotRow()
  sameDateNewRule$snapshotDate <- history$snapshotDate[1L]
  sameDateNewRule$membershipRule <- "focalPopulation"
  merged <- appendColonySnapshot(history, sameDateNewRule)
  expect_identical(nrow(merged), 5L)
})

test_that("snapshot history round-trips: read, append, write.csv, re-read, equal", {
  ## D2 / Dragon 5: full-precision write.csv is the persistence path; a lossy
  ## round trip would inject artificial deltas into trends.
  merged <- appendColonySnapshot(validatedSnapshotHistory(), newSnapshotRow())
  csv <- tempfile(fileext = ".csv")
  on.exit(unlink(csv), add = TRUE)
  write.csv(merged, csv, row.names = FALSE)
  reRead <- checkSnapshotHistory(readSnapshotHistory(csv))
  expect_identical(names(reRead), names(merged))
  expect_equal(reRead, merged)
})

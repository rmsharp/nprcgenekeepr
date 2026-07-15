## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

test_that("getLkDirectAncestors throws an error with no nprcgenekeepr
          configuration file", {
  expect_warning(
    getLkDirectAncestors(),
    "The file should be named:"
  )
})

## Issue #111 coverage backfill: the only existing test reaches just the
## getSiteInfo warning and the early NULL return (getDemographics warns offline).
## Mock getDemographics to drive the error handler (lines 37-40) and the
## ancestor-walk body (lines 46-60). The fixture columns are in
## siteInfo$mapPedColumns order (id, sex, birth, death, exit, dam, sire), which
## getLkDirectAncestors assigns to the pulled data before walking parents.
test_that("getLkDirectAncestors returns NULL when getDemographics errors", {
  skip_if_not_installed("mockery")
  mockery::stub(getLkDirectAncestors, "getDemographics",
                function(...) stop("labkey down"))
  expect_null(suppressWarnings(getLkDirectAncestors(ids = "O1")))
})

## BACKLOG.md "4 remaining unguarded getSiteInfo() call sites": getSiteInfo()
## itself is unguarded here, and its parser can throw on a PRESENT but
## malformed configuration file (distinct from the missing-file case above,
## which only warns and falls back to defaults). Mirrors the getDemographics
## guard immediately below it in the same function.
test_that("getLkDirectAncestors returns NULL when getSiteInfo() errors (malformed config)", {
  skip_if_not_installed("mockery")
  mockery::stub(getLkDirectAncestors, "getSiteInfo",
                function(...) stop("simulated malformed config"))
  expect_null(getLkDirectAncestors(ids = "O1"))
})

test_that("getLkDirectAncestors walks the sire/dam chain to all ancestors", {
  skip_if_not_installed("mockery")
  fixture <- data.frame(
    id    = c("O1", "S1", "D1"),
    sex   = c("F", "M", "F"),
    birth = c("2015-01-01", "2000-01-01", "2000-01-01"),
    death = c(NA, NA, NA),
    exit  = c(NA, NA, NA),
    dam   = c("D1", NA, NA),
    sire  = c("S1", NA, NA),
    stringsAsFactors = FALSE
  )
  mockery::stub(getLkDirectAncestors, "getDemographics",
                mockery::mock(fixture))
  result <- suppressWarnings(getLkDirectAncestors(ids = "O1"))
  expect_setequal(result$id, c("O1", "S1", "D1"))
})

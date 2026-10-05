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

## PED-3 (BACKLOG; owner decision S912, Decision record 13; strict TDD, S915):
## the loop that collects the ancestors moves into walkPedigree(), and the
## function stops on circular data (today it never does). The tests below
## record what the function returns today (they pass at the commit that adds
## them, except the two that name circular data) and check it asks
## walkPedigree() for its ids. The fixtures are in helper-walkPedigree.R.

## `lkFn` (getLkDirectAncestors, or a copy of it) reading `demographics`
## instead of LabKey. It takes the function as an argument because
## mockery::stub() replaces a function only in the scope that calls it.
lkOver <- function(lkFn, demographics) {
  mockery::stub(
    lkFn, "getSiteInfo",
    function(...) {
      list(
        lkPedColumns = names(demographics),
        mapPedColumns = names(demographics)
      )
    }
  )
  mockery::stub(lkFn, "getDemographics", function(...) demographics)
  lkFn
}

test_that("getLkDirectAncestors returns the focal animals, then each generation, in table order", {
  skip_if_not_installed("mockery")
  ## The table is in the order G, H, D, S, O. Pure table order would be that
  ## order and pure discovery order O, S, D, G, H; the rows come back as O, then
  ## D and S (O's parents, in table order), then G and H (their parents).
  result <- lkOver(getLkDirectAncestors, diamondPed())("O")
  expect_identical(result$id, c("O", "D", "S", "G", "H"))
})

test_that("getLkDirectAncestors puts the focal animals first, in table order", {
  skip_if_not_installed("mockery")
  result <- lkOver(getLkDirectAncestors, diamondPed())(c("D", "O"))
  expect_identical(result$id, c("D", "O", "H", "S", "G"))
})

test_that("getLkDirectAncestors keeps the first row of an id that the table repeats", {
  skip_if_not_installed("mockery")
  repeated <- data.frame(
    id = c("O", "S", "D", "S"), sire = c("S", NA, NA, NA),
    dam = c("D", NA, NA, NA), sex = c("F", "M", "F", "X"),
    stringsAsFactors = FALSE
  )
  result <- lkOver(getLkDirectAncestors, repeated)("O")
  expect_identical(result$id, c("O", "S", "D"))
  expect_identical(result$sex, c("F", "M", "F"))
})

test_that("getLkDirectAncestors returns no rows for missing, absent or empty ids", {
  skip_if_not_installed("mockery")
  lk <- lkOver(getLkDirectAncestors, diamondPed())
  expect_identical(nrow(lk(NA_character_)), 0L)
  expect_identical(nrow(lk("ZZZ")), 0L)
  expect_identical(nrow(lk(character(0L))), 0L)
})

test_that("getLkDirectAncestors leaves out a parent that has no row of its own", {
  skip_if_not_installed("mockery")
  result <- lkOver(getLkDirectAncestors, danglingParentPed())("L")
  expect_identical(result$id, c("L", "K"))
})

test_that("getLkDirectAncestors stops on circular data", {
  skip_if_not_installed("mockery")
  expect_identical(
    withinSeconds(lkOver(getLkDirectAncestors, circlePed())("A"))$id,
    c("A", "B")
  )
  expect_identical(
    withinSeconds(lkOver(getLkDirectAncestors, selfParentPed())("A"))$id,
    "A"
  )
})

test_that("getLkDirectAncestors asks walkPedigree() for the ancestors of the focal animals", {
  skip_if_not_installed("mockery")
  fixture <- diamondPed()
  ## Control: the real rule gives all four ancestors of O.
  expect_identical(
    lkOver(getLkDirectAncestors, fixture)("O")$id,
    c("O", "D", "S", "G", "H")
  )
  ## A stand-in that finds only D above O leaves O and D.
  walker <- mockery::mock(list("O", "D"))
  lk <- lkOver(getLkDirectAncestors, fixture)
  mockery::stub(lk, "walkPedigree", walker)
  result <- lk("O")
  expectOneWalk(walker, ids = "O", ped = fixture, direction = "ancestors")
  expect_identical(result$id, c("O", "D"))
})

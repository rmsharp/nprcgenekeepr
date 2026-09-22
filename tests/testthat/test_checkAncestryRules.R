## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# Issue #168 Slice 1: checkAncestryRules(rules) validates a center-configurable
# ancestry compatibility rules table (ancestry1, ancestry2, severity),
# mirroring checkKinshipOverrides. It stop()s on structural / domain errors
# (missing column, NA values, a level outside convertAncestry()'s six, an
# unknown severity, duplicated unordered pair) and -- per ratified D6 -- WARNS
# (does not stop) when exactly one of UNKNOWN/OTHER is named anywhere in the
# table, because convertAncestry() is not idempotent (a literal "UNKNOWN"
# re-standardizes to OTHER; plan section 1.3), so a center naming one almost
# always wants both. Self-pairs (e.g. HYBRID x HYBRID) are legal rules,
# unlike the kinship-overrides sibling. The returned frame carries character
# columns with levels coerced to uppercase and severity to lowercase.

validAncestryRules <- function() {
  data.frame(
    ancestry1 = c("INDIAN", "INDIAN"),
    ancestry2 = c("CHINESE", "HYBRID"),
    severity = c("block", "flag"),
    stringsAsFactors = FALSE
  )
}

test_that("checkAncestryRules accepts a valid rules frame without error or warning", {
  expect_error(checkAncestryRules(validAncestryRules()), NA)
  # Neither UNKNOWN nor OTHER is named here, so no D6 asymmetry warning.
  expect_warning(checkAncestryRules(validAncestryRules()), NA)
})

test_that("checkAncestryRules returns character columns", {
  out <- checkAncestryRules(validAncestryRules())
  expect_s3_class(out, "data.frame")
  expect_type(out$ancestry1, "character")
  expect_type(out$ancestry2, "character")
  expect_type(out$severity, "character")
})

test_that("checkAncestryRules normalizes case: levels to uppercase, severity to lowercase", {
  mixed <- data.frame(
    ancestry1 = "indian", ancestry2 = "Chinese", severity = "BLOCK",
    stringsAsFactors = FALSE
  )
  out <- checkAncestryRules(mixed)
  expect_identical(out$ancestry1, "INDIAN")
  expect_identical(out$ancestry2, "CHINESE")
  expect_identical(out$severity, "block")
})

test_that("checkAncestryRules accepts factor columns, returning character", {
  fct <- data.frame(
    ancestry1 = factor("INDIAN"), ancestry2 = factor("CHINESE"),
    severity = factor("block")
  )
  out <- checkAncestryRules(fct)
  expect_type(out$ancestry1, "character")
  expect_identical(out$ancestry1, "INDIAN")
})

test_that("checkAncestryRules stops when a required column is missing", {
  for (col in c("ancestry1", "ancestry2", "severity")) {
    bad <- validAncestryRules()
    bad[[col]] <- NULL
    expect_error(checkAncestryRules(bad), "missing")
  }
})

test_that("checkAncestryRules stops on a level outside convertAncestry()'s six", {
  bad <- validAncestryRules()
  bad$ancestry2[1L] <- "MAURITIUS"
  expect_error(checkAncestryRules(bad), "MAURITIUS")
})

test_that("checkAncestryRules stops on an unknown severity", {
  bad <- validAncestryRules()
  bad$severity[1L] <- "warn"
  expect_error(checkAncestryRules(bad), "warn")
})

test_that("checkAncestryRules stops on NA values", {
  # The "NA" message pattern keeps these RED-honest: a bare expect_error()
  # would be satisfied by the could-not-find-function error too.
  badLevel <- validAncestryRules()
  badLevel$ancestry1[1L] <- NA_character_
  expect_error(checkAncestryRules(badLevel), "NA")
  badSeverity <- validAncestryRules()
  badSeverity$severity[1L] <- NA_character_
  expect_error(checkAncestryRules(badSeverity), "NA")
})

test_that("checkAncestryRules accepts a self-pair rule (plan section 4)", {
  selfPair <- data.frame(
    ancestry1 = "HYBRID", ancestry2 = "HYBRID", severity = "block",
    stringsAsFactors = FALSE
  )
  expect_error(checkAncestryRules(selfPair), NA)
})

test_that("checkAncestryRules stops on a duplicated unordered pair", {
  bad <- data.frame(
    ancestry1 = c("INDIAN", "CHINESE"),
    ancestry2 = c("CHINESE", "INDIAN"), # same unordered pair
    severity = c("block", "flag"),
    stringsAsFactors = FALSE
  )
  expect_error(checkAncestryRules(bad), "duplicat")
})

test_that("checkAncestryRules duplicate detection applies after case coercion", {
  bad <- data.frame(
    ancestry1 = c("INDIAN", "indian"),
    ancestry2 = c("CHINESE", "chinese"),
    severity = c("block", "block"),
    stringsAsFactors = FALSE
  )
  expect_error(checkAncestryRules(bad), "duplicat")
})

test_that("checkAncestryRules stops on duplicated self-pair rows", {
  bad <- data.frame(
    ancestry1 = c("HYBRID", "HYBRID"),
    ancestry2 = c("HYBRID", "HYBRID"),
    severity = c("block", "flag"),
    stringsAsFactors = FALSE
  )
  expect_error(checkAncestryRules(bad), "duplicat")
})

test_that("checkAncestryRules accepts an empty rules table", {
  empty <- data.frame(
    ancestry1 = character(0L), ancestry2 = character(0L),
    severity = character(0L), stringsAsFactors = FALSE
  )
  out <- checkAncestryRules(empty)
  expect_identical(nrow(out), 0L)
  expect_true(all(c("ancestry1", "ancestry2", "severity") %in% names(out)))
})

test_that("checkAncestryRules ignores extra columns", {
  extra <- validAncestryRules()
  extra$note <- c("policy 2024-07", "review annually")
  expect_error(checkAncestryRules(extra), NA)
})

test_that("checkAncestryRules warns when UNKNOWN is named but OTHER is not (D6)", {
  oneSided <- data.frame(
    ancestry1 = "INDIAN", ancestry2 = "UNKNOWN", severity = "flag",
    stringsAsFactors = FALSE
  )
  expect_warning(checkAncestryRules(oneSided), "OTHER")
})

test_that("checkAncestryRules warns when OTHER is named but UNKNOWN is not (D6)", {
  oneSided <- data.frame(
    ancestry1 = "INDIAN", ancestry2 = "OTHER", severity = "flag",
    stringsAsFactors = FALSE
  )
  expect_warning(checkAncestryRules(oneSided), "UNKNOWN")
})

test_that("checkAncestryRules does not warn when UNKNOWN and OTHER are both named (D6)", {
  bothNamed <- data.frame(
    ancestry1 = c("INDIAN", "INDIAN"),
    ancestry2 = c("UNKNOWN", "OTHER"),
    severity = c("flag", "flag"),
    stringsAsFactors = FALSE
  )
  expect_warning(checkAncestryRules(bothNamed), NA)
})

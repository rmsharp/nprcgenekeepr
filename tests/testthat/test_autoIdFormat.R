## Copyright(c) 2017-2026 R. Mark Sharp
# This file is part of nprcgenekeepr
#
# Tests for the single-source-of-truth auto-generated unknown-ID format
# (GitHub #44 / #38): getAutoIdFormat() / setAutoIdFormat() public API, the
# internal getAutoIdPrefix() / isGeneratedUnknownId() predicate, and a
# non-default-format round trip (configure -> generate -> detect -> remove).
library(testthat)

# --- getAutoIdFormat() default --------------------------------------------
test_that("getAutoIdFormat() defaults to 'U%04d' with no option set", {
  old <- getOption("nprcgenekeepr.autoIdFormat")
  on.exit(options(nprcgenekeepr.autoIdFormat = old), add = TRUE)
  options(nprcgenekeepr.autoIdFormat = NULL)
  expect_equal(getAutoIdFormat(), "U%04d")
})

# --- setAutoIdFormat() set + read-back -------------------------------------
test_that("setAutoIdFormat() updates the format read by getAutoIdFormat()", {
  old <- getOption("nprcgenekeepr.autoIdFormat")
  on.exit(options(nprcgenekeepr.autoIdFormat = old), add = TRUE)
  setAutoIdFormat("AUTO%05d")
  expect_equal(getAutoIdFormat(), "AUTO%05d")
})

test_that("setAutoIdFormat() returns the previous value invisibly", {
  old <- getOption("nprcgenekeepr.autoIdFormat")
  on.exit(options(nprcgenekeepr.autoIdFormat = old), add = TRUE)
  options(nprcgenekeepr.autoIdFormat = NULL)
  res <- withVisible(setAutoIdFormat("AUTO%05d"))
  expect_false(res$visible)
  expect_equal(res$value, "U%04d")
})

# --- setAutoIdFormat() validation -----------------------------------------
test_that("setAutoIdFormat() rejects invalid formats", {
  old <- getOption("nprcgenekeepr.autoIdFormat")
  on.exit(options(nprcgenekeepr.autoIdFormat = old), add = TRUE)
  expect_error(setAutoIdFormat(123))                  # not character
  expect_error(setAutoIdFormat(NA_character_))        # NA
  expect_error(setAutoIdFormat(c("U%04d", "X%04d")))  # length > 1
  expect_error(setAutoIdFormat("%04d"))               # empty literal prefix
  expect_error(setAutoIdFormat("ABC"))                # no integer conversion
})

# --- getAutoIdPrefix() internal -------------------------------------------
test_that("getAutoIdPrefix() extracts the literal prefix before the first %", {
  expect_equal(getAutoIdPrefix("U%04d"), "U")
  expect_equal(getAutoIdPrefix("AUTO%05d"), "AUTO")
})

# --- isGeneratedUnknownId() predicate -------------------------------------
test_that("isGeneratedUnknownId() detects default-format ids, case-sensitively", {
  old <- getOption("nprcgenekeepr.autoIdFormat")
  on.exit(options(nprcgenekeepr.autoIdFormat = old), add = TRUE)
  options(nprcgenekeepr.autoIdFormat = NULL) # default U%04d
  expect_true(isGeneratedUnknownId("U0001"))
  expect_true(isGeneratedUnknownId("U123")) # prefix-only: any U-leading id
  expect_false(isGeneratedUnknownId("abc"))
  expect_false(isGeneratedUnknownId("u001")) # case-sensitive
})

test_that("isGeneratedUnknownId() preserves NA like startsWith()", {
  expect_true(is.na(isGeneratedUnknownId(NA_character_)))
})

test_that("isGeneratedUnknownId() is vectorized", {
  res <- isGeneratedUnknownId(c("U0001", "abc", "u001"))
  expect_equal(res, c(TRUE, FALSE, FALSE))
})

test_that("isGeneratedUnknownId() honors a configured non-default format", {
  old <- getOption("nprcgenekeepr.autoIdFormat")
  on.exit(options(nprcgenekeepr.autoIdFormat = old), add = TRUE)
  setAutoIdFormat("AUTO%05d")
  expect_true(isGeneratedUnknownId("AUTO00001"))
  expect_false(isGeneratedUnknownId("U0001")) # "U" is no longer the prefix
})

# --- round trip: configure -> generate -> detect -> remove ----------------
test_that("a non-default format round-trips through generation and detection", {
  old <- getOption("nprcgenekeepr.autoIdFormat")
  on.exit(options(nprcgenekeepr.autoIdFormat = old), add = TRUE)
  setAutoIdFormat("AUTO%05d")
  ped <- data.frame(
    id = c("s1", "d1", "o1"),
    sire = c(NA, NA, "s1"), # s1 has a dam but no sire -> gets an auto sire
    dam = c("d0", NA, "d1"),
    sex = c("M", "F", "F"),
    stringsAsFactors = FALSE
  )
  newPed <- addUIds(ped)
  minted <- newPed$sire[newPed$id == "s1"]
  expect_equal(minted, "AUTO00001") # generation honors the configured format
  expect_true(isGeneratedUnknownId(minted)) # detection honors the same format
  cleaned <- removeAutoGenIds(newPed)
  expect_true(is.na(cleaned$sire[cleaned$id == "s1"])) # minted sire removed
})

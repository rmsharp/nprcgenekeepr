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
  expect_false(isGeneratedUnknownId("U123")) # too short to be a placeholder
  expect_false(isGeneratedUnknownId("abc"))
  expect_false(isGeneratedUnknownId("u001")) # case-sensitive
})

# --- the tighter rule (placeholder-marking plan D3 (b), S807) --------------
# A placeholder is the prefix followed by at least as many capital letters or
# digits as the format's number part prints (4 for "U%04d"). So a real animal
# whose id merely starts with "U" is no longer taken for a stand-in.
test_that("isGeneratedUnknownId() reads short or lowercase U-leading ids as real", {
  old <- getOption("nprcgenekeepr.autoIdFormat")
  on.exit(options(nprcgenekeepr.autoIdFormat = old), add = TRUE)
  options(nprcgenekeepr.autoIdFormat = NULL) # default U%04d
  ## U1 is the real founder in the shipped ancestry example
  expect_identical(
    isGeneratedUnknownId(c("U1", "U123", "Uma", "Umbra", "U12a")),
    c(FALSE, FALSE, FALSE, FALSE, FALSE)
  )
})

test_that("isGeneratedUnknownId() still reads minted and de-identified placeholders", {
  old <- getOption("nprcgenekeepr.autoIdFormat")
  on.exit(options(nprcgenekeepr.autoIdFormat = old), add = TRUE)
  options(nprcgenekeepr.autoIdFormat = NULL)
  ## U0001: addUIds() output; U05X3C: obfuscateId() output in the shipped data
  expect_identical(
    isGeneratedUnknownId(c("U0001", "U05X3C", "U12345", "UABCD")),
    c(TRUE, TRUE, TRUE, TRUE)
  )
})

test_that("isGeneratedUnknownId() keeps NA in a mixed vector", {
  old <- getOption("nprcgenekeepr.autoIdFormat")
  on.exit(options(nprcgenekeepr.autoIdFormat = old), add = TRUE)
  options(nprcgenekeepr.autoIdFormat = NULL)
  expect_identical(
    isGeneratedUnknownId(c("U1", NA, "U0001")),
    c(FALSE, NA, TRUE)
  )
})

test_that("isGeneratedUnknownId() needs the width of a non-default format", {
  old <- getOption("nprcgenekeepr.autoIdFormat")
  on.exit(options(nprcgenekeepr.autoIdFormat = old), add = TRUE)
  setAutoIdFormat("AUTO%05d") # number part prints 5 characters
  expect_identical(
    isGeneratedUnknownId(c("AUTO00001", "AUTO1234", "AUTO123", "AUTOX7K2Q")),
    c(TRUE, FALSE, FALSE, TRUE)
  )
})

test_that("every id the format makes is recognized (default, wider, suffix)", {
  old <- getOption("nprcgenekeepr.autoIdFormat")
  on.exit(options(nprcgenekeepr.autoIdFormat = old), add = TRUE)
  n <- c(1L, 9L, 10L, 15L, 16L, 99L, 100L, 999L, 1000L, 9999L, 10000L,
         99999L, 100000L)
  for (fmt in c("U%04d", "AUTO%05d", "U%04d-x")) {
    setAutoIdFormat(fmt)
    expect_true(all(isGeneratedUnknownId(sprintf(fmt, n))), info = fmt)
  }
})

test_that("a suffix format round-trips through addUIds() and removeAutoGenIds()", {
  old <- getOption("nprcgenekeepr.autoIdFormat")
  on.exit(options(nprcgenekeepr.autoIdFormat = old), add = TRUE)
  setAutoIdFormat("U%04d-x")
  ped <- data.frame(
    id = c("s1", "d1", "o1"),
    sire = c(NA, NA, "s1"),
    dam = c("d0", NA, "d1"),
    sex = c("M", "F", "F"),
    stringsAsFactors = FALSE
  )
  newPed <- addUIds(ped)
  minted <- newPed$sire[newPed$id == "s1"]
  expect_identical(minted, "U0001-x")
  expect_true(isGeneratedUnknownId(minted))
  cleaned <- removeAutoGenIds(newPed)
  expect_true(is.na(cleaned$sire[cleaned$id == "s1"]))
})

# --- setAutoIdFormat() refuses formats the rule cannot read (D11, S807) -----
test_that("setAutoIdFormat() refuses a format whose ids would not be recognized", {
  old <- getOption("nprcgenekeepr.autoIdFormat")
  on.exit(options(nprcgenekeepr.autoIdFormat = old), add = TRUE)
  options(nprcgenekeepr.autoIdFormat = NULL)
  ## lowercase hex: sprintf("U%04x", 10L) is "U000a"
  expect_error(setAutoIdFormat("U%04x"), "would not be recognized")
  ## space padding: sprintf("U%4d", 1L) is "U   1"
  expect_error(setAutoIdFormat("U%4d"), "would not be recognized")
  expect_error(setAutoIdFormat("U%-4d"), "would not be recognized")
  ## a refused format leaves the setting as it was
  expect_identical(getAutoIdFormat(), "U%04d")
})

test_that("setAutoIdFormat() still accepts formats whose ids are recognized", {
  old <- getOption("nprcgenekeepr.autoIdFormat")
  on.exit(options(nprcgenekeepr.autoIdFormat = old), add = TRUE)
  for (fmt in c("U%04d", "AUTO%05d", "U%04d-x", "U%d", "U%04X")) {
    expect_no_error(setAutoIdFormat(fmt))
    expect_identical(getAutoIdFormat(), fmt)
  }
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

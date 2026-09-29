## Copyright(c) 2017-2026 R. Mark Sharp
# This file is part of nprcgenekeepr
library(testthat)
library(stringi)

set_seed(10L)
test_that("obfuscateId creates new ID with expected size", {
  id <- c("abc123", "george", "autumn")
  obfuscatedId <- obfuscateId(id, 6L)
  expect_length(obfuscatedId, 3L)
  expect_true(all(stri_length(obfuscatedId) == 6L))
  expect_length(id, length(unique(obfuscatedId)))
})
# this test is weak
test_that("obfuscateId does not create duplicates", { # this test is weak
  id <- stri_c(1L:10000L)
  obfuscatedId <- obfuscateId(id, 5L)
  expect_length(obfuscatedId, 10000L)
  expect_true(all(stri_length(obfuscatedId) == 5L))
  expect_length(id, length(unique(obfuscatedId)))
})

test_that("obfuscateId fails when duplicates cannot be avoided", {
  id <- stri_c(1L:10000L)
  expect_error(obfuscateId(id, size = 2L))
})
test_that("obfuscateId gives only placeholder ids placeholder-shaped aliases", {
  # #44 reconciliation: detection is case-sensitive (matches generation's
  # uppercase prefix), so lowercase "u001" is a real ID. Under the tighter
  # rule (placeholder-marking plan D3 (b), S807) "U123" is a real ID too: it
  # is shorter than the "U" + 4 characters a placeholder needs.
  old <- getOption("nprcgenekeepr.autoIdFormat")
  on.exit(options(nprcgenekeepr.autoIdFormat = old), add = TRUE)
  options(nprcgenekeepr.autoIdFormat = NULL)
  id <- c("U0001", "U123", "u001", "abc")
  alias <- obfuscateId(id, size = 5L)
  expect_identical(unname(isGeneratedUnknownId(alias)),
                   c(TRUE, FALSE, FALSE, FALSE))
  expect_true(stri_detect_regex(alias[1L], "^U"))
  expect_false(any(stri_detect_regex(alias[2L:4L], "^U")))
})

# D10 (S807): a placeholder alias must stay recognizable, so when `size` is
# too short for one, only the placeholder aliases are lengthened to the
# shortest recognizable length (prefix + the format's number width); real
# animals keep `size`. The De-identified Export allows an alias length of 4.
test_that("obfuscateId lengthens only placeholder aliases when size is too short", {
  old <- getOption("nprcgenekeepr.autoIdFormat")
  on.exit(options(nprcgenekeepr.autoIdFormat = old), add = TRUE)
  options(nprcgenekeepr.autoIdFormat = NULL) # U%04d: shortest is 5
  alias <- obfuscateId(c("U0001", "U05X3C", "abc", "george"), size = 4L)
  expect_identical(unname(stri_length(alias)), c(5L, 5L, 4L, 4L))
  expect_identical(unname(isGeneratedUnknownId(alias)),
                   c(TRUE, TRUE, FALSE, FALSE))
})

test_that("obfuscateId lengthens placeholder aliases to a wider format's width", {
  old <- getOption("nprcgenekeepr.autoIdFormat")
  on.exit(options(nprcgenekeepr.autoIdFormat = old), add = TRUE)
  setAutoIdFormat("AUTO%05d") # shortest recognizable placeholder is 9
  alias <- obfuscateId(c("AUTO00001", "real1"), size = 6L)
  expect_identical(unname(stri_length(alias)), c(9L, 6L))
  expect_identical(unname(isGeneratedUnknownId(alias)), c(TRUE, FALSE))
})

test_that("obfuscateId keeps size for placeholder aliases when size is long enough", {
  old <- getOption("nprcgenekeepr.autoIdFormat")
  on.exit(options(nprcgenekeepr.autoIdFormat = old), add = TRUE)
  options(nprcgenekeepr.autoIdFormat = NULL)
  alias <- obfuscateId(c("U0001", "abc"), size = 6L)
  expect_identical(unname(stri_length(alias)), c(6L, 6L))
})

## NEW-45 guarantee: obfuscated (de-identified) IDs must never contain a
## period ('.'). obfuscateId samples letters + digits only, so this holds on
## current code and must continue to hold (characterization guard).
test_that("obfuscateId generates period-free IDs (NEW-45 guarantee)", {
  ids <- obfuscateId(c("abc123", "george", "autumn"), size = 6L)
  expect_false(any(grepl(".", ids, fixed = TRUE)))
})

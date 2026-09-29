## Copyright(c) 2017-2026 R. Mark Sharp
# This file is part of nprcgenekeepr
#
# Direct unit tests for removeAutoGenIds() (GitHub #44). None existed before;
# the issue calls for adding one. Covers default-prefix removal (back-compat),
# case-sensitivity (real lowercase-u ids are kept), and a configured
# non-default prefix routed through the shared detection predicate.
library(testthat)

test_that("removeAutoGenIds() drops rows and parent refs with the default prefix", {
  old <- getOption("nprcgenekeepr.autoIdFormat")
  on.exit(options(nprcgenekeepr.autoIdFormat = old), add = TRUE)
  options(nprcgenekeepr.autoIdFormat = NULL) # default U%04d
  ped <- data.frame(
    id = c("A", "B", "U0001"),
    sire = c("U0002", "A", NA),
    dam = c("B", NA, NA),
    sex = c("M", "F", "F"),
    stringsAsFactors = FALSE
  )
  out <- removeAutoGenIds(ped)
  expect_false("U0001" %in% out$id) # auto-generated row removed
  expect_equal(sort(out$id), c("A", "B")) # real rows kept
  expect_true(is.na(out$sire[out$id == "A"])) # U-sire cleared to NA
  expect_equal(out$sire[out$id == "B"], "A") # real sire untouched
})

test_that("removeAutoGenIds() is case-sensitive (keeps real lowercase-u ids)", {
  old <- getOption("nprcgenekeepr.autoIdFormat")
  on.exit(options(nprcgenekeepr.autoIdFormat = old), add = TRUE)
  options(nprcgenekeepr.autoIdFormat = NULL)
  ped <- data.frame(
    id = c("u123", "B"),
    sire = c(NA, "u123"),
    dam = c(NA, NA),
    sex = c("M", "F"),
    stringsAsFactors = FALSE
  )
  out <- removeAutoGenIds(ped)
  expect_true("u123" %in% out$id) # lowercase u is NOT auto-generated
  expect_equal(out$sire[out$id == "B"], "u123") # real sire untouched
})

test_that("removeAutoGenIds() honors a configured non-default prefix", {
  old <- getOption("nprcgenekeepr.autoIdFormat")
  on.exit(options(nprcgenekeepr.autoIdFormat = old), add = TRUE)
  setAutoIdFormat("AUTO%05d")
  ped <- data.frame(
    id = c("A", "AUTO00001"),
    sire = c("AUTO00002", NA),
    dam = c(NA, NA),
    sex = c("M", "F"),
    stringsAsFactors = FALSE
  )
  out <- removeAutoGenIds(ped)
  expect_false("AUTO00001" %in% out$id) # auto-generated row removed
  expect_true(is.na(out$sire[out$id == "A"])) # AUTO-sire cleared to NA
})

# --- the tighter rule (placeholder-marking plan D3 (b), S807) --------------
test_that("removeAutoGenIds() keeps real ids that merely start with U", {
  old <- getOption("nprcgenekeepr.autoIdFormat")
  on.exit(options(nprcgenekeepr.autoIdFormat = old), add = TRUE)
  options(nprcgenekeepr.autoIdFormat = NULL) # default U%04d
  ped <- data.frame(
    id = c("U1", "Uma", "U123", "K1", "K2", "U0001"),
    sire = c(NA, NA, NA, "U123", "U0001", NA),
    dam = c(NA, NA, NA, "Uma", "U1", NA),
    sex = c("F", "F", "M", "F", "M", "M"),
    stringsAsFactors = FALSE
  )
  out <- removeAutoGenIds(ped)
  expect_setequal(out$id, c("U1", "Uma", "U123", "K1", "K2"))
  expect_identical(out$sire[out$id == "K1"], "U123") # real sire kept
  expect_identical(out$dam[out$id == "K1"], "Uma") # real dam kept
  expect_true(is.na(out$sire[out$id == "K2"])) # placeholder sire cleared
  expect_identical(out$dam[out$id == "K2"], "U1") # real dam kept
})

test_that("removeAutoGenIds() keeps the shipped ancestry example's real founder U1", {
  old <- getOption("nprcgenekeepr.autoIdFormat")
  on.exit(options(nprcgenekeepr.autoIdFormat = old), add = TRUE)
  options(nprcgenekeepr.autoIdFormat = NULL)
  ped <- qcStudbook(utils::read.csv(
    system.file("extdata", "examples", "example_ancestry_pedigree.csv",
                package = "nprcgenekeepr"),
    stringsAsFactors = FALSE, na.strings = c("", "NA")
  ))
  out <- removeAutoGenIds(ped)
  expect_true("U1" %in% out$id)
  expect_identical(nrow(out), nrow(ped)) # the example has no placeholders
})

# --- the placeholder mark (placeholder-marking plan Slice 2, D4, S808) -----
test_that("removeAutoGenIds() keeps a real U1234 marked FALSE, as an animal and as a parent", {
  old <- getOption("nprcgenekeepr.autoIdFormat")
  on.exit(options(nprcgenekeepr.autoIdFormat = old), add = TRUE)
  options(nprcgenekeepr.autoIdFormat = NULL) # default U%04d
  ped <- data.frame(
    id = c("U1234", "U0001", "D1", "K1", "K2"),
    sire = c(NA, NA, NA, "U1234", "U0001"),
    dam = c(NA, NA, NA, "D1", "D1"),
    sex = c("M", "M", "F", "F", "M"),
    placeholder = c(FALSE, TRUE, FALSE, FALSE, FALSE),
    stringsAsFactors = FALSE
  )
  out <- removeAutoGenIds(ped)
  expect_setequal(out$id, c("U1234", "D1", "K1", "K2"))
  expect_identical(out$sire[out$id == "K1"], "U1234") # real sire kept
  expect_true(is.na(out$sire[out$id == "K2"])) # placeholder sire cleared
})

## The marks are read from the whole pedigree before any row is removed: once
## UNK7's row is gone, its id has no row and the id-shape rule (which reads
## "UNK7" as real) would keep it as K1's sire.
test_that("removeAutoGenIds() removes a stand-in marked TRUE, as an animal and as a parent", {
  old <- getOption("nprcgenekeepr.autoIdFormat")
  on.exit(options(nprcgenekeepr.autoIdFormat = old), add = TRUE)
  options(nprcgenekeepr.autoIdFormat = NULL)
  ped <- data.frame(
    id = c("UNK7", "D1", "K1"),
    sire = c(NA, NA, "UNK7"),
    dam = c(NA, NA, "D1"),
    sex = c("M", "F", "F"),
    placeholder = c(TRUE, FALSE, FALSE),
    stringsAsFactors = FALSE
  )
  out <- removeAutoGenIds(ped)
  expect_setequal(out$id, c("D1", "K1"))
  expect_true(is.na(out$sire[out$id == "K1"]))
  expect_identical(out$dam[out$id == "K1"], "D1")
})

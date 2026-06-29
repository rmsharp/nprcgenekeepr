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

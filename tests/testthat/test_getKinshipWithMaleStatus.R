## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Tests for getKinshipWithMaleStatus() -- issue #112 Slice S2.
## The provider reports, among females aged >= minFemaleAge in a breeding
## group, the fraction that are essentially unrelated (kinship <= threshold)
## to at least one male aged >= minMaleAge in the group. Higher fraction is
## healthier: fraction < 0.6 -> red (1), 0.6 <= fraction <= 0.9 -> yellow (2),
## fraction > 0.9 -> green (3). An empty denominator (no eligible females)
## is reported as NA / NA / NA_integer_ -- deliberately NOT green.

## Build a named kinship matrix: every off-diagonal pair starts "related"
## (0.25, well above the 0.015625 threshold); the diagonal is a founder's
## 0.5 self-kinship; each pair in `unrelated` is set symmetrically to 0.
makeKmat <- function(ids, unrelated = list()) {
  kmat <- matrix(0.25, nrow = length(ids), ncol = length(ids),
                 dimnames = list(ids, ids))
  diag(kmat) <- 0.5
  for (pair in unrelated) {
    kmat[pair[1L], pair[2L]] <- 0
    kmat[pair[2L], pair[1L]] <- 0
  }
  kmat
}

makeGroup <- function(id, sex, age) {
  data.frame(id = id, sex = sex, age = age, stringsAsFactors = FALSE)
}

test_that("all eligible females unrelated to a male -> green (fraction 1)", {
  ids <- c("f1", "f2", "m1")
  group <- makeGroup(ids, c("F", "F", "M"), c(4, 4, 6))
  kmat <- makeKmat(ids, list(c("f1", "m1"), c("f2", "m1")))
  status <- getKinshipWithMaleStatus(group, kmat)
  expect_identical(names(status), c("fraction", "color", "colorIndex"))
  expect_equal(status$fraction, 1)
  expect_identical(status$color, "green")
  expect_identical(status$colorIndex, 3L)
})

test_that("all eligible females related to every male -> red (fraction 0)", {
  ids <- c("f1", "f2", "m1")
  group <- makeGroup(ids, c("F", "F", "M"), c(4, 4, 6))
  kmat <- makeKmat(ids)
  status <- getKinshipWithMaleStatus(group, kmat)
  expect_equal(status$fraction, 0)
  expect_identical(status$color, "red")
  expect_identical(status$colorIndex, 1L)
})

test_that("a male aged below minMaleAge is not an eligible mate", {
  ## The only male is 4 (< 5) and unrelated to both females; because he is
  ## too young the females have no eligible mate -> fraction 0 -> red.
  ids <- c("f1", "f2", "m1")
  group <- makeGroup(ids, c("F", "F", "M"), c(4, 4, 4))
  kmat <- makeKmat(ids, list(c("f1", "m1"), c("f2", "m1")))
  status <- getKinshipWithMaleStatus(group, kmat)
  expect_equal(status$fraction, 0)
  expect_identical(status$colorIndex, 1L)
})

test_that("fraction of exactly 0.6 is yellow (inclusive lower boundary)", {
  ## 5 eligible females, 3 unrelated to the male -> 3 / 5 = 0.6.
  ids <- c("f1", "f2", "f3", "f4", "f5", "m1")
  group <- makeGroup(ids, c("F", "F", "F", "F", "F", "M"),
                     c(4, 4, 4, 4, 4, 6))
  kmat <- makeKmat(ids, list(c("f1", "m1"), c("f2", "m1"), c("f3", "m1")))
  status <- getKinshipWithMaleStatus(group, kmat)
  expect_equal(status$fraction, 0.6)
  expect_identical(status$color, "yellow")
  expect_identical(status$colorIndex, 2L)
})

test_that("fraction of exactly 0.9 is yellow (inclusive upper boundary)", {
  ## 10 eligible females, 9 unrelated to the male -> 9 / 10 = 0.9.
  fem <- paste0("f", 1:10)
  ids <- c(fem, "m1")
  group <- makeGroup(ids, c(rep("F", 10L), "M"), c(rep(4, 10L), 6))
  unrelated <- lapply(fem[1:9], function(f) c(f, "m1"))
  kmat <- makeKmat(ids, unrelated)
  status <- getKinshipWithMaleStatus(group, kmat)
  expect_equal(status$fraction, 0.9)
  expect_identical(status$colorIndex, 2L)
})

test_that("kinship exactly at the threshold counts as unrelated", {
  ids <- c("f1", "m1")
  group <- makeGroup(ids, c("F", "M"), c(4, 6))
  kmat <- makeKmat(ids)
  kmat["f1", "m1"] <- kmat["m1", "f1"] <- 0.015625
  status <- getKinshipWithMaleStatus(group, kmat)
  expect_equal(status$fraction, 1)
  expect_identical(status$colorIndex, 3L)
})

test_that("kinship just above the threshold does not count", {
  ids <- c("f1", "m1")
  group <- makeGroup(ids, c("F", "M"), c(4, 6))
  kmat <- makeKmat(ids)
  kmat["f1", "m1"] <- kmat["m1", "f1"] <- 0.02
  status <- getKinshipWithMaleStatus(group, kmat)
  expect_equal(status$fraction, 0)
  expect_identical(status$colorIndex, 1L)
})

test_that("a female below minFemaleAge is excluded from the denominator", {
  ## fA (age 5) is related to the male; fB (age 2) is unrelated but too
  ## young. If the age filter works, the denominator is {fA} and the
  ## fraction is 0 (fA has no unrelated mate). If fB were wrongly counted,
  ## the fraction would be 0.5.
  ids <- c("fA", "fB", "m1")
  group <- makeGroup(ids, c("F", "F", "M"), c(5, 2, 6))
  kmat <- makeKmat(ids, list(c("fB", "m1")))
  status <- getKinshipWithMaleStatus(group, kmat)
  expect_equal(status$fraction, 0)
})

test_that("a sex 'U' member is neither a female nor an eligible male", {
  ## f1 is related to the male m1 but unrelated to the U animal u1. If u1
  ## were treated as a male mate the fraction would be 1 (green); correctly
  ## excluding U leaves f1 with no eligible mate -> fraction 0 -> red.
  ids <- c("f1", "m1", "u1")
  group <- makeGroup(ids, c("F", "M", "U"), c(4, 6, 8))
  kmat <- makeKmat(ids, list(c("f1", "u1")))
  status <- getKinshipWithMaleStatus(group, kmat)
  expect_equal(status$fraction, 0)
  expect_identical(status$colorIndex, 1L)
})

test_that("no eligible females -> NA fraction / NA colour / NA index", {
  ## Only a too-young female and a male; the denominator is empty.
  ids <- c("f1", "m1")
  group <- makeGroup(ids, c("F", "M"), c(2, 6))
  kmat <- makeKmat(ids, list(c("f1", "m1")))
  status <- getKinshipWithMaleStatus(group, kmat)
  expect_true(is.na(status$fraction))
  expect_true(is.na(status$color))
  expect_true(is.na(status$colorIndex))
})

test_that("a missing id/sex/age column is an error", {
  ids <- c("f1", "m1")
  kmat <- makeKmat(ids)
  noSex <- data.frame(id = ids, age = c(4, 6), stringsAsFactors = FALSE)
  expect_error(getKinshipWithMaleStatus(noSex, kmat), "group is missing: sex")
})

test_that("a group id absent from the kinship matrix is an error", {
  group <- makeGroup(c("f1", "f9"), c("F", "F"), c(4, 4))
  kmat <- makeKmat(c("f1", "m1"))
  expect_error(
    getKinshipWithMaleStatus(group, kmat),
    "kmat is missing kinship"
  )
})

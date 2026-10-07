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

## An animal with no birth date has no age (NA). It cannot be shown to be old
## enough to breed, so it is left out of both counts (S928 owner decision).
## Found S928: an NA age made the id subscript return an NA id, and the kinship
## lookup then stopped with "subscript out of bounds" (the shipped example
## pedigree's default top-ranked group has no birth date on any of its 20
## animals, so the Genetic Diversity heat map ended the user's session).

test_that("a female with no age is left out of the check, not an error", {
  ## f1 (age 4) is unrelated to m1; f2 has no age and is related to m1. If f2
  ## were counted the fraction would be 0.5 (red); left out it is 1 (green).
  ids <- c("f1", "f2", "m1")
  group <- makeGroup(ids, c("F", "F", "M"), c(4, NA, 6))
  kmat <- makeKmat(ids, list(c("f1", "m1")))
  status <- getKinshipWithMaleStatus(group, kmat)
  expect_equal(status$fraction, 1)
  expect_identical(status$colorIndex, 3L)
})

test_that("a male with no age is not an eligible mate, not an error", {
  ## m1 has no age and is unrelated to f1; m2 (age 6) is related to f1. If m1
  ## were counted as a mate the fraction would be 1; left out, f1 has no
  ## unrelated eligible mate, so it is 0 (red).
  ids <- c("f1", "m1", "m2")
  group <- makeGroup(ids, c("F", "M", "M"), c(4, NA, 6))
  kmat <- makeKmat(ids, list(c("f1", "m1")))
  status <- getKinshipWithMaleStatus(group, kmat)
  expect_equal(status$fraction, 0)
  expect_identical(status$colorIndex, 1L)
})

test_that("a group where no animal has an age -> NA fraction / NA colour / NA index", {
  ids <- c("f1", "f2", "m1")
  group <- makeGroup(ids, c("F", "F", "M"), rep(NA_real_, 3L))
  kmat <- makeKmat(ids, list(c("f1", "m1")))
  status <- getKinshipWithMaleStatus(group, kmat)
  expect_true(is.na(status$fraction))
  expect_true(is.na(status$color))
  expect_true(is.na(status$colorIndex))
})

test_that("an animal with no sex is neither a female nor an eligible male", {
  ## f1 is related to m1 but unrelated to x1, whose sex is missing. If x1 were
  ## treated as a mate the fraction would be 1; excluded, f1 has no unrelated
  ## eligible mate, so it is 0 (red). Same mechanism as a missing age: an NA in
  ## the logical subscript.
  ids <- c("f1", "m1", "x1")
  group <- makeGroup(ids, c("F", "M", NA), c(4, 6, 8))
  kmat <- makeKmat(ids, list(c("f1", "x1")))
  status <- getKinshipWithMaleStatus(group, kmat)
  expect_equal(status$fraction, 0)
  expect_identical(status$colorIndex, 1L)
})

## A female with no birth date and a listed offspring (S935 owner ruling). The
## Production cell counts such a female as a breeding-age mother only when the
## pedigree lists an offspring for her; the Inbreeding cell follows the same
## rule. `damIds` holds the IDs listed as a dam in the WHOLE pedigree, and
## isCountedMotherWithoutBirthDate() is the one place the rule lives. A male
## with no birth date stays out of the potential mates.

test_that("a female with no age counts as a breeding-age female when damIds lists her", {
  ## f1 (age 4) is unrelated to m1; f2 has no age and is related to m1. Counted,
  ## f2 makes it 1 of 2 = 0.5 (red); left out it is 1 (green).
  ids <- c("f1", "f2", "m1")
  group <- makeGroup(ids, c("F", "F", "M"), c(4, NA, 6))
  kmat <- makeKmat(ids, list(c("f1", "m1")))
  status <- getKinshipWithMaleStatus(group, kmat, damIds = "f2")
  expect_equal(status$fraction, 0.5)
  expect_identical(status$color, "red")
  expect_identical(status$colorIndex, 1L)
})

test_that("a female with no age stays out when damIds does not list her", {
  ids <- c("f1", "f2", "m1")
  group <- makeGroup(ids, c("F", "F", "M"), c(4, NA, 6))
  kmat <- makeKmat(ids, list(c("f1", "m1")))
  status <- getKinshipWithMaleStatus(group, kmat,
                                     damIds = c("elsewhere1", "elsewhere2"))
  expect_equal(status$fraction, 1)
  expect_identical(status$colorIndex, 3L)
})

test_that("a group whose only female has no age but a listed offspring has a result, not NA", {
  ## Without the rule she is left out and the metric is undefined (NA).
  ids <- c("f1", "m1")
  group <- makeGroup(ids, c("F", "M"), c(NA, 6))
  kmat <- makeKmat(ids, list(c("f1", "m1")))
  status <- getKinshipWithMaleStatus(group, kmat, damIds = "f1")
  expect_equal(status$fraction, 1)
  expect_identical(status$color, "green")
  expect_identical(status$colorIndex, 3L)
})

test_that("a counted female with no age who is related to every male scores red", {
  ids <- c("f1", "m1")
  group <- makeGroup(ids, c("F", "M"), c(NA, 6))
  kmat <- makeKmat(ids)
  status <- getKinshipWithMaleStatus(group, kmat, damIds = "f1")
  expect_equal(status$fraction, 0)
  expect_identical(status$colorIndex, 1L)
})

test_that("a known age under minFemaleAge stays out even when damIds lists her", {
  ## f2 is 1 year old and related to m1. A known age is judged by the age, not
  ## by the offspring list: f1 alone decides, 1 of 1 -> green.
  ids <- c("f1", "f2", "m1")
  group <- makeGroup(ids, c("F", "F", "M"), c(4, 1, 6))
  kmat <- makeKmat(ids, list(c("f1", "m1")))
  status <- getKinshipWithMaleStatus(group, kmat, damIds = "f2")
  expect_equal(status$fraction, 1)
  expect_identical(status$colorIndex, 3L)
})

test_that("an animal with no sex is not counted even when damIds lists it", {
  ## x1 has no sex and no age. If it were counted as a mother f1 would not be
  ## alone; left out, f1 is unrelated to m1: 1 of 1 -> green, and no error.
  ids <- c("f1", "m1", "x1")
  group <- makeGroup(ids, c("F", "M", NA), c(4, 6, NA))
  kmat <- makeKmat(ids, list(c("f1", "m1")))
  status <- getKinshipWithMaleStatus(group, kmat, damIds = "x1")
  expect_equal(status$fraction, 1)
  expect_identical(status$colorIndex, 3L)
})

test_that("a male with no age stays out of the mates even when damIds lists his id", {
  ## m1 has no age and is unrelated to f1; m2 (age 6) is related to f1. Males
  ## with no birth date are not counted, so f1 has no unrelated mate: red.
  ids <- c("f1", "m1", "m2")
  group <- makeGroup(ids, c("F", "M", "M"), c(4, NA, 6))
  kmat <- makeKmat(ids, list(c("f1", "m1")))
  status <- getKinshipWithMaleStatus(group, kmat, damIds = "m1")
  expect_equal(status$fraction, 0)
  expect_identical(status$colorIndex, 1L)
})

## Who counts as a breeding-age female lives in one place,
## isBreedingAgeFemale(). This test stubs it with a mask that DIFFERS from the
## real rule (the real rule counts f1, who is 4, and not f2) and checks the cell
## follows the stub. A control with the real rule comes first.

test_that("getKinshipWithMaleStatus asks isBreedingAgeFemale which females count", {
  ids <- c("f1", "f2", "m1")
  group <- makeGroup(ids, c("F", "F", "M"), c(4, NA, 6))
  kmat <- makeKmat(ids, list(c("f1", "m1")))
  ## Control: the real rule counts f1 only, who is unrelated to m1: 1 (green).
  control <- getKinshipWithMaleStatus(group, kmat, damIds = "elsewhere")
  expect_equal(control$fraction, 1)
  helper <- mockery::mock(c(FALSE, TRUE, FALSE))
  mockery::stub(getKinshipWithMaleStatus, "isBreedingAgeFemale", helper)
  status <- getKinshipWithMaleStatus(group, kmat, damIds = "elsewhere")
  mockery::expect_called(helper, 1L)
  ## The stub counts f2 only, who is related to m1: 0 (red).
  expect_equal(status$fraction, 0)
  args <- mockery::mock_args(helper)[[1L]]
  expect_identical(args[[1L]], group$id)
  expect_identical(args[[2L]], group$sex)
  expect_identical(args[[3L]], group$age)
  expect_identical(args[[4L]], 3L)
  expect_identical(args[[5L]], "elsewhere")
})

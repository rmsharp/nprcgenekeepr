## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

ped <- nprcgenekeepr::lacy1989Ped
# nolint start: object_name_linter.
simParent_1 <- list(
  id = "A",
  sires = c("s1_1", "s1_2", "s1_3"),
  dams = c("d1_1", "d1_2", "d1_3", "d1_4")
)
simParent_2 <- list(
  id = "B",
  sires = c("s2_1", "s2_2", "s2_3"),
  dams = c("d2_1", "d2_2", "d2_3", "d2_4")
)
simParent_3 <- list(
  id = "E",
  sires = c("s3_1", "s3_2", "s3_3"),
  dams = c("d3_1", "d3_2", "d3_3", "d3_4")
)
allSimParents <- list(simParent_1, simParent_2, simParent_3)

set_seed(seed = 1L)

simPed <- makeSimPed(ped, allSimParents)

test_that("makeSimPed creates a correct pedigree structure", {
  expect_identical(simPed$sire[simPed$id == "A"], "s1_1")
  expect_identical(simPed$sire[simPed$id == "B"], "s2_2")
  expect_identical(simPed$sire[simPed$id == "E"], "s3_1")

  expect_identical(simPed$dam[simPed$id == "A"], "d1_2")
  expect_identical(simPed$dam[simPed$id == "B"], "d2_4")
  expect_identical(simPed$dam[simPed$id == "E"], "d3_4")
})

set_seed(seed = 1L)

simPed <- makeSimPed(ped, allSimParents, verbose = TRUE)

test_that("makeSimPed creates a correct pedigree structure", {
  expect_identical(simPed$sire[simPed$id == "A"], "s1_1")
  expect_identical(simPed$sire[simPed$id == "B"], "s2_2")
  expect_identical(simPed$sire[simPed$id == "E"], "s3_1")

  expect_identical(simPed$dam[simPed$id == "A"], "d1_2")
  expect_identical(simPed$dam[simPed$id == "B"], "d2_4")
  expect_identical(simPed$dam[simPed$id == "E"], "d3_4")
})

simParent_4 <- list(
  id = "B",
  sires = NULL,
  dams = c("d2_1", "d2_2", "d2_3", "d2_4")
)
allSimParents <- list(simParent_1, simParent_4, simParent_3)
set_seed(seed = 1L)

simPed <- makeSimPed(ped, allSimParents)

test_that("makeSimPed creates a correct pedigree structure with no sires", {
  expect_identical(simPed$sire[simPed$id == "A"], "s1_1")
  expect_true(is.na(simPed$sire[simPed$id == "B"]))
  expect_identical(simPed$sire[simPed$id == "E"], "s3_3")

  expect_identical(simPed$dam[simPed$id == "A"], "d1_2")
  expect_identical(simPed$dam[simPed$id == "B"], "d2_3")
  expect_identical(simPed$dam[simPed$id == "E"], "d3_1")
})

set_seed(seed = 1L)

simPed <- makeSimPed(ped, allSimParents, verbose = TRUE)

test_that("makeSimPed creates a correct pedigree structure with no sires", {
  expect_identical(simPed$sire[simPed$id == "A"], "s1_1")
  expect_true(is.na(simPed$sire[simPed$id == "B"]))
  expect_identical(simPed$sire[simPed$id == "E"], "s3_3")

  expect_identical(simPed$dam[simPed$id == "A"], "d1_2")
  expect_identical(simPed$dam[simPed$id == "B"], "d2_3")
  expect_identical(simPed$dam[simPed$id == "E"], "d3_1")
})

simParent_5 <- list(
  id = "B",
  sires = c("s2_1", "s2_2", "s2_3"),
  dams = NULL
)

allSimParents <- list(simParent_1, simParent_5, simParent_3)
set_seed(seed = 1L)

simPed <- makeSimPed(ped, allSimParents)

test_that("makeSimPed creates a correct pedigree structure with no dams", {
  expect_identical(simPed$sire[simPed$id == "A"], "s1_1")
  expect_identical(simPed$sire[simPed$id == "B"], "s2_2")
  expect_identical(simPed$sire[simPed$id == "E"], "s3_3")

  expect_identical(simPed$dam[simPed$id == "A"], "d1_2")
  expect_true(is.na(simPed$dam[simPed$id == "B"]))
  expect_identical(simPed$dam[simPed$id == "E"], "d3_1")
})

set_seed(seed = 1L)

simPed <- makeSimPed(ped, allSimParents, verbose = TRUE)

test_that("makeSimPed creates a correct pedigree structure with no dams", {
  expect_identical(simPed$sire[simPed$id == "A"], "s1_1")
  expect_identical(simPed$sire[simPed$id == "B"], "s2_2")
  expect_identical(simPed$sire[simPed$id == "E"], "s3_3")

  expect_identical(simPed$dam[simPed$id == "A"], "d1_2")
  expect_true(is.na(simPed$dam[simPed$id == "B"]))
  expect_identical(simPed$dam[simPed$id == "E"], "d3_1")
  # nolint end: object_name_linter.
})

test_that("makeSimPed does not mutate the caller's pedigree (NEW-53)", {
  ## NEW-53: makeSimPed must not flip the caller's data.frame to a data.table
  ## by reference (setDT mutates the argument in place). Content is preserved
  ## either way (empirically only the class leaked), so the class is the
  ## discriminating assertion; the sire snapshot guards the content contract.
  pedDF <- as.data.frame(nprcgenekeepr::lacy1989Ped)
  expect_identical(class(pedDF), "data.frame") # precondition
  sireSnapshot <- paste0(pedDF$sire, collapse = "\r")
  localParents <- list(
    list(id = "A", sires = c("s1_1", "s1_2"), dams = c("d1_1", "d1_2")),
    list(id = "B", sires = c("s2_1", "s2_2"), dams = c("d2_1", "d2_2"))
  )
  set_seed(seed = 1L)
  invisible(makeSimPed(pedDF, localParents))
  expect_false(inherits(pedDF, "data.table"))
  expect_identical(class(pedDF), "data.frame")
  expect_identical(paste0(pedDF$sire, collapse = "\r"), sireSnapshot)
})

## Guard-known-parents contract (issue #109 finding #31, S277).
## makeSimPed must impute ONLY unknown (NA) parents and preserve known ones:
## a known sire/dam is left untouched regardless of the candidate vector, and
## only an unknown (NA) parent is (re)drawn from the representative pool.

test_that("makeSimPed preserves a known sire while imputing the unknown dam", {
  ped <- data.frame(
    id = c("KS", "X"),
    sire = c(NA_character_, "KS"),
    dam = c(NA_character_, NA_character_),
    stringsAsFactors = FALSE
  )
  set_seed(seed = 1L)
  simPed <- makeSimPed(
    ped,
    list(list(id = "X", sires = c("s1", "s2", "s3"), dams = c("d1", "d2")))
  )
  expect_identical(simPed$sire[simPed$id == "X"], "KS")
  expect_true(simPed$dam[simPed$id == "X"] %in% c("d1", "d2"))
})

test_that("makeSimPed does not erase a known sire given an empty vector", {
  ped <- data.frame(
    id = c("KS", "X"),
    sire = c(NA_character_, "KS"),
    dam = c(NA_character_, NA_character_),
    stringsAsFactors = FALSE
  )
  set_seed(seed = 1L)
  simPed <- makeSimPed(
    ped,
    list(list(id = "X", sires = NULL, dams = c("d1", "d2")))
  )
  expect_identical(simPed$sire[simPed$id == "X"], "KS")
})

test_that("makeSimPed preserves both parents when both are known", {
  ped <- data.frame(
    id = c("KS", "KD", "Y"),
    sire = c(NA_character_, NA_character_, "KS"),
    dam = c(NA_character_, NA_character_, "KD"),
    stringsAsFactors = FALSE
  )
  set_seed(seed = 1L)
  simPed <- makeSimPed(
    ped,
    list(list(id = "Y", sires = c("s1", "s2"), dams = c("d1", "d2")))
  )
  expect_identical(simPed$sire[simPed$id == "Y"], "KS")
  expect_identical(simPed$dam[simPed$id == "Y"], "KD")
})

test_that("makeSimPed still imputes an unknown parent from the pool", {
  ped <- data.frame(
    id = "Z",
    sire = NA_character_,
    dam = NA_character_,
    stringsAsFactors = FALSE
  )
  set_seed(seed = 1L)
  simPed <- makeSimPed(
    ped,
    list(list(id = "Z", sires = c("s1", "s2", "s3"), dams = c("d1", "d2")))
  )
  expect_true(simPed$sire[simPed$id == "Z"] %in% c("s1", "s2", "s3"))
  expect_true(simPed$dam[simPed$id == "Z"] %in% c("d1", "d2"))
})

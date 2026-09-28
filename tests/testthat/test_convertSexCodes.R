## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)
original <- c(
  "m", "male", "1", "MALE", "M", "F", "f", "female", "FemAle", "U",
  "Unknown", "H", "hermaphrodite", "U", "Unknown", "3", "4"
)
sexCodes <- convertSexCodes(original)
test_that("convertSexCodes makes correct transformations", {
  expect_true(is.factor(sexCodes))
  sexCodes <- as.character(sexCodes)
  expect_equal(sexCodes[1L], "M")
  expect_equal(sexCodes[2L], "M")
  expect_equal(sexCodes[3L], "M")
  expect_equal(sexCodes[4L], "M")
  expect_equal(sexCodes[5L], "M")
  expect_equal(sexCodes[6L], "F")
  expect_equal(sexCodes[7L], "F")
  expect_equal(sexCodes[8L], "F")
  expect_equal(sexCodes[9L], "F")
  expect_equal(sexCodes[10L], "U")
  expect_equal(sexCodes[11L], "U")
  expect_equal(sexCodes[12L], "U")
  expect_equal(sexCodes[13L], "U")
  expect_equal(sexCodes[14L], "U")
  expect_equal(sexCodes[15L], "U")
  expect_equal(sexCodes[16L], "U")
  expect_equal(sexCodes[17L], "U")
  sexCodes <- convertSexCodes(original, ignoreHerm = FALSE)
  sexCodes <- as.character(sexCodes)
  expect_equal(sexCodes[12L], "H")
  expect_equal(sexCodes[13L], "H")
  expect_equal(sexCodes[13L], "H")
  expect_equal(sexCodes[17L], "H")
})

## --- Blank, unrecognized and space-padded codes (S799) -----------------------
## A blank or unrecognized code reads as unknown ("U"), the same as a missing
## one, and spaces around a code are ignored. Before S799 each of these came
## back NA, which correctParentSex() then reported as a "female sire" or a
## "male dam".
unreadable <- c("", "   ", "xyz", "?", "0", "5", "Unk")
test_that("convertSexCodes reads a blank or unrecognized code as U", {
  for (herm in c(TRUE, FALSE)) {
    sexCodes <- convertSexCodes(unreadable, ignoreHerm = herm)
    expect_false(anyNA(sexCodes), info = paste("ignoreHerm", herm))
    expect_identical(as.character(sexCodes), rep("U", length(unreadable)),
      info = paste("ignoreHerm", herm)
    )
  }
})
test_that("convertSexCodes ignores spaces around a sex code", {
  padded <- c("M ", " F", " male ", "F\t", "  unknown", " 2 ")
  expect_identical(
    as.character(convertSexCodes(padded)),
    c("M", "F", "M", "F", "U", "F")
  )
  expect_identical(as.character(convertSexCodes(" 4 ")), "U")
  expect_identical(
    as.character(convertSexCodes(" 4 ", ignoreHerm = FALSE)), "H"
  )
})
test_that("control: convertSexCodes keeps its factor levels and NA handling", {
  sexCodes <- convertSexCodes(c(unreadable, "M ", NA))
  expect_true(is.factor(sexCodes))
  expect_identical(levels(sexCodes), c("F", "M", "H", "U"))
  expect_identical(as.character(convertSexCodes(NA_character_)), "U")
  expect_identical(
    as.character(convertSexCodes(c(1L, 2L, 3L, 4L))), c("M", "F", "U", "U")
  )
})

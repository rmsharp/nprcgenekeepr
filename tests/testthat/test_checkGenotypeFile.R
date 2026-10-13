## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(stringi) # nolint undesirable_function_linter.

ped <- nprcgenekeepr::qcPed
ped <- ped[order(ped$id), ]
genotype <- data.frame(
  id = ped$id[50L + 1L:20L],
  first_name = stri_c("first_name", 1L:20L),
  second_name = stri_c("second_name", 1L:20L),
  stringsAsFactors = FALSE
)

test_that("checkGenotypeFile allows correct dataframe", {
  expect_error(checkGenotypeFile(genotype), NA)
})
test_that("checkGenotypeFile disallows dataframe with < 3 columns", {
  expect_error(
    checkGenotypeFile(genotype[, c("id", "first_name")]),
    "Genotype file must have at least three columns."
  )
})
test_that("checkGenotypeFile ensures 'id' as the first column.", {
  names(genotype) <- c("ego", "first_name", "second_name")
  expect_error(
    checkGenotypeFile(genotype),
    "Genotype file must have 'id' as the first column."
  )
})
test_that(paste0(
  "checkGenotypeFile ensures cannot have a column named ",
  "'first' or 'second'."
), {
  names(genotype) <- c("id", "first", "second_name")
  expect_error(
    checkGenotypeFile(genotype),
    "Genotype file cannot have a column named 'first' or 'second'."
  )
})
genotype <- data.frame(
  id = ped$id[50L + 1L:20L],
  first_name = stri_c("first_name", 1L:20L),
  second_name = stri_c("sec:ond_name", 1L:20L),
  stringsAsFactors = FALSE
)
test_that("checkGenotypeFile detects a bad dataframe", {
  expect_true(inherits(checkGenotypeFile(genotype), "data.frame"))
})
genotype <- data.frame(
  id = ped$id[50L + 1L:20L],
  first_name = stri_c("first_name", 1L:20L),
  second_name = stri_c("second_name", 1L:20L),
  stringsAsFactors = FALSE
)
genotype$first_name[genotype$id == "1X1237"] <- "almost; ok"
test_that("checkGenotypeFile detects single error", {
  expect_s3_class(checkGenotypeFile(genotype), "data.frame")
})
genotype <- data.frame(
  id = ped$id[50L + 1L:20L],
  first_name = stri_c("first_name", 1L:20L),
  second = stri_c("second_name", 1L:20L),
  stringsAsFactors = FALSE
)
test_that("checkGenotypeFile detects illegal column name", {
  expect_error(checkGenotypeFile(genotype))
})
genotype <- data.frame(
  id = ped$id[50L + 1L:20L],
  first_name = stri_c(10001L:10020L),
  second_name = stri_c("second_name", 1L:20L),
  stringsAsFactors = FALSE
)
test_that(stri_c(
  "checkGenotypeFile checks for ossible collision on allele(s) ",
  "interpreted as a number"
), {
  expect_error(checkGenotypeFile(genotype))
})

## ---------------------------------------------------------------------
## RED (S979; BACKLOG.md:139, S976 audit finding 5, the owner's S976 ruling
## "one list, one line, name the column"): the collision error repeated its
## sentence once per allele (stri_c() was given sep, not collapse), carried 20
## spaces of source indentation and a line break, padded its numbers to a common
## width, and stopped at the first bad column, so the second column's alleles
## were never named (S979 probe: 10001 and 10002 in column 2 and 10003 in
## column 3 gave a 182-character message with 2 line breaks that never named
## 10003). Which files pass is not touched. The app swallows this error
## (R/modInput.R:499-503), so only script users read it.
## ---------------------------------------------------------------------
collisionSentence <-
  "Possible collision on allele(s) interpreted as a number > 10000:"

collisionGenotype <- function(first, second = c("x", "y", "z")) {
  data.frame(
    id = c("a", "b", "c"),
    first_name = first,
    second_name = second,
    stringsAsFactors = FALSE
  )
}

collisionMessage <- function(gt) {
  tryCatch(
    {
      checkGenotypeFile(gt)
      NA_character_
    },
    error = function(e) conditionMessage(e)
  )
}

test_that("checkGenotypeFile's collision error names the bad column and its one allele", {
  expect_identical(
    collisionMessage(collisionGenotype(c("10001", "1", "2"))),
    paste(collisionSentence, "10001 in column 'first_name'.")
  )
})

test_that("checkGenotypeFile's collision error lists several alleles of a column once each, in one list", {
  expect_identical(
    collisionMessage(collisionGenotype(c("10001", "10002", "2"))),
    paste(collisionSentence, "10001, 10002 in column 'first_name'.")
  )
})

test_that("checkGenotypeFile's collision error names every column with a collision, in one message", {
  gt <- collisionGenotype(c("10001", "10002", "2"), c("3", "10003", "4"))
  expect_identical(
    collisionMessage(gt),
    paste0(collisionSentence, " 10001, 10002 in column 'first_name'; ",
           "10003 in column 'second_name'.")
  )
})

test_that("checkGenotypeFile's collision error is one line, with no source indentation, and says its sentence once", {
  gt <- data.frame(
    id = paste0("a", 1L:20L),
    first_name = as.character(10001L:10020L),
    second_name = paste0("second_name", 1L:20L),
    stringsAsFactors = FALSE
  )
  msg <- collisionMessage(gt)
  expect_false(grepl("\n", msg, fixed = TRUE), info = msg)
  expect_false(grepl("  ", msg, fixed = TRUE), info = msg)
  expect_identical(
    lengths(regmatches(msg, gregexpr("Possible collision", msg, fixed = TRUE))),
    1L
  )
  expect_identical(
    msg,
    paste0(collisionSentence, " ",
           paste(10001L:10020L, collapse = ", "), " in column 'first_name'.")
  )
})

test_that("checkGenotypeFile's collision error writes its numbers without padding", {
  ## format() pads to a common width ("  10001", "100000"); the list is one
  ## line of plain numbers.
  expect_identical(
    collisionMessage(collisionGenotype(c("10001", "100000", "2"))),
    paste(collisionSentence, "10001, 100000 in column 'first_name'.")
  )
})

test_that("checkGenotypeFile's collision error lists a number once when two labels read as it", {
  ## collidingNumbers() repeats a number that two labels read as ("10500" and
  ## "10500.0"); the message names the number once.
  expect_identical(
    collisionMessage(collisionGenotype(c("10500", "10500.0", "2"))),
    paste(collisionSentence, "10500 in column 'first_name'.")
  )
})

test_that("checkGenotypeFile still passes alleles up to 10000 and still stops above it", {
  ## Guard, green at HEAD: the message changes, which files pass does not.
  expect_s3_class(
    checkGenotypeFile(collisionGenotype(c("10000", "9999", "1"))),
    "data.frame"
  )
  expect_s3_class(
    checkGenotypeFile(collisionGenotype(c("text", NA, "A1"))),
    "data.frame"
  )
  expect_error(
    checkGenotypeFile(collisionGenotype(c("10001", "1", "2"))),
    "Possible collision",
    fixed = TRUE
  )
})

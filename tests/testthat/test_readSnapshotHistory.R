## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# Issue #167 Slice 1: readSnapshotHistory(fileName, sep = ",") reads a
# user-maintained snapshot-history file (CSV/text or Excel) into a raw
# data.frame, mirroring readKinshipOverrides(). It does no validation --
# that is checkSnapshotHistory()'s job (the sibling-pair convention).

## The exact D1 column list (27 columns, three groups of nine) ratified by the
## issue #167 plan. This vector IS the schema fixed by Slice 1's RED phase.
snapshotHistoryColumns <- c(
  # provenance / comparability (D4)
  "schemaVersion", "snapshotDate", "packageVersion", "membershipRule",
  "guIter", "guThresh", "nAnimals", "nMales", "nFemales",
  # colony scalars, verbatim from reportGV()
  "fe", "fg", "fgSE", "neGD", "neSexRatio", "neVariance",
  "nMaleFounders", "nFemaleFounders", "nFounders",
  # colony aggregates of per-animal metrics (Summary Statistics definitions)
  "meanIndivMeanKin", "medianIndivMeanKin", "skewnessIndivMeanKin",
  "kurtosisIndivMeanKin", "meanGu", "medianGu", "meanGuSE",
  "skewnessGu", "kurtosisGu"
)

test_that("readSnapshotHistory reads the committed fixture with the exact D1 columns", {
  path <- system.file(
    "extdata", "examples", "example_snapshot_history.csv",
    package = "nprcgenekeepr"
  )
  res <- readSnapshotHistory(path)
  expect_true(is.data.frame(res))
  expect_identical(names(res), snapshotHistoryColumns)
  expect_identical(nrow(res), 4L)
  expect_identical(res$membershipRule,
                   c("wholePedigree", "wholePedigree", "wholePedigree",
                     "focalPopulation"))
})

test_that("readSnapshotHistory output validates with checkSnapshotHistory", {
  path <- system.file(
    "extdata", "examples", "example_snapshot_history.csv",
    package = "nprcgenekeepr"
  )
  out <- checkSnapshotHistory(readSnapshotHistory(path))
  expect_identical(nrow(out), 4L)
  expect_s3_class(out$snapshotDate, "Date")
})

test_that("readSnapshotHistory reads a delimited text file with a non-comma sep", {
  txt <- tempfile(fileext = ".txt")
  on.exit(unlink(txt), add = TRUE)
  history <- read.csv(system.file(
    "extdata", "examples", "example_snapshot_history.csv",
    package = "nprcgenekeepr"
  ), stringsAsFactors = FALSE)
  write.table(history, txt, sep = "\t", row.names = FALSE, quote = FALSE)
  res <- readSnapshotHistory(txt, sep = "\t")
  expect_identical(names(res), snapshotHistoryColumns)
  expect_identical(nrow(res), 4L)
})

test_that("readSnapshotHistory reads an Excel snapshot-history file", {
  skip_if_not_installed("openxlsx")
  xf <- tempfile(fileext = ".xlsx")
  on.exit(unlink(xf), add = TRUE)
  history <- read.csv(system.file(
    "extdata", "examples", "example_snapshot_history.csv",
    package = "nprcgenekeepr"
  ), stringsAsFactors = FALSE)
  status <- create_wkbk(file = xf, df_list = list(history),
                        sheetnames = "history", replace = TRUE)
  skip_if_not(isTRUE(status))
  res <- readSnapshotHistory(xf)
  expect_true(is.data.frame(res))
  expect_identical(names(res), snapshotHistoryColumns)
  expect_identical(nrow(res), 4L)
})

## S1005 (BACKLOG ruling S1004): an Excel file is read as text, so the reader
## must turn the 24 numeric columns into numbers, as the CSV path does.
## snapshotDate, packageVersion and membershipRule are text and stay text.
snapshotTextColumns <- c("snapshotDate", "packageVersion", "membershipRule")
snapshotExamplePath <- system.file(
  "extdata", "examples", "example_snapshot_history.csv",
  package = "nprcgenekeepr"
)

test_that("readSnapshotHistory gives an Excel file the same table as the CSV of the same data", {
  history <- read.csv(snapshotExamplePath, stringsAsFactors = FALSE)
  xf <- writeTestXlsx(history, "history")
  on.exit(unlink(xf), add = TRUE)

  res <- readSnapshotHistory(xf)

  numericCols <- setdiff(names(res), snapshotTextColumns)
  expect_length(numericCols, 24L)
  expect_true(all(vapply(res[numericCols], is.numeric, logical(1L))))
  expect_type(res$snapshotDate, "character")
  expect_equal(res, readSnapshotHistory(snapshotExamplePath))
})

test_that("an Excel snapshot history passes checkSnapshotHistory with the CSV's result", {
  history <- read.csv(snapshotExamplePath, stringsAsFactors = FALSE)
  xf <- writeTestXlsx(history, "history")
  on.exit(unlink(xf), add = TRUE)

  res <- checkSnapshotHistory(readSnapshotHistory(xf))

  expect_identical(nrow(res), 4L)
  expect_equal(res, checkSnapshotHistory(readSnapshotHistory(snapshotExamplePath)))
})

test_that("a text cell in an Excel numeric column leaves it as text, so the check names that column", {
  history <- read.csv(snapshotExamplePath, stringsAsFactors = FALSE)
  history$nAnimals <- as.character(history$nAnimals)
  history$nAnimals[2L] <- "many"
  xf <- writeTestXlsx(history, "history")
  on.exit(unlink(xf), add = TRUE)

  res <- readSnapshotHistory(xf)

  expect_type(res$schemaVersion, "double")
  expect_type(res$nAnimals, "character")
  expect_error(checkSnapshotHistory(res), "'nAnimals' column must be numeric")
})

## Guard (passes before the fix): a real Excel date cell keeps reading as an
## ISO date, so converting the numeric columns must not touch snapshotDate.
test_that("a real Excel date cell in snapshotDate still reads as an ISO date text", {
  history <- read.csv(snapshotExamplePath, stringsAsFactors = FALSE)
  expected <- history$snapshotDate
  history$snapshotDate <- as.Date(history$snapshotDate)
  xf <- writeTestXlsx(history, "history")
  on.exit(unlink(xf), add = TRUE)

  res <- readSnapshotHistory(xf)

  expect_identical(res$snapshotDate, expected)
})

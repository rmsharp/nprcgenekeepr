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

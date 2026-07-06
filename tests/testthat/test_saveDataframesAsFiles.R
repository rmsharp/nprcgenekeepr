## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)
dfList <- list(
  lacy1989Ped = nprcgenekeepr::lacy1989Ped,
  pedGood = nprcgenekeepr::pedGood
)

## Issue #111 coverage backfill: the input-type guard (line 33) and the Excel
## write-failure stop (line 53) were never exercised -- all valid-list tests
## skip the guard, and the real Excel path is user-gated and always succeeds.
test_that("saveDataframesAsFiles rejects a non-dataframe list element", {
  expect_error(
    saveDataframesAsFiles(list(a = 1:3), baseDir = tempdir()),
    "must be a list containing only dataframes"
  )
})

test_that("saveDataframesAsFiles stops when the Excel write fails", {
  testthat::local_mocked_bindings(create_wkbk = function(...) FALSE)
  expect_error(
    saveDataframesAsFiles(list(d = data.frame(x = 1)), tempdir(), "excel"),
    "Failed to write"
  )
})

test_that("makeExamplePedigreeFile creates CSV files", {
  skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "rmsharp")
  files_csv <- saveDataframesAsFiles(dfList,
    baseDir = tempdir(),
    fileType = "csv"
  )
  # nolint start: object_name_linter.
  pedCsv_1 <- read.table(files_csv[1L],
    sep = ",", header = TRUE,
    stringsAsFactors = FALSE
  )
  expect_named(pedCsv_1, names(nprcgenekeepr::lacy1989Ped))
  expect_identical(
    row.names.data.frame(pedCsv_1),
    row.names.data.frame(nprcgenekeepr::lacy1989Ped)
  )
  pedCsv_2 <- read.table(files_csv[2L],
    sep = ",", header = TRUE,
    stringsAsFactors = FALSE
  )
  expect_named(pedCsv_2, names(nprcgenekeepr::pedGood))
  expect_identical(
    row.names.data.frame(pedCsv_2),
    row.names.data.frame(nprcgenekeepr::pedGood)
  )
})
test_that("makeExamplePedigreeFile creates TXT files", {
  skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "rmsharp")
  files_csv <- saveDataframesAsFiles(dfList,
    baseDir = tempdir(),
    fileType = "txt"
  )
  pedCsv_1 <- read.table(files_csv[1L],
    sep = "\t", header = TRUE,
    stringsAsFactors = FALSE
  )
  expect_named(pedCsv_1, names(nprcgenekeepr::lacy1989Ped))
  expect_identical(
    row.names.data.frame(pedCsv_1),
    row.names.data.frame(nprcgenekeepr::lacy1989Ped)
  )
  pedCsv_2 <- read.table(files_csv[2L],
    sep = "\t", header = TRUE,
    stringsAsFactors = FALSE
  )
  expect_named(pedCsv_2, names(nprcgenekeepr::pedGood))
  expect_identical(
    row.names.data.frame(pedCsv_2),
    row.names.data.frame(nprcgenekeepr::pedGood)
  )
})
test_that("makeExamplePedigreeFile creates Excel files", {
  skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "rmsharp")
  files_csv <- saveDataframesAsFiles(dfList,
    baseDir = tempdir(),
    fileType = "excel"
  )
  pedCsv_1 <- suppressWarnings(getPedigree(files_csv[1L]))

  expect_named(pedCsv_1, names(nprcgenekeepr::lacy1989Ped))
  expect_identical(
    row.names.data.frame(pedCsv_1),
    row.names.data.frame(nprcgenekeepr::lacy1989Ped)
  )

  pedCsv_2 <- suppressWarnings(getPedigree(files_csv[2L]))
  expect_named(pedCsv_2, names(nprcgenekeepr::pedGood))
  expect_identical(
    row.names.data.frame(pedCsv_2),
    row.names.data.frame(nprcgenekeepr::pedGood)
  )
  # nolint end: object_name_linter.
})

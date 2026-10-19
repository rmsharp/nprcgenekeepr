## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#
# The shared Input-tab upload helper (helper-inputTabUpload.R; BACKLOG.md:168,
# S1015). uploadPedigreeFile() returns the Input module's qcResults().
# uploadPedigreeFileQc() returns that as `results`, with the module's
# qcSummary() as `summary` and its isReady() as `ready`, for the tests that
# read all three. Both go through the one upload block in the helper.
library(testthat)
testthat::skip_on_cran()

## pedGood (8 animals) written to a temporary file, `edit` applied first: a
## CSV by default, or a tab-separated text file with sep = "\t".
writePedGood <- function(edit = identity, sep = ",") {
  ped <- edit(nprcgenekeepr::pedGood)
  path <- tempfile(fileext = if (identical(sep, ",")) ".csv" else ".txt")
  if (identical(sep, ",")) {
    write.csv(ped, path, row.names = FALSE, na = "")
  } else {
    write.table(ped, path, sep = sep, row.names = FALSE, quote = FALSE,
                na = "")
  }
  path
}

test_that("uploadPedigreeFileQc() returns the summary, the results and the ready flag for a clean file", {
  skip_if_not_installed("shiny")
  path <- writePedGood()
  on.exit(unlink(path))
  got <- uploadPedigreeFileQc(path)
  expect_named(got, c("summary", "results", "ready"), ignore.order = TRUE)
  expect_identical(got$summary$errors, 0L)
  expect_identical(got$summary$warnings, 0L)
  expect_identical(got$summary$records, 8L)
  expect_true(got$ready)
  expect_identical(nrow(got$results$errors), 0L)
  expect_identical(nrow(got$results$cleaned), 8L)
})

test_that("uploadPedigreeFileQc() reports one invalid birth date as an error and not ready", {
  skip_if_not_installed("shiny")
  path <- writePedGood(function(ped) {
    ped$birth_date <- as.character(ped$birth_date)
    ped$birth_date[1L] <- "2010-16-22"
    ped
  })
  on.exit(unlink(path))
  got <- uploadPedigreeFileQc(path)
  expect_identical(got$summary$errors, 1L)
  expect_identical(got$summary$warnings, 0L)
  expect_identical(got$summary$records, 0L)
  expect_false(got$ready)
  expect_identical(got$results$errors$Error, "Invalid date values")
  expect_identical(got$results$errors$Details, "1")
})

test_that("uploadPedigreeFileQc() passes the file type and separator to the module", {
  skip_if_not_installed("shiny")
  csvPath <- writePedGood()
  tabPath <- writePedGood(sep = "\t")
  on.exit(unlink(c(csvPath, tabPath)))
  fromCsv <- uploadPedigreeFileQc(csvPath)
  fromTab <- uploadPedigreeFileQc(tabPath, fileType = "fileTypeText",
                                  separator = "\t")
  expect_identical(fromTab$summary, fromCsv$summary)
  expect_true(fromTab$ready)
  expect_identical(fromTab$results$cleaned, fromCsv$results$cleaned)
  ## The control: the same tab-separated file read with the comma separator
  ## is not a usable pedigree, so the arguments above are what made it one.
  asComma <- uploadPedigreeFileQc(tabPath)
  expect_false(asComma$ready)
})

test_that("uploadPedigreeFile() returns exactly the results of uploadPedigreeFileQc()", {
  skip_if_not_installed("shiny")
  path <- writePedGood()
  on.exit(unlink(path))
  expect_identical(uploadPedigreeFile(path),
                   uploadPedigreeFileQc(path)$results)
})

test_that("uploadPedigreeFile() still returns the module's results alone", {
  skip_if_not_installed("shiny")
  path <- writePedGood()
  on.exit(unlink(path))
  res <- uploadPedigreeFile(path)
  expect_true(all(c("cleaned", "errors", "warnings") %in% names(res)))
  expect_false(any(c("summary", "ready") %in% names(res)))
})

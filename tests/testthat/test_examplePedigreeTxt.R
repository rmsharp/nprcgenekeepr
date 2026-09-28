## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#
# The shipped tab-delimited example ExamplePedigree.txt (BACKLOG.md, found
# S800; rebuilt S801). It is the only text-format example under inst/extdata,
# the file a user can try the app's text upload with, and it had been saved
# through Excel: every recorded age was written as Excel's date display of the
# number (7.8 as "1900-01-07", an age under 1 as "1900-01-00", a negative age
# as "#####") and the id "15FEBR" as "15-Feb". The app's text upload carried
# that date text in the age column, and getPedigree() could not read the file
# at all, because read.table() treats "#" as the start of a comment. The file
# now holds the same cells as ExamplePedigree.csv.
library(testthat)
testthat::skip_on_cran()

examplePath <- function(file) {
  system.file("extdata", "examples", file, package = "nprcgenekeepr")
}
txtPath <- examplePath("ExamplePedigree.txt")
csvPath <- examplePath("ExamplePedigree.csv")

## Uploads a file through the real Input module (read, then runQcStudbook()),
## returning the module's qcResults().
uploadExample <- function(path, fileType, separator) {
  got <- new.env()
  shiny::testServer(modInputServer, {
    session$setInputs(fileContent = "pedFile", fileType = fileType,
                      separator = separator, minSireAge = "", minDamAge = "")
    session$setInputs(pedigreeFileOne = list(name = basename(path),
                                             datapath = path))
    session$setInputs(getData = 1L)
    got$res <- qcResults()
  })
  got$res
}

test_that("ExamplePedigree.txt holds the same cells as ExamplePedigree.csv", {
  ## Every cell read as the text the file holds ("NA" stays "NA", a blank
  ## stays ""), so this compares the files, not how a reader interprets them.
  txt <- read.delim(txtPath, colClasses = "character",
                    na.strings = character(0))
  csv <- read.csv(csvPath, colClasses = "character",
                  na.strings = character(0))
  recordedAge <- txt$age[txt$age != "NA"]
  expect_identical(sum(is.na(suppressWarnings(as.numeric(recordedAge)))), 0L)
  expect_true("15FEBR" %in% txt$id)
  expect_identical(txt, csv)
})

test_that("ExamplePedigree.txt uses plain line endings and ends with one", {
  bytes <- readBin(txtPath, "raw", file.size(txtPath))
  expect_false(any(bytes == as.raw(13L))) # no carriage return
  expect_identical(bytes[length(bytes)], as.raw(10L))
})

test_that("getPedigree() reads ExamplePedigree.txt as it reads the CSV", {
  expect_no_error(getPedigree(txtPath, sep = "\t"))
  got <- tryCatch(getPedigree(txtPath, sep = "\t"), error = function(e) NULL)
  expect_identical(got, getPedigree(csvPath))
})

test_that("the app's text upload of ExamplePedigree.txt matches the CSV's", {
  skip_if_not_installed("shiny")
  fromTxt <- uploadExample(txtPath, "fileTypeText", "\t")
  fromCsv <- uploadExample(csvPath, "fileTypeExcel", ",")
  expect_identical(nrow(fromTxt$errors), 0L)
  expect_identical(nrow(fromCsv$errors), 0L)
  expect_identical(nrow(fromCsv$cleaned), 3694L)
  expect_identical(fromTxt$cleaned, fromCsv$cleaned)
})

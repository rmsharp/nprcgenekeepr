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

## A Windows checkout must keep those plain line endings too (found S804). Git
## for Windows ships with core.autocrlf=true, which the windows-latest CI
## runner gets, and that setting writes every line ending as CRLF on checkout
## unless the repository's .gitattributes pins the file to LF; that is how
## R-CMD-check's windows-latest leg came to fail the test above. `git cat-file
## --filters` prints the bytes a checkout under the given settings would
## write, without making one. It runs only from the source repository, so it
## skips under R CMD check.
isGitTopLevel <- function(dir) {
  if (!nzchar(Sys.which("git"))) return(FALSE)
  top <- suppressWarnings(system2("git", c("-C", shQuote(dir), "rev-parse",
                                           "--show-toplevel"),
                                  stdout = TRUE, stderr = FALSE))
  is.null(attr(top, "status")) && length(top) == 1L &&
    normalizePath(top) == normalizePath(dir)
}

checkoutBytes <- function(root, gitConfig, path) {
  out <- tempfile()
  on.exit(unlink(out))
  configArgs <- as.vector(rbind("-c", gitConfig))
  status <- system2("git", c("-C", shQuote(root), configArgs, "cat-file",
                             "--filters", paste0("HEAD:", path)),
                    stdout = out, stderr = FALSE)
  if (!identical(status, 0L)) stop("git cat-file --filters failed: ", status)
  readBin(out, "raw", file.size(out))
}

test_that("a Windows checkout of ExamplePedigree.txt keeps plain line endings", {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = FALSE)
  skip_if_not(isGitTopLevel(root), "not run from the source git repository")
  shipped <- readBin(txtPath, "raw", file.size(txtPath))
  ## core.autocrlf=true: Git for Windows' default and the windows-latest
  ## runner's. core.eol=crlf: a user who asks for CRLF in every text file.
  settings <- list(autocrlf = "core.autocrlf=true",
                   eol = c("core.autocrlf=false", "core.eol=crlf"))
  for (setting in names(settings)) {
    bytes <- checkoutBytes(root, settings[[setting]],
                           "inst/extdata/examples/ExamplePedigree.txt")
    expect_false(any(bytes == as.raw(13L)), info = setting)
    expect_identical(bytes, shipped, info = setting)
  }
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

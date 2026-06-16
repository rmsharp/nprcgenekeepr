#' Copyright(c) 2017-2025 R. Mark Sharp
#' This file is part of nprcgenekeepr
#' In-process regression test for GitHub issue #4 at the Shiny UPLOAD layer.
#'
#' S89 wrapped modInput's two upload readers (read.table / read.csv) in
#' muffleIncompleteFinalLine(). This drives modInputServer's getData observer
#' via shiny::testServer (no browser) with a SMALL no-trailing-newline upload
#' and asserts the "incomplete final line" warning does NOT escape the read,
#' while every record is still parsed and QC-clean.
#'
#' Fixture size is load-bearing: read.table / read.csv only emit the
#' "incomplete final line found by readTableHeader" warning when the header /
#' type-detection scan (~the first few lines) actually reaches the unterminated
#' final line -- i.e. for SMALL files (the condition the user hit with 0.txt);
#' a large file never triggers it (verified S90). So the fixture here is a
#' 3-founder pedigree (4 lines). Teeth verified S90: un-muffling either read
#' site makes the warning escape getData and the expect_false() below fails.
library(testthat)
library(shiny)

# Header + 3 founder rows of ExamplePedigree.csv (founders have no parents, so
# QC is clean), written WITHOUT a trailing final newline -> 4 lines, which
# triggers the incomplete-final-line warning S89 muffles.
tiny_no_final_newline <- function(ext = ".csv") {
  src <- system.file("extdata", "ExamplePedigree.csv",
                     package = "nprcgenekeepr")
  ln <- readLines(src, warn = FALSE)[1:4]
  dest <- tempfile(fileext = ext)
  cat(paste(ln, collapse = "\n"), file = dest)
  dest
}

# Drive modInputServer's getData with `fixture` + `fileType`, capturing any
# warning that escapes the read. Returns list(warned, rows, errors).
run_upload <- function(fixture, fileType, separator = ",") {
  fileval <- data.frame(
    name = basename(fixture), size = file.info(fixture)$size,
    type = "text/plain", datapath = fixture, stringsAsFactors = FALSE
  )
  out <- list(warned = NA, rows = NA_integer_, errors = NA_integer_)
  testServer(modInputServer, {
    session$setInputs(fileType = fileType, separator = separator,
                      fileContent = "pedFile", minParentAge = "2.0",
                      pedigreeFileOne = fileval)
    captured <- character(0)
    withCallingHandlers(
      session$setInputs(getData = 1),
      warning = function(w) {
        captured <<- c(captured, conditionMessage(w))
        invokeRestart("muffleWarning")
      }
    )
    out$warned <<- any(grepl("incomplete final line", captured, fixed = TRUE))
    summary <- session$returned$qcSummary()
    out$rows <<- summary$records
    out$errors <<- summary$errors
  }, args = list(id = "test"))
  out
}

test_that("read.csv upload path muffles incomplete-final-line, keeps rows", {
  res <- run_upload(tiny_no_final_newline(".csv"), "fileTypeExcel")
  expect_false(
    res$warned,
    info = "read.csv path must not leak the incomplete-final-line warning"
  )
  expect_equal(res$rows, 3L,
               info = "all 3 founder records survive the read + QC")
  expect_equal(res$errors, 0L)
})

test_that("read.table upload path muffles incomplete-final-line, keeps rows", {
  res <- run_upload(tiny_no_final_newline(".txt"), "fileTypeText", ",")
  expect_false(
    res$warned,
    info = "read.table path must not leak the incomplete-final-line warning"
  )
  expect_equal(res$rows, 3L,
               info = "all 3 founder records survive the read + QC")
  expect_equal(res$errors, 0L)
})

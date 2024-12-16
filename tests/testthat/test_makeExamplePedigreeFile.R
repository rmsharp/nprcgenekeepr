#' Copyright(c) 2017-2020 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("makeExamplePedigreeFile")
library(testthat)
test_that("makeExamplePedigreeFile creates file", {
  skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "rmsharp")
  pedigreeFile <- suppressMessages(makeExamplePedigreeFile())
  expect_true(all(file.exists(pedigreeFile)))
})
test_that("makeExamplePedigreeFile creates correct file contents", {
  skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "rmsharp")
  pedigreeFile <- suppressMessages(makeExamplePedigreeFile())
  pedCsv <- read.table(pedigreeFile, sep = ",", header = TRUE,
                              stringsAsFactors = FALSE)
  expect_equal(nrow(pedCsv), 3694)
})

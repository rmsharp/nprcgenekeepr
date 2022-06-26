#' Copyright(c) 2017-2022 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("makeExamplePedigreeFile")
library(testthat)
test_that("makeExamplePedigreeFile creates file when defaults are used", {
  skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "msharp")
  pedigreeFile <- suppressMessages(makeExamplePedigreeFile())
  expect_true(all(file.exists(pedigreeFile)))
})
test_that(
  paste0("makeExamplePedigreeFile creates correct file contents when ",
         "defaults are used"), {
  skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "msharp")
  pedigreeFile <- suppressMessages(makeExamplePedigreeFile())
  pedCsv <- read.table(pedigreeFile, sep = ",", header = TRUE,
                              stringsAsFactors = FALSE)
  file.remove(pedigreeFile)
  expect_equal(nrow(pedCsv), 3694)
})
test_that(
  paste0("makeExamplePedigreeFile creates correct file when Excel file ",
         "is requested"), {
  skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "msharp")
  pedigreeFile <- suppressMessages(makeExamplePedigreeFile(
    file = file.path(tempdir(), "examplePedigree.xlsx"), fileType = "excel"))
  expect_true(all(file.exists(pedigreeFile)))
  pedExcel <- as.data.frame(readxl::read_excel(path = pedigreeFile, na = "NA",
                                               col_types = rep("text", 12)),
                            stringsAsFactors = FALSE)
  file.remove(pedigreeFile)
  expect_equal(nrow(pedExcel), 3694)
})
test_that(
  paste0("makeExamplePedigreeFile creates correct file when text file ",
         "is requested"), {
           skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "msharp")
           pedigreeFile <- suppressMessages(makeExamplePedigreeFile(
             file = file.path(tempdir(), "examplePedigree.txt"),
             fileType = "txt"))
           expect_true(all(file.exists(pedigreeFile)))
           pedTxt <- read.table(pedigreeFile, sep = "\t", header = TRUE,
                                stringsAsFactors = FALSE)

           file.remove(pedigreeFile)
           expect_equal(nrow(pedTxt), 3694)
         })



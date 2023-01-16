#' Copyright(c) 2017-2023 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("getPedigree")

test_that("getPedigree recognizes no file and wrong file arguments", {
  expect_error(getPedigree(), "\"fileName\" is missing, with no default")
})
test_that("getPedigree recognizes and opens Excel files.", {
  pedExcel <- suppressWarnings(
    getPedigree(fileName = system.file("testdata", "qcPed.xlsx",
                                       package = "nprcgenekeepr")))
  expect_equal(nrow(pedExcel), 280)
})
test_that(
  paste0("getPedigree recognizes and opens CSV files with default ",
         "comma separator."), {
           pedCsv <-
             getPedigree(fileName = system.file("testdata", "qcPed.csv",
                                                package = "nprcgenekeepr"))
           expect_equal(nrow(pedCsv), 280)
                 })
test_that(
  paste0("getPedigree recognizes and opens CSV files with specified ",
         "comma separator."), {
           pedCsv2 <-
             getPedigree(fileName = system.file("testdata",
                                                "qcPed.csv",
                                                package = "nprcgenekeepr"),
                                            sep = ",")
                   expect_equal(nrow(pedCsv2), 280)
                 })
test_that(
  paste0("getPedigree recognizes and opens .txt files with specified ",
         "tab separator."), {
           pedTxt <-
             getPedigree(fileName = system.file("testdata", "qcPed.txt",
                                                package = "nprcgenekeepr"),
                         sep = "\t")
           expect_equal(nrow(pedTxt), 280)
           })

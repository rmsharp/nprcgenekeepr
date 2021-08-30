#' Copyright(c) 2017-2020 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("saveDataframesAsFiles")
library(testthat)
dfList <- list(
  lacy1989Ped = nprcgenekeepr::lacy1989Ped,
  pedGood = nprcgenekeepr::pedGood
)

test_that("makeExamplePedigreeFile creates CSV files", {
  skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "msharp")
  files_csv <- saveDataframesAsFiles(dfList, baseDir = tempdir(),
                                     fileType = "csv")
  pedCsv_1 <- read.table(files_csv[1], sep = ",", header = TRUE,
                       stringsAsFactors = FALSE)
  expect_equal(names(pedCsv_1), names(nprcgenekeepr::lacy1989Ped))
  expect_equal(row.names.data.frame(pedCsv_1),
               row.names.data.frame(nprcgenekeepr::lacy1989Ped))
  pedCsv_2 <- read.table(files_csv[2], sep = ",", header = TRUE,
                         stringsAsFactors = FALSE)
  expect_equal(names(pedCsv_2), names(nprcgenekeepr::pedGood))
  expect_equal(row.names.data.frame(pedCsv_2),
               row.names.data.frame(nprcgenekeepr::pedGood))


})
test_that("makeExamplePedigreeFile creates TXT files", {
  skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "msharp")
  files_csv <- saveDataframesAsFiles(dfList, baseDir = tempdir(),
                                     fileType = "txt")
  pedCsv_1 <- read.table(files_csv[1], sep = "\t", header = TRUE,
                         stringsAsFactors = FALSE)
  expect_equal(names(pedCsv_1), names(nprcgenekeepr::lacy1989Ped))
  expect_equal(row.names.data.frame(pedCsv_1),
               row.names.data.frame(nprcgenekeepr::lacy1989Ped))
  pedCsv_2 <- read.table(files_csv[2], sep = "\t", header = TRUE,
                         stringsAsFactors = FALSE)
  expect_equal(names(pedCsv_2), names(nprcgenekeepr::pedGood))
  expect_equal(row.names.data.frame(pedCsv_2),
               row.names.data.frame(nprcgenekeepr::pedGood))
})
test_that("makeExamplePedigreeFile creates Excel files", {
  skip_if_not(Sys.info()[names(Sys.info()) == "user"] == "msharp")
  files_csv <- saveDataframesAsFiles(dfList, baseDir = tempdir(),
                                     fileType = "excel")
  pedCsv_1 <- suppressWarnings(getPedigree(files_csv[1]))

  expect_equal(names(pedCsv_1), names(nprcgenekeepr::lacy1989Ped))
  expect_equal(row.names.data.frame(pedCsv_1),
               row.names.data.frame(nprcgenekeepr::lacy1989Ped))

  pedCsv_2 <- suppressWarnings(getPedigree(files_csv[2]))
  expect_equal(names(pedCsv_2), names(nprcgenekeepr::pedGood))
  expect_equal(row.names.data.frame(pedCsv_2),
               row.names.data.frame(nprcgenekeepr::pedGood))
})
test_that("makeExamplePedigreeFile detects a non-dataframe object", {
  dfList <- list(
  lacy1989Ped = nprcgenekeepr::lacy1989Ped,
  pedGood = nprcgenekeepr::pedGood,
  charVector = c("not a data.frame"))
  expect_error(saveDataframesAsFiles(dfList, baseDir = tempdir(),
                                     fileType = "excel"),
               "dfList must be a list containing only dataframes")
})

## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#
# Regression tests for the Excel-upload sire/dam corruption bug (BACKLOG.md,
# discovered S347): R/modInput.R's readDataFile() called
# readxl::read_excel(file$datapath) with no col_types, so readxl's
# column-type guessing samples the early (blank-parent/founder) rows,
# defaults those columns to logical, and silently converts every later
# alphanumeric sire/dam ID it cannot parse as logical to NA -- with no
# warning surfaced to the app user. Confirmed on a round-trip of the shipped
# data(examplePedigree): 100% of non-blank sire values and >99% of dam
# values became NA. The CSV/text-file paths are unaffected (read.csv/
# read.table scan the whole column, not a sample).

testthat::skip_on_cran()

test_that("readDataFile preserves alphanumeric sire/dam IDs from Excel uploads", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("readxl")

  excelFile <- tempfile(fileext = ".xlsx")
  on.exit(unlink(excelFile))
  makeExamplePedigreeFile(excelFile, fileType = "excel")

  shiny::testServer(modInputServer, args = list(config = NULL), {
    excel <- readDataFile(
      list(name = "examplePedigree.xlsx", datapath = excelFile),
      "fileTypeExcel", ","
    )
    expect_true(is.data.frame(excel))
    expect_equal(
      sum(!is.na(excel$sire)),
      sum(!is.na(nprcgenekeepr::examplePedigree$sire))
    )
    expect_equal(
      sum(!is.na(excel$dam)),
      sum(!is.na(nprcgenekeepr::examplePedigree$dam))
    )
    expect_true(is.character(excel$sire))
    expect_true(is.character(excel$dam))
  })
})

test_that("modInputServer processing an Excel upload does not collapse the pedigree to founders", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("readxl")

  excelFile <- tempfile(fileext = ".xlsx")
  on.exit(unlink(excelFile))
  makeExamplePedigreeFile(excelFile, fileType = "excel")

  shiny::testServer(modInputServer, args = list(config = NULL), {
    session$setInputs(
      fileContent = "pedFile", fileType = "fileTypeExcel",
      minSireAge = "2.0", minDamAge = "2.0"
    )
    session$setInputs(pedigreeFileOne = list(
      name = basename(excelFile), datapath = excelFile
    ))
    session$setInputs(getData = 1)

    cleaned <- session$getReturned()$cleanedStudbook()
    expect_true(is.data.frame(cleaned))
    # Before the fix every sire/dam becomes NA at read time, so the real
    # example pedigree's thousands of non-founder rows collapse to a
    # near-empty handful after qcStudbook.
    expect_gt(sum(!is.na(cleaned$sire)), 1000L)
  })
})

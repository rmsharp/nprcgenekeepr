## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#
# The placeholder mark through the app (placeholder-marking plan Slice 2,
# S808). A center can mark a real animal whose id looks like a made-up
# stand-in (U1234) as FALSE in a `placeholder` column; the upload's quality
# check keeps that mark, marks the stand-ins it makes as TRUE, and the
# Potential Parents tab then treats U1234 as the real sire it is. A value the
# column does not accept stops the check with the rows listed.
library(testthat)
testthat::skip_on_cran()

## Writes `lines` to a temporary CSV file and uploads it through the real
## Input module (read, then runQcStudbook()), returning the module's
## qcResults().
uploadPlaceholderLines <- function(lines) {
  path <- tempfile(fileext = ".csv")
  writeLines(lines, path)
  got <- new.env()
  shiny::testServer(modInputServer, {
    session$setInputs(fileContent = "pedFile", fileType = "fileTypeExcel",
                      separator = ",", minSireAge = "", minDamAge = "")
    session$setInputs(pedigreeFileOne = list(name = basename(path),
                                             datapath = path))
    session$setInputs(getData = 1L)
    got$res <- qcResults()
  })
  got$res
}
valueOf <- function(ped, id, col) ped[[col]][ped$id == id]

## U1234 is a real sire marked FALSE; K2 has no recorded sire, so the check
## makes a stand-in (U0001) for it.
markedLines <- c(
  "id,sire,dam,sex,birth,fromCenter,placeholder",
  "S1,,,M,2000-01-01,TRUE,",
  "U1234,,,M,2000-01-01,TRUE,FALSE",
  "D1,,,F,2000-01-01,TRUE,",
  "D2,,,F,2000-01-01,TRUE,",
  "K1,U1234,D1,F,2008-01-01,TRUE,",
  "K2,,D2,M,2010-01-01,TRUE,"
)

test_that("an uploaded U1234 marked FALSE stays a real sire through Potential Parents", {
  skip_if_not_installed("shiny")
  res <- uploadPlaceholderLines(markedLines)
  expect_identical(nrow(res$errors), 0L)
  cleaned <- res$cleaned
  expect_false(valueOf(cleaned, "U1234", "placeholder"))
  madeSire <- valueOf(cleaned, "K2", "sire")
  expect_true(valueOf(cleaned, madeSire, "placeholder"))

  shiny::testServer(
    modPotentialParentsServer,
    args = list(pedigree = shiny::reactive(cleaned),
                minSireAge = 2, minDamAge = 2),
    {
      session$setInputs(maxGestationalPeriod = 210, findParents = 1)
      td <- session$getReturned()$tableData()
      expect_false("K1" %in% td$id) # both parents on record
      expect_true("K2" %in% td$id)
      expect_true(grepl("U1234", td$sires[td$id == "K2"], fixed = TRUE))
    }
  )
})

test_that("an uploaded placeholder value other than TRUE, FALSE, 1, 0 or blank is a QC error naming its rows", {
  skip_if_not_installed("shiny")
  res <- uploadPlaceholderLines(c(
    "id,sire,dam,sex,birth,placeholder",
    "S1,,,M,2000-01-01,yes",
    "D1,,,F,2000-01-01,",
    "K1,S1,D1,F,2008-01-01,2"
  ))
  expect_true("Invalid placeholder values" %in% res$errors$Error)
  details <- res$errors$Details[res$errors$Error == "Invalid placeholder values"]
  expect_true(grepl("1, 3", details, fixed = TRUE))
})

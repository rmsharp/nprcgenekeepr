## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#
# Blank cells in CSV and text uploads (BACKLOG.md, found S776, extended S799;
# fixed S800). The Input module's readDataFile() read uploads with no
# na.strings, so an empty cell arrived as "" while getPedigree() and Excel
# uploads read it as missing. Consequences on the upload path only: a blank
# sire/dam cell became the id "" ("appears as both a sire and a dam", so the
# upload did not load), a blank ancestry became OTHER instead of UNKNOWN, and a
# blank origin counted as a recorded origin, so a founder with no recorded
# origin was ranked as an import instead of "Undetermined". The upload now
# reads an empty cell as missing, the same as the script path.
library(testthat)
testthat::skip_on_cran()

## Writes `lines` to a temporary file and uploads it through the real Input
## module (read, then runQcStudbook()), returning the module's qcResults().
uploadPedigree <- function(lines, fileExt = "csv", fileType = "fileTypeExcel",
                           separator = ",") {
  path <- tempfile(fileext = paste0(".", fileExt))
  writeLines(lines, path)
  uploadPedigreeFile(path, fileType = fileType, separator = separator)
}
uploadPedigreeFile <- function(path, fileType = "fileTypeExcel",
                               separator = ",", minDamAge = "",
                               minSireAge = "") {
  got <- new.env()
  shiny::testServer(modInputServer, {
    session$setInputs(fileContent = "pedFile", fileType = fileType,
                      separator = separator, minSireAge = minSireAge,
                      minDamAge = minDamAge)
    session$setInputs(pedigreeFileOne = list(name = basename(path),
                                             datapath = path))
    session$setInputs(getData = 1L)
    got$res <- qcResults()
  })
  got$res
}
## as.character(): the cleaned ancestry column is a factor.
valueOf <- function(ped, id, col) as.character(ped[[col]][ped$id == id])

## Founders with blank sire and dam cells, as the app's Input Format help asks
## ("If an animal is missing information on one parent, that cell should be
## blank").
blankParentLines <- c(
  "id,sire,dam,sex,birth",
  "S1,,,M,2000-01-01",
  "D1,,,F,2000-01-01",
  "K1,S1,D1,F,2006-01-01",
  "K2,S1,,M,2007-01-01"
)
## Parents written as NA (which the upload already read as missing) so the
## file loads either way, with blank ancestry, origin and status cells. O1's
## ancestry is unrecognized text, not blank.
blankFieldLines <- c(
  "id,sire,dam,sex,birth,ancestry,origin,status",
  "S1,NA,NA,M,2000-01-01,india,,ALIVE",
  "D1,NA,NA,F,2000-01-01,,Zoo,",
  "O1,NA,NA,M,2000-01-01,mauritius,,ALIVE",
  "K1,S1,D1,F,2006-01-01,india,,ALIVE",
  "K2,S1,D1,M,2007-01-01,,,ALIVE"
)

## --- readDataFile(): the raw read ------------------------------------------

test_that("readDataFile reads a blank CSV cell as missing, not \"\"", {
  skip_if_not_installed("shiny")
  path <- tempfile(fileext = ".csv")
  writeLines(blankFieldLines, path)
  shiny::testServer(modInputServer, {
    raw <- readDataFile(list(name = "ped.csv", datapath = path),
                        "fileTypeExcel", ",")
    expect_true(is.na(valueOf(raw, "D1", "ancestry")))
    expect_true(is.na(valueOf(raw, "S1", "origin")))
    expect_true(is.na(valueOf(raw, "D1", "status")))
    expect_false(any(vapply(raw, function(x) any(x %in% ""), logical(1L))))
  })
})
test_that("readDataFile reads a blank tab-separated text cell as missing", {
  skip_if_not_installed("shiny")
  path <- tempfile(fileext = ".txt")
  writeLines(gsub(",", "\t", blankFieldLines, fixed = TRUE), path)
  shiny::testServer(modInputServer, {
    raw <- readDataFile(list(name = "ped.txt", datapath = path),
                        "fileTypeText", "\t")
    expect_true(is.na(valueOf(raw, "D1", "ancestry")))
    expect_true(is.na(valueOf(raw, "S1", "origin")))
    expect_true(is.na(valueOf(raw, "D1", "status")))
    expect_false(any(vapply(raw, function(x) any(x %in% ""), logical(1L))))
  })
})
test_that("control: readDataFile still reads a literal NA as missing", {
  skip_if_not_installed("shiny")
  path <- tempfile(fileext = ".csv")
  writeLines(blankFieldLines, path)
  shiny::testServer(modInputServer, {
    raw <- readDataFile(list(name = "ped.csv", datapath = path),
                        "fileTypeExcel", ",")
    expect_true(is.na(valueOf(raw, "S1", "sire")))
    expect_true(is.na(valueOf(raw, "S1", "dam")))
  })
})

## --- A whole upload through the Input module --------------------------------

test_that("a CSV upload whose founders have blank parent cells loads", {
  skip_if_not_installed("shiny")
  res <- uploadPedigree(blankParentLines)
  expect_false("Animal is both sire and dam" %in% res$errors$Error)
  expect_identical(nrow(res$errors), 0L)
  expect_false(is.null(res$cleaned))
  expect_false("" %in% res$cleaned$id)
  expect_true(is.na(valueOf(res$cleaned, "S1", "sire")))
  expect_true(is.na(valueOf(res$cleaned, "D1", "dam")))
  expect_identical(valueOf(res$cleaned, "K1", "sire"), "S1")
})
test_that("a tab-separated text upload whose founders have blank parent cells loads", {
  skip_if_not_installed("shiny")
  res <- uploadPedigree(gsub(",", "\t", blankParentLines, fixed = TRUE),
                        fileExt = "txt", fileType = "fileTypeText",
                        separator = "\t")
  expect_identical(nrow(res$errors), 0L)
  expect_false(is.null(res$cleaned))
  expect_false("" %in% res$cleaned$id)
})
test_that("a blank ancestry cell in an upload becomes UNKNOWN, not OTHER", {
  skip_if_not_installed("shiny")
  res <- uploadPedigree(blankFieldLines)
  expect_identical(valueOf(res$cleaned, "D1", "ancestry"), "UNKNOWN")
  expect_identical(valueOf(res$cleaned, "K2", "ancestry"), "UNKNOWN")
})
test_that("control: unrecognized ancestry text in an upload is still OTHER", {
  skip_if_not_installed("shiny")
  res <- uploadPedigree(blankFieldLines)
  expect_identical(valueOf(res$cleaned, "O1", "ancestry"), "OTHER")
  expect_identical(valueOf(res$cleaned, "S1", "ancestry"), "INDIAN")
})
test_that("a blank origin cell in an upload is no recorded origin", {
  skip_if_not_installed("shiny")
  res <- uploadPedigree(blankFieldLines)
  expect_true(is.na(valueOf(res$cleaned, "S1", "origin")))
  expect_identical(valueOf(res$cleaned, "D1", "origin"), "Zoo")
})
test_that("a founder uploaded with a blank origin is Undetermined, not an import", {
  skip_if_not_installed("shiny")
  res <- uploadPedigree(blankFieldLines)
  set.seed(1L)
  rpt <- suppressWarnings(reportGV(res$cleaned, guIter = 10L))
  ordered <- orderReport(rpt$report, res$cleaned)
  expect_identical(valueOf(ordered, "S1", "value"), "Undetermined")
  expect_identical(valueOf(ordered, "O1", "value"), "Undetermined")
  expect_false(valueOf(ordered, "D1", "value") == "Undetermined") # origin Zoo
})

## --- The shipped example files ----------------------------------------------

test_that("the shipped ancestry example uploads with U1 as UNKNOWN", {
  skip_if_not_installed("shiny")
  path <- system.file("extdata", "examples", "example_ancestry_pedigree.csv",
                      package = "nprcgenekeepr")
  skip_if(path == "")
  res <- uploadPedigreeFile(path)
  expect_identical(valueOf(res$cleaned, "U1", "ancestry"), "UNKNOWN")
  expect_identical(sum(res$cleaned$ancestry == "OTHER"), 1L) # O1 (mauritius)
  expect_identical(sum(res$cleaned$ancestry == "UNKNOWN"), 1L)
})
## jmacExamplePath() is in helper-jmacExample.R.
##
## RED (S981; BACKLOG.md:179, the owner's S980 request "reconstruct in the next
## session"; Pre-RED rulings: replace the old file, keep the species column):
## the shipped Japanese macaque example is now the 2018-07-11 studbook,
## de-identified with obfuscatePed() (dev/buildJmacExample.R, seed 20180711):
## 2,590 animals, 819 of them with a sire. The numbers below were measured on a
## scratch build through this module; the studbook itself is neither in git nor
## in the package. The species column (JAPANESE MACAQUE) brings the built-in
## floors: 4 years for a mother and 5 for a father. 62 mothers and 18 fathers
## are under them, 79 rows in the Errors table, so the file loads only once both
## Minimum Dam Age and Minimum Sire Age are lowered (test_jmacExampleWording.R
## pins the guide, manual and NEWS sentences).
test_that("the shipped jmac example no longer reports the id \"\" as both a sire and a dam", {
  skip_if_not_installed("shiny")
  path <- jmacExamplePath()
  skip_if(path == "")
  res <- uploadPedigreeFile(path)
  expect_false("Animal is both sire and dam" %in% res$errors$Error)
  expect_identical(unique(res$errors$Error), "Parent age too young")
  expect_identical(nrow(res$errors), 79L)
  expect_null(res$cleaned)
})
## Each box alone is not enough: Minimum Dam Age 3.3 leaves the 18 fathers
## under 5 years, Minimum Sire Age 4.3 leaves the 62 mothers under 4.
test_that("the shipped jmac example needs both Minimum Dam Age and Minimum Sire Age lowered", {
  skip_if_not_installed("shiny")
  path <- jmacExamplePath()
  skip_if(path == "")
  damOnly <- uploadPedigreeFile(path, minDamAge = "3.3")
  expect_identical(nrow(damOnly$errors), 18L)
  expect_null(damOnly$cleaned)
  sireOnly <- uploadPedigreeFile(path, minSireAge = "4.3")
  expect_identical(nrow(sireOnly$errors), 62L)
  expect_null(sireOnly$cleaned)
})
## Minimum Dam Age 3.3 and Minimum Sire Age 4.3 are the largest round values
## under the youngest mother (3.38) and father (4.36), so the file loads whole:
## nothing is dropped and the check adds a placeholder row for each unknown
## parent (the cleaned table holds 4,055 rows, 2,592 of them real animals: the
## file's 2,590 and the 2 mothers it names but gives no row). The guide, the
## manual and NEWS name these settings (test_jmacExampleWording.R).
test_that("the shipped jmac example loads once Minimum Dam Age is 3.3 and Minimum Sire Age is 4.3", {
  skip_if_not_installed("shiny")
  path <- jmacExamplePath()
  skip_if(path == "")
  res <- uploadPedigreeFile(path, minDamAge = "3.3", minSireAge = "4.3")
  expect_identical(nrow(res$errors), 0L)
  expect_false(is.null(res$cleaned))
  expect_identical(nrow(res$cleaned), 4055L)
  expect_identical(sum(!(res$cleaned$placeholder %in% TRUE)), 2592L)
})
## The boundaries: 3.4 is above the youngest mother (3.38) and 4.4 above the
## youngest father (4.36), so one row is still flagged and the file does not
## load. This is what keeps "3.3 or lower" and "4.3 or lower" in the wording
## from being loose numbers.
test_that("Minimum Dam Age 3.4 and Minimum Sire Age 4.4 each still flag one row", {
  skip_if_not_installed("shiny")
  path <- jmacExamplePath()
  skip_if(path == "")
  damTooHigh <- uploadPedigreeFile(path, minDamAge = "3.4", minSireAge = "4.3")
  expect_identical(unique(damTooHigh$errors$Error), "Parent age too young")
  expect_identical(nrow(damTooHigh$errors), 1L)
  expect_null(damTooHigh$cleaned)
  sireTooHigh <- uploadPedigreeFile(path, minDamAge = "3.3", minSireAge = "4.4")
  expect_identical(unique(sireTooHigh$errors$Error), "Parent age too young")
  expect_identical(nrow(sireTooHigh$errors), 1L)
  expect_null(sireTooHigh$cleaned)
})

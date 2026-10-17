## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# BACKLOG.md:166 (ruled S1004): a fromCenter value that is not a whole yes or
# no stops the load and names its row, through qcStudbook() and through the
# Input tab, instead of being read as TRUE or FALSE with no message.

# pedGood with the text a colony manager's file would hold in fromCenter (the
# shipped examplePedigree already holds TRUE and FALSE, which skips the
# conversion). Row 3 carries the value under test.
fromCenterPed <- function(value) {
  ped <- nprcgenekeepr::pedGood
  ped$fromCenter <- "Yes"
  ped$fromCenter[3L] <- value
  ped
}

# The Input tab's result after "Get Data" on a CSV holding `ped`.
inputTabResult <- function(ped) {
  path <- tempfile(fileext = ".csv")
  on.exit(unlink(path), add = TRUE)
  utils::write.csv(ped, path, row.names = FALSE)
  result <- NULL
  frame <- environment()
  shiny::testServer(modInputServer, {
    session$setInputs(
      fileContent = "pedFile", fileType = "fileTypeExcel",
      minSireAge = "2.0", minDamAge = "2.0"
    )
    session$setInputs(pedigreeFileOne = list(
      name = basename(path), datapath = path
    ))
    session$setInputs(getData = 1)
    assign("result", storedResults(), envir = frame)
  })
  result
}

test_that("qcStudbook() stops on a fromCenter value that is not yes or no", {
  for (reportErrors in c(FALSE, TRUE)) {
    expect_error(
      suppressWarnings(
        qcStudbook(fromCenterPed("unknown"), reportErrors = reportErrors)
      ),
      "fromCenter field has ambiguous values in row\\(s\\) 3$",
      info = paste("reportErrors =", reportErrors)
    )
  }
})

test_that("qcStudbook() still reads a padded yes as TRUE", {
  ped <- fromCenterPed(" Yes ")
  cleaned <- suppressWarnings(qcStudbook(ped, reportErrors = FALSE))
  expect_type(cleaned$fromCenter, "logical")
  expect_false(anyNA(cleaned$fromCenter))
  expect_true(all(cleaned$fromCenter))
})

test_that("qcStudbook() reports the row position of a value that stops", {
  # "&" stops before and after the fix, so this proves row 3 of the file is
  # the row the message names.
  expect_error(
    suppressWarnings(qcStudbook(fromCenterPed("&"), reportErrors = FALSE)),
    "fromCenter field has ambiguous values in row\\(s\\) 3$"
  )
})

test_that("the Input tab stops on a fromCenter value that is not yes or no", {
  skip_if_not_installed("shiny")
  res <- inputTabResult(fromCenterPed("unknown"))
  expect_null(res$cleaned)
  expect_identical(res$errors$Error, "Data Processing Error")
  expect_identical(
    res$errors$Details,
    "fromCenter field has ambiguous values in row(s) 3"
  )
})

test_that("the Input tab still loads a padded lower-case no", {
  skip_if_not_installed("shiny")
  res <- inputTabResult(fromCenterPed(" no "))
  expect_false(is.null(res$cleaned))
  expect_identical(nrow(res$errors), 0L)
  expect_type(res$cleaned$fromCenter, "logical")
})

## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#
# The Pedigree Browser and the exports read and keep the placeholder mark
# (placeholder-marking plan Slice 4, S810). A center can mark a real animal
# whose id looks like a made-up stand-in (U1234) as FALSE in the `placeholder`
# column that qcStudbook() writes. Until now the "Display Unknown IDs" box
# hid every row whose id looked like a stand-in, so unticking it hid a real
# U1234 and left its offspring naming a parent that was no longer in the
# table. The box now asks isGeneratedUnknownId(ped =): a row with a mark is
# hidden by its mark, a row with no mark by its id shape. The Pedigree Browser
# export and the cleaned-studbook export carry the column, and reading either
# file back through qcStudbook() gives the same marks (plan D8).
library(testthat)

## U1234 is a real sire marked FALSE; U0001 is a made-up stand-in marked TRUE;
## Xq9 is a stand-in whose id does not look like one, marked TRUE; U0002 is an
## unmarked (NA) row that looks like a stand-in and is read by its shape.
makeDisplayPed <- function() {
  data.frame(
    id = c("U1234", "U0001", "Xq9", "U0002", "D1", "K1", "K2", "K3"),
    sire = c(NA, NA, NA, NA, NA, "U1234", "U0001", "Xq9"),
    dam = c(NA, NA, NA, NA, NA, "D1", "D1", "D1"),
    sex = c("M", "M", "M", "M", "F", "F", "M", "F"),
    birth = as.Date("2000-01-01") + c(0, 0, 0, 0, 0, 900, 950, 1000),
    placeholder = c(FALSE, TRUE, TRUE, NA, FALSE, FALSE, FALSE, FALSE),
    stringsAsFactors = FALSE
  )
}

shownIds <- function(ped, displayUnknownIds) {
  got <- new.env()
  shiny::testServer(
    modPedigreeServer,
    args = list(studbook = shiny::reactive(ped)),
    {
      session$setInputs(displayUnknownIds = displayUnknownIds,
                        trimPedigree = FALSE)
      got$ids <- session$getReturned()$pedigree()$id
    }
  )
  got$ids
}

## --- the "Display Unknown IDs" filter ----------------------------------------

test_that("unticking Display Unknown IDs keeps a real U1234 marked FALSE", {
  skip_if_not_installed("shiny")
  ids <- shownIds(makeDisplayPed(), displayUnknownIds = FALSE)
  expect_true("U1234" %in% ids)
})

test_that("unticking Display Unknown IDs hides a stand-in marked TRUE whatever its id looks like", {
  skip_if_not_installed("shiny")
  ids <- shownIds(makeDisplayPed(), displayUnknownIds = FALSE)
  expect_false(any(c("U0001", "Xq9") %in% ids))
})

test_that("unticking Display Unknown IDs reads an unmarked row by its id shape", {
  skip_if_not_installed("shiny")
  ids <- shownIds(makeDisplayPed(), displayUnknownIds = FALSE)
  expect_false("U0002" %in% ids)
  expect_true(all(c("D1", "K1", "K2", "K3") %in% ids))
})

test_that("unticking Display Unknown IDs keeps exactly the rows that are not marked stand-ins", {
  skip_if_not_installed("shiny")
  ids <- shownIds(makeDisplayPed(), displayUnknownIds = FALSE)
  expect_setequal(ids, c("U1234", "D1", "K1", "K2", "K3"))
})

test_that("with Display Unknown IDs ticked every row is shown, marks or not (guard)", {
  skip_if_not_installed("shiny")
  ped <- makeDisplayPed()
  expect_setequal(shownIds(ped, displayUnknownIds = TRUE), ped$id)
})

test_that("a pedigree with no placeholder column is still filtered by id shape (guard)", {
  skip_if_not_installed("shiny")
  ped <- makeDisplayPed()
  ped$placeholder <- NULL
  ids <- shownIds(ped, displayUnknownIds = FALSE)
  ## by shape U1234, U0001 and U0002 all look like stand-ins; Xq9 does not
  expect_setequal(ids, c("Xq9", "D1", "K1", "K2", "K3"))
})

## --- the display name --------------------------------------------------------

test_that("headerDisplayNames() names the placeholder column in plain words", {
  expect_identical(headerDisplayNames("placeholder"), "Generated Unknown ID")
  expect_identical(
    headerDisplayNames(c("id", "recordStatus", "placeholder")),
    c("Ego ID", "Original/ Added", "Generated Unknown ID")
  )
})

## --- the help text -----------------------------------------------------------

test_that("the Display Unknown IDs help text says the mark decides, and that a real animal can be marked", {
  skip_if_not_installed("shiny")
  html <- as.character(modPedigreeUI("pedNS"))
  ## "placeholder" alone would match the focal-animal text box's HTML
  ## placeholder attribute, so the test asks for the column by name
  expect_true(grepl("placeholder column", html, fixed = TRUE))
  expect_true(grepl("FALSE", html, fixed = TRUE))
})

## --- the exports keep the mark (plan D8) ---------------------------------------

## A center's file: U1234 is a real sire (FALSE), K2 has no recorded sire so
## the quality check makes a stand-in for it.
makeCenterPed <- function() {
  data.frame(
    id = c("S1", "U1234", "D1", "D2", "K1", "K2"),
    sire = c(NA, NA, NA, NA, "U1234", NA),
    dam = c(NA, NA, NA, NA, "D1", "D2"),
    sex = c("M", "M", "F", "F", "F", "M"),
    birth = as.Date(c("2000-01-01", "2000-01-01", "2000-01-01", "2000-01-01",
                      "2008-01-01", "2010-01-01")),
    placeholder = c(NA, FALSE, NA, NA, NA, NA),
    stringsAsFactors = FALSE
  )
}

test_that("the Pedigree Browser export carries the placeholder column and re-checks to the same marks", {
  skip_if_not_installed("shiny")
  qc <- qcStudbook(makeCenterPed(), minSireAge = 2, minDamAge = 2)
  got <- new.env()
  shiny::testServer(
    modPedigreeServer,
    args = list(studbook = shiny::reactive(qc)),
    {
      session$setInputs(displayUnknownIds = TRUE, trimPedigree = FALSE)
      got$df <- utils::read.csv(output$exportPedigree,
                                stringsAsFactors = FALSE)
    }
  )
  expect_true("placeholder" %in% names(got$df))
  expect_identical(got$df$placeholder[match("U1234", got$df$id)], FALSE)
  again <- qcStudbook(got$df, minSireAge = 2, minDamAge = 2)
  expect_identical(again$placeholder[match(qc$id, again$id)], qc$placeholder)
})

test_that("the cleaned-studbook export carries the placeholder column and re-checks to the same marks", {
  skip_if_not_installed("shiny")
  path <- tempfile(fileext = ".csv")
  utils::write.csv(makeCenterPed(), path, row.names = FALSE)
  got <- new.env()
  shiny::testServer(modInputServer, {
    session$setInputs(fileContent = "pedFile", fileType = "fileTypeExcel",
                      separator = ",", minSireAge = "", minDamAge = "")
    session$setInputs(pedigreeFileOne = list(name = basename(path),
                                             datapath = path))
    session$setInputs(getData = 1L)
    got$cleaned <- qcResults()$cleaned
    got$df <- utils::read.csv(output$downloadCleaned, stringsAsFactors = FALSE)
  })
  expect_true("placeholder" %in% names(got$df))
  expect_identical(got$df$placeholder[match("U1234", got$df$id)], FALSE)
  again <- qcStudbook(got$df)
  expect_identical(again$placeholder[match(got$cleaned$id, again$id)],
                   got$cleaned$placeholder)
})

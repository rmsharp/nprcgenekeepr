## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

library(testthat)
library(nprcgenekeepr)

## Tests for getNoBirthDateWarning() (S933): the one row the Input tab's
## Warnings list gets when animals in the uploaded pedigree have no birth date
## (BACKLOG.md, owner ruled S932). The function reads the cleaned pedigree that
## runQcStudbook() holds after its second pass and returns a data frame in the
## shape of the QC warnings table (Row, Warning, Details): one row, or none.
## Every animal with no birth date counts, whatever its sex, status or exit
## date.

## The sentence both the app and these tests spell out.
afterCount <- paste0(
  " no birth date, so their age is unknown. Age-based checks and counts ",
  "(the parent-age check, the Age-Sex Pyramid, breeding-age counts) cannot ",
  "use them."
)

makeBirthPed <- function(birth, sex = rep("F", length(birth))) {
  data.frame(
    id = paste0("A", seq_along(birth)),
    sire = NA_character_,
    dam = NA_character_,
    sex = sex,
    birth = as.Date(birth),
    stringsAsFactors = FALSE
  )
}

test_that("getNoBirthDateWarning returns one row shaped like a QC warning", {
  ped <- makeBirthPed(c("2001-01-01", NA, "2003-03-03", NA, "2005-05-05"))
  res <- getNoBirthDateWarning(ped)
  expect_s3_class(res, "data.frame")
  expect_named(res, c("Row", "Warning", "Details"))
  expect_identical(nrow(res), 1L)
  expect_type(res$Row, "integer")
  expect_true(is.na(res$Row))
  expect_identical(res$Warning, "Animals with no birth date")
  expect_identical(
    res$Details,
    paste0("2 of 5 animals have", afterCount)
  )
})

test_that("getNoBirthDateWarning says 'has' when exactly one animal lacks one", {
  ped <- makeBirthPed(c("2001-01-01", NA, "2003-03-03", "2004-04-04",
                        "2005-05-05"))
  res <- getNoBirthDateWarning(ped)
  expect_identical(nrow(res), 1L)
  expect_identical(res$Details, paste0("1 of 5 animals has", afterCount))
})

test_that("getNoBirthDateWarning counts every animal, whatever its sex or status", {
  ped <- data.frame(
    id = c("L1", "M1", "U1", "K1", "K2", "K3"),
    sex = c("F", "M", "U", "F", "M", "F"),
    status = c("ALIVE", "DEAD", "ALIVE", "ALIVE", "SHIPPED", "ALIVE"),
    exit = as.Date(c(NA, "2020-05-01", NA, NA, "2019-01-01", NA)),
    birth = as.Date(c(NA, NA, NA, NA, "2001-01-01", "2002-02-02")),
    stringsAsFactors = FALSE
  )
  res <- getNoBirthDateWarning(ped)
  ## A living female, a male with an exit date, an animal of unknown sex and
  ## another female all lack a birth date; the two with one do not count.
  expect_identical(res$Details, paste0("4 of 6 animals have", afterCount))
})

test_that("getNoBirthDateWarning counts every animal when none has a birth date", {
  ped <- makeBirthPed(c(NA, NA, NA))
  res <- getNoBirthDateWarning(ped)
  expect_identical(res$Details, paste0("3 of 3 animals have", afterCount))
})

test_that("getNoBirthDateWarning writes the counts as plain numbers", {
  ped <- makeBirthPed(c(rep(NA, 1200L), rep("2010-01-01", 300L)))
  res <- getNoBirthDateWarning(ped)
  expect_identical(res$Details, paste0("1200 of 1500 animals have", afterCount))
})

test_that("getNoBirthDateWarning returns no row when every animal has a birth date", {
  res <- getNoBirthDateWarning(makeBirthPed(c("2001-01-01", "2002-02-02")))
  expect_s3_class(res, "data.frame")
  expect_named(res, c("Row", "Warning", "Details"))
  expect_identical(nrow(res), 0L)
  expect_type(res$Row, "integer")
  expect_type(res$Warning, "character")
  expect_type(res$Details, "character")
})

test_that("getNoBirthDateWarning returns no row for a pedigree with no animals", {
  res <- getNoBirthDateWarning(makeBirthPed(character(0L)))
  expect_named(res, c("Row", "Warning", "Details"))
  expect_identical(nrow(res), 0L)
})

test_that("getNoBirthDateWarning returns no row, without failing, if there is no birth column", {
  ## A missing birth column is already an error ("Missing required columns"),
  ## so a pedigree without one never reaches this function from the app.
  res <- getNoBirthDateWarning(data.frame(id = c("A", "B"),
                                          stringsAsFactors = FALSE))
  expect_named(res, c("Row", "Warning", "Details"))
  expect_identical(nrow(res), 0L)
})

## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

library(testthat)
library(nprcgenekeepr)

## RED (S982; BACKLOG.md:156): tests for getExitBeforeBirthWarning(), the one
## row the Input tab's Warnings list gets when animals in the uploaded pedigree
## have an exit date (a death or a departure) earlier than their birth date.
## The owner ruled at Pre-RED: a warning, not an error (the file still loads);
## strictly earlier only (a same-day exit is not flagged); read the cleaned
## `exit` column, which holds the earlier of death and departure or the file's
## own exit column. The function reads the cleaned pedigree that runQcStudbook()
## holds after its second pass and returns a data frame in the shape of the QC
## warnings table (Row, Warning, Details): one row, or none. It is modelled on
## getNoBirthDateWarning() (test_getNoBirthDateWarning.R).

warningLabel <- "Animals with a death or departure before birth"

## Animals A1.. born on the given dates and leaving on the given dates.
makeExitPed <- function(birth, exit, id = sprintf("A%d", seq_along(birth))) {
  data.frame(
    id = id,
    sire = rep(NA_character_, length(birth)),
    dam = rep(NA_character_, length(birth)),
    sex = rep("F", length(birth)),
    birth = as.Date(birth),
    exit = as.Date(exit),
    stringsAsFactors = FALSE
  )
}

test_that("getExitBeforeBirthWarning returns one row shaped like a QC warning", {
  ped <- makeExitPed(
    birth = c("2001-01-01", "2002-02-02", "2003-03-03", "2004-04-04",
              "2005-05-05"),
    exit = c("2000-12-01", NA, "2003-03-03", "2004-01-01", "2006-06-06")
  )
  res <- getExitBeforeBirthWarning(ped)
  expect_s3_class(res, "data.frame")
  expect_named(res, c("Row", "Warning", "Details"))
  expect_identical(nrow(res), 1L)
  expect_type(res$Row, "integer")
  expect_true(is.na(res$Row))
  expect_identical(res$Warning, warningLabel)
  expect_identical(
    res$Details,
    paste0("2 of 5 animals have an exit date earlier than their birth date ",
           "(A1, A4). Their age comes out zero or negative. Check those ",
           "dates in your file.")
  )
})

test_that("getExitBeforeBirthWarning says 'has' and 'its' for exactly one animal", {
  ped <- makeExitPed(
    birth = c("2001-01-01", "2002-02-02", "2003-03-03"),
    exit = c("2002-01-01", "2002-01-01", "2004-03-03")
  )
  res <- getExitBeforeBirthWarning(ped)
  expect_identical(nrow(res), 1L)
  expect_identical(
    res$Details,
    paste0("1 of 3 animals has an exit date earlier than its birth date ",
           "(A2). Its age comes out zero or negative. Check that date in ",
           "your file.")
  )
})

test_that("getExitBeforeBirthWarning flags an exit one day before the birth date", {
  res <- getExitBeforeBirthWarning(
    makeExitPed(birth = "2001-01-02", exit = "2001-01-01")
  )
  expect_identical(nrow(res), 1L)
  expect_match(res$Details, "^1 of 1 animals has an exit date earlier than")
})

test_that("getExitBeforeBirthWarning does not flag an exit on the birth day", {
  ## A stillbirth or a death on the day of birth is plausible: the owner ruled
  ## strictly earlier only (226 of ExamplePedigree.csv's 1930 dated animals and
  ## 370 of the Japanese macaque example's 1839 exit on the birth day).
  res <- getExitBeforeBirthWarning(
    makeExitPed(birth = c("2001-01-01", "2002-02-02"),
                exit = c("2001-01-01", "2002-02-02"))
  )
  expect_identical(nrow(res), 0L)
  ## Beside one real early exit, only the early one counts.
  mixed <- getExitBeforeBirthWarning(
    makeExitPed(birth = c("2001-01-01", "2002-02-02", "2003-03-03"),
                exit = c("2001-01-01", "2002-01-01", "2003-03-03"))
  )
  expect_match(mixed$Details, "^1 of 3 animals has an exit date earlier")
  expect_match(mixed$Details, "(A2)", fixed = TRUE)
})

test_that("getExitBeforeBirthWarning leaves out animals missing either date but counts them in the total", {
  ped <- makeExitPed(
    birth = c("2001-01-01", NA, "2003-03-03", NA, "2005-05-05"),
    exit = c("2000-01-01", "1999-01-01", NA, NA, "2005-05-06")
  )
  res <- getExitBeforeBirthWarning(ped)
  ## Only A1 has both dates with the exit first; A2 has no birth date, A3 and
  ## A4 have no exit date (alive, or not recorded), A5 leaves after its birth.
  expect_identical(
    res$Details,
    paste0("1 of 5 animals has an exit date earlier than its birth date ",
           "(A1). Its age comes out zero or negative. Check that date in ",
           "your file.")
  )
})

test_that("getExitBeforeBirthWarning names the first five, in table order, when more are found", {
  ids <- c("K7", "B2", "M9", "A1", "Z3", "C4", "D5", "OK1", "OK2")
  early <- c(TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE)
  ped <- makeExitPed(
    birth = rep("2010-01-01", length(ids)),
    exit = ifelse(early, "2009-01-01", "2011-01-01"),
    id = ids
  )
  res <- getExitBeforeBirthWarning(ped)
  expect_identical(
    res$Details,
    paste0("7 of 9 animals have an exit date earlier than their birth date ",
           "(first 5: K7, B2, M9, A1, Z3). Their age comes out zero or ",
           "negative. Check those dates in your file.")
  )
})

test_that("getExitBeforeBirthWarning names all five when there are exactly five", {
  ped <- makeExitPed(
    birth = rep("2010-01-01", 6L),
    exit = c(rep("2009-01-01", 5L), "2011-01-01")
  )
  res <- getExitBeforeBirthWarning(ped)
  expect_identical(
    res$Details,
    paste0("5 of 6 animals have an exit date earlier than their birth date ",
           "(A1, A2, A3, A4, A5). Their age comes out zero or negative. ",
           "Check those dates in your file.")
  )
})

test_that("getExitBeforeBirthWarning says 'first 5' from the sixth animal on", {
  ped <- makeExitPed(
    birth = rep("2010-01-01", 7L),
    exit = c(rep("2009-01-01", 6L), "2011-01-01")
  )
  res <- getExitBeforeBirthWarning(ped)
  expect_identical(
    res$Details,
    paste0("6 of 7 animals have an exit date earlier than their birth date ",
           "(first 5: A1, A2, A3, A4, A5). Their age comes out zero or ",
           "negative. Check those dates in your file.")
  )
})

test_that("getExitBeforeBirthWarning reads the date columns by their exact names", {
  ## ped$exit would also find a column called exitDate, and ped$birth one
  ## called birthDate; the cleaned pedigree's two columns are exit and birth.
  noExit <- data.frame(id = "A1", birth = as.Date("2001-01-02"),
                       exitDate = as.Date("2001-01-01"),
                       stringsAsFactors = FALSE)
  noBirth <- data.frame(id = "A1", birthDate = as.Date("2001-01-02"),
                        exit = as.Date("2001-01-01"),
                        stringsAsFactors = FALSE)
  expect_identical(nrow(getExitBeforeBirthWarning(noExit)), 0L)
  expect_identical(nrow(getExitBeforeBirthWarning(noBirth)), 0L)
})

test_that("getExitBeforeBirthWarning writes the counts as plain numbers", {
  ped <- makeExitPed(
    birth = rep("2010-01-01", 1500L),
    exit = c(rep("2009-01-01", 1200L), rep("2011-01-01", 300L))
  )
  res <- getExitBeforeBirthWarning(ped)
  expect_match(res$Details, "^1200 of 1500 animals have an exit date earlier")
})

test_that("getExitBeforeBirthWarning returns no row when no exit is before its birth", {
  res <- getExitBeforeBirthWarning(
    makeExitPed(birth = c("2001-01-01", "2002-02-02"),
                exit = c("2003-03-03", NA))
  )
  expect_s3_class(res, "data.frame")
  expect_named(res, c("Row", "Warning", "Details"))
  expect_identical(nrow(res), 0L)
  expect_type(res$Row, "integer")
  expect_type(res$Warning, "character")
  expect_type(res$Details, "character")
})

test_that("getExitBeforeBirthWarning returns no row when every exit date is blank", {
  res <- getExitBeforeBirthWarning(
    makeExitPed(birth = c("2001-01-01", "2002-02-02"), exit = c(NA, NA))
  )
  expect_identical(nrow(res), 0L)
})

test_that("getExitBeforeBirthWarning returns no row for a pedigree with no animals", {
  res <- getExitBeforeBirthWarning(makeExitPed(character(0L), character(0L)))
  expect_named(res, c("Row", "Warning", "Details"))
  expect_identical(nrow(res), 0L)
})

test_that("getExitBeforeBirthWarning returns no row, without failing, if a date column is missing", {
  ## A missing birth column is already an error ("Missing required columns"),
  ## and a pedigree with no death, departure or exit column has no exit
  ## column, so neither case has animals to count.
  noExit <- data.frame(id = c("A", "B"), birth = as.Date(c("2001-01-01",
                                                          "2002-02-02")),
                       stringsAsFactors = FALSE)
  noBirth <- data.frame(id = c("A", "B"), exit = as.Date(c("2001-01-01",
                                                          "2002-02-02")),
                        stringsAsFactors = FALSE)
  for (ped in list(noExit, noBirth)) {
    res <- getExitBeforeBirthWarning(ped)
    expect_named(res, c("Row", "Warning", "Details"))
    expect_identical(nrow(res), 0L)
  }
})

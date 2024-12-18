#' Copyright(c) 2017-2020 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("convertDate")
library(testthat)
library(lubridate)
set_seed(10)
someBirthDates <- paste0(sample(seq(0, 15, by = 3), 10, replace = TRUE) + 2000,
                         "-", sample(1:12, 10, replace = TRUE), "-",
                    sample(1:28, 10, replace = TRUE))
someBadBirthDates <- paste0(sample(1:12, 10, replace = TRUE), "-",
                         sample(1:28, 10, replace = TRUE), "-",
                         sample(seq(0, 15, by = 3), 10, replace = TRUE) + 2000)
someDeathDates <- sample(someBirthDates, length(someBirthDates),
                         replace = FALSE)
someDepartureDates <- sample(someBirthDates, length(someBirthDates),
                             replace = FALSE)
ped1 <- data.frame(birth = someBadBirthDates, death = someDeathDates,
                   departure = someDepartureDates)
someDates <- ymd(someBirthDates)
ped2 <- data.frame(birth = someDates, death = someDeathDates,
                   departure = someDepartureDates)
ped3 <- data.frame(birth = someBirthDates, death = someDeathDates,
                   departure = someDepartureDates)
someNADeathDates <- someDeathDates
someNADeathDates[c(1, 3, 5)] <- ""
someNABirthDates <- someDates
someNABirthDates[c(2, 4, 6)] <- NA
ped4 <- data.frame(birth = someNABirthDates, death = someNADeathDates,
                   departure = someDepartureDates)

test_that("convertDate identifies bad dates", {
  expect_error(convertDate(ped1))
})
test_that("convertDate with error flag returns error list", {
  expect_equal(convertDate(ped1, reportErrors = TRUE),
               c("1", "2", "3", "4", "5", "6", "7", "8", "9", "10"))
})
test_that("convertDate likes good dates", {
  expect_true(all(is.Date(convertDate(ped2)$birth)))
  expect_true(all(is.Date(convertDate(ped3)$birth)))
})
test_that("convertDate with error flag returns NULL with good dates", {
  expect_true(all(is.null(convertDate(ped2, reportErrors = TRUE))))
  expect_true(all(is.null(convertDate(ped3, reportErrors = TRUE))))
})
test_that(paste0("convertDate handles NA and empty character string values ",
                 "correctly"), {
  expect_null(convertDate(ped4, reportErrors = TRUE))
})
test_that("convertDate ignores added records", {
  ped5 <- cbind(ped4, recordStatus = c(rep("added", 10)),
                stringsAsFactors = FALSE)
  expect_equal(nrow(convertDate(ped5)), 10)
  expect_true(all(convertDate(ped5)$recordStatus == "added"))
})
test_that("convertDate fails when date column class is real", {
  ped5 <- ped3
  ped5$birth <- rnorm(10, 10, 100)
  expect_error(convertDate(ped5))
})

ped <- nprcgenekeepr::pedInvalidDates
rowsWithBadDates <- convertDate(ped, reportErrors = TRUE)
test_that("classifies dates <= 1000 CE as errors", {
  expect_true(any(3 %in% rowsWithBadDates))
})
pedWithNAs <- ped
pedWithNAs[, "birth"] <- as.Date(pedWithNAs[, "birth"], origin = "1970-01-01")

pedWithNAs <- convertDate(pedWithNAs, reportErrors = FALSE)
test_that("classifies dates <= 1000 CE as errors", {
  expect_true(all(is.na(pedWithNAs[3:4, "birth"])))
})

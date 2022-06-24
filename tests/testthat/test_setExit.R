#' Copyright(c) 2017-2022 R. Mark Sharp
# This file is part of nprcgenekeepr
context("setExit")
library(testthat)
library(lubridate)
set_seed(10)
death <- mdy(paste0(sample(1:12, 10, replace = TRUE), "-",
                   sample(1:28, 10, replace = TRUE), "-",
                   sample(seq(0, 15, by = 3), 10, replace = TRUE) + 2000))
departure <- as.Date(rep(NA, 10), origin = as.Date("1970-01-01"))
departure[c(1, 3, 6)] <- as.Date(death[c(1, 3, 6)],
                                 origin = as.Date("1970-01-01"))
death[c(1, 3, 5)] <- NA
death[6] <- death[6] + days(1)
ped <- data.frame(
  id = paste0(100 + 1:10),
  birth = mdy(paste0(sample(1:12, 10, replace = TRUE), "-",
                     sample(1:28, 10, replace = TRUE), "-",
                     sample(seq(0, 20, by = 3), 10, replace = TRUE) + 1980)),
  death = death,
  departure = departure,
  stringsAsFactors = FALSE)
ped_1 <- setExit(ped)
ped_2 <- setExit(ped[ , -3])
ped_3 <- setExit(ped[ , -4])
ped_4 <- setExit(ped[ , c(-3, -4)])
test_that("setExit picks the correct date", {
  expect_true(all(is.na(ped_4$exit)))
  expect_equal(format(ped_3$exit[[2]], format = "%Y-%m-%d"), "2009-04-16")
  expect_true(all(is.na(ped_4$exit[c(1, 3, 5)])))
  expect_equal(format(ped_2$exit[[1]], format = "%Y-%m-%d"), "2015-07-19")
  expect_equal(format(ped_2$exit[[3]], format = "%Y-%m-%d"), "2012-06-04")
  expect_true(all(is.na(ped_2$exit[c(2, 4:5, 7:10)])))
  expect_equal(format(ped_1$exit[[6]], format = "%Y-%m-%d"), "2012-03-13")
  expect_equal(format(ped_1$exit[[7]], format = "%Y-%m-%d"), "2015-04-02")
  expect_true(all(!is.na(ped_1$exit[c(1:4, 6:10)])))
})
test_that("setExit returns same empty dataframe as provided if nrow() == 0", {
  emptyDf <- data.frame(
    id = integer(0),
    birth = as.Date(numeric(0), origin = "1-1-1970"),
    death = as.Date(numeric(0), origin = "1-1-1970"),
    departure = as.Date(numeric(0), origin = "1-1-1970"),
    stringsAsFactors = FALSE)
  expect_equal(setExit(emptyDf), emptyDf)
})

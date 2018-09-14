context("getPedMaxAge")
library(testthat)
library(lubridate)
library(stringi)

set.seed(10)
pedOne <- data.frame(ego_id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
                  sire = c(NA, NA, NA, NA, "s1", "s1", "s2", "s2"),
                  dam_id = c(NA, NA, NA, NA, "d1", "d2", "d2", "d2"),
                  sex = c("F", "M", "M", "F", "F", "F", "F", "M"),
                  birth_date = mdy(
                    paste0(sample(1:12, 8, replace = TRUE), "-",
                           sample(1:28, 8, replace = TRUE), "-",
                           sample(seq(0, 15, by = 3), 8, replace = TRUE) +
                             2000), tz = "America/Chicago"),
                  stringsAsFactors = FALSE, check.names = FALSE)
pedOne$age <- (mdy("10-05-2017", tz = "America/Chicago") -
                 as.POSIXct(pedOne$birth)) / dyears(1)

test_that("getPedMaxAge finds max age", {
  expect_equal(getPedMaxAge(pedOne), 17.227146, tolerance = 0.01)
  expect_equal(getPedMaxAge(pedOne[c(-1, -2), ]), 11.48742, tolerance = 0.01)
})
#' Copyright(c) 2017-2022 R. Mark Sharp
# This file is part of nprcgenekeepr
context("obfuscateDate")
library(testthat)

test_that("obfuscateDate creates new date within accepted range", {
  targetDate <- as.Date("2009-2-28", format = "%Y-%m-%d")
  minBirthDate <- as.Date("2009-2-14", format = "%Y-%m-%d")
  for (i in 1:10) {
    obDate <- obfuscateDate(targetDate, 30, minBirthDate)
    expect_true(obDate >= as.Date("2009-02-14", format = "%Y-%m-%d"))
    expect_true(obDate <= as.Date("2009-03-30", format = "%Y-%m-%d"))
  }
})
test_that(
  "obfuscateDate creates new dates within accepted range with list of dates", {
  targetDate <- list(
    as.Date("2009-2-28", format = "%Y-%m-%d"),
    as.Date("2003-10-03", format = "%Y-%m-%d")
  )
  minBirthDate <- list(
    as.Date("2009-2-14", format = "%Y-%m-%d"),
    as.Date("2003-10-03", format = "%Y-%m-%d")
  )
  for (i in 1:10) {
    obDate <- obfuscateDate(targetDate, 30, minBirthDate)
    expect_true(obDate[[1]] >= as.Date("2009-02-14", format = "%Y-%m-%d"))
    expect_true(obDate[[1]] <= as.Date("2009-03-30", format = "%Y-%m-%d"))
    expect_true(obDate[[2]] >= as.Date("2003-10-03", format = "%Y-%m-%d"))
    expect_true(obDate[[2]] <= as.Date("2003-11-02", format = "%Y-%m-%d"))
  }
})
test_that(
  paste0("obfuscateDate fails when length of minDate is not 1 or the ",
         "same as baseDate length."), {
  targetDate <- list(
    as.Date("2009-2-28", format = "%Y-%m-%d"),
    as.Date("2003-10-03", format = "%Y-%m-%d"))
  minBirthDate <- list(
    as.Date("2009-2-14", format = "%Y-%m-%d"))
  expect_error(obfuscateDate(targetDate, 10, minBirthDate),
               "Length of baseDate and minDate must be the same.")
  minBirthDate <- list(
    as.Date("2009-2-14", format = "%Y-%m-%d"),
    as.Date("2003-2-14", format = "%Y-%m-%d"),
    as.Date("2003-10-03", format = "%Y-%m-%d")
  )
  expect_error(obfuscateDate(targetDate, 10, minBirthDate),
               "Length of baseDate and minDate must be the same.")
})
test_that(
  paste0("obfuscateDate fails when length of maxDelta is not 1 or the ",
         "same as baseDate length."), {
           targetDate <- list(
             as.Date("2009-2-28", format = "%Y-%m-%d"),
             as.Date("2003-10-03", format = "%Y-%m-%d")
           )
           minBirthDate <- list(
             as.Date("2009-2-14", format = "%Y-%m-%d"),
             as.Date("2003-10-03", format = "%Y-%m-%d")
           )
           expect_error(obfuscateDate(targetDate, c(10, 30, 20), minBirthDate),
                        "Length of minDate must be 1 or the same as baseDate.")
         })

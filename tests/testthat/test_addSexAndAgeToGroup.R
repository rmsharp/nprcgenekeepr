#' Copyright(c) 2017-2022 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("addSexAndAgeToGroup")
library(testthat)
library(nprcgenekeepr)
library(lubridate)
data("qcBreeders")
data("qcPed")
skip_if_not(exists("qcBreeders"))
skip_if_not(exists("qcPed"))
test_that("addSexAndAgeToGroup forms the correct dataframe", {
  df <- addSexAndAgeToGroup(ids = qcBreeders, ped = qcPed)
  expect_equal(length(df), 3)
  expect_equal(length(df[["ids"]]), 29)
  expect_equal(names(df), c("ids", "sex", "age"))
  expect_equal(df$ids[1], "Q0RGP7")
  expect_equal(as.character(df$sex[1]), "F")
}
)

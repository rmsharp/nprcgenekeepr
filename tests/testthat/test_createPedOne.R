#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("createPedOne")
library(testthat)
pedOne <- createPedOne(savePed = FALSE)
test_that("createPedOne makes the right pedigree", {
  expect_equal(nrow(pedOne), 8)
  expect_equal(ncol(pedOne), 5)
  expect_equal(names(pedOne)[1], "ego_id")
})
pedOne <- createPedOne(savePed = TRUE)
test_that("createPedOne makes the right pedigree and saves it", {
  expect_equal(names(pedOne)[1], "ego_id")
})

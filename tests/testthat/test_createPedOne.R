#' Copyright(c) 2017-2022 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("createPedOne")
library(testthat)
pedOne <- nprcgenekeepr:::createPedOne(savePed = FALSE)
test_that("createPedOne makes the right pedigree", {
  expect_equal(nrow(pedOne), 8)
  expect_equal(ncol(pedOne), 6)
  expect_equal(names(pedOne)[1], "ego_id")
})
pedOne <- suppressMessages(nprcgenekeepr:::createPedOne(savePed = TRUE))
test_that("createPedOne makes the right pedigree when saving file", {
  expect_equal(nrow(pedOne), 8)
  expect_equal(ncol(pedOne), 6)
  expect_equal(names(pedOne)[1], "ego_id")
})



#' Copyright(c) 2017-2020 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("createPedSix")
library(testthat)
pedSix <- createPedSix(savePed = FALSE)
test_that("createPedSix makes the right pedigree", {
  expect_equal(nrow(pedSix), 8)
  expect_equal(ncol(pedSix), 7)
  expect_equal(names(pedSix)[1], "Ego Id")
})


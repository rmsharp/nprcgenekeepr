#' Copyright(c) 2017-2020 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("getLogo")
library(testthat)
logo <- suppressWarnings(getLogo())
test_that("getLogo returns reasonalble values", {
  expect_true(is.integer(logo$height))
  expect_true(is.integer(logo$width))
  expect_true(logo$height > 0)
  expect_true(logo$width > 0)
  expect_true(is.character(logo$file))
})
## See also: Drop-in replacement for testthat::with_mock()
## https://krlmlr.github.io/mockr
## mock getSiteInfo()
test_that("getLogo returns reasonalble values with SNPRC mock", {
  with_mock(
    getSiteInfo = function() {
      list(center = "SNPRC")
    },
    logo <- suppressWarnings(getLogo()),
    expect_true(is.integer(logo$height)),
    expect_true(is.integer(logo$width)),
    expect_true(logo$height > 0),
    expect_true(logo$width > 0),
    expect_true(is.character(logo$file))
  )
})
test_that("getLogo returns reasonalble values with ONPRC mock", {
  with_mock(
    getSiteInfo = function() {
      list(center = "ONPRC")
    },
    logo <- suppressWarnings(getLogo()),
    expect_true(is.integer(logo$height)),
    expect_true(is.integer(logo$width)),
    expect_true(logo$height > 0),
    expect_true(logo$width > 0),
    expect_true(is.character(logo$file))
  )
})

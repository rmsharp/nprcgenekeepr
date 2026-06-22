#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr

test_that("makeGroupNum builds the initial grpNum list", {
  expect_identical(makeGroupNum(3L), list(1L, 2L, 3L))
  expect_identical(makeGroupNum(1L), list(1L))
})

test_that("makeGrpNum still works but is deprecated", {
  expect_warning(g <- makeGrpNum(3L), "makeGroupNum")
  expect_identical(g, list(1L, 2L, 3L))
})

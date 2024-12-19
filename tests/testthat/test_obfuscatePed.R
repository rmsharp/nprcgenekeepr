#' Copyright(c) 2017-2024 R. Mark Sharp
# This file is part of nprcgenekeepr
context("obfuscatePed")
library(testthat)

test_that("obfuscatePed creates correctly obfuscated pedigree", {
  pedSix <- qcStudbook(nprcgenekeepr::pedSix)
  ped <- obfuscatePed(pedSix, size = 3, maxDelta = 20)
  expect_equal(nrow(ped), nrow(pedSix))
  expect_equal(ncol(ped), ncol(pedSix))
  expect_equal(ped$id[1], ped$dam[7])
  expect_equal(ped$id[1], ped$dam[7])
  expect_true(all(ped$id[2] == ped$dam[c(8, 11, 12)]))
  expect_true(max(abs(pedSix$birth[!is.na(pedSix$birth)] -
                        ped$birth[!is.na(ped$birth)])) <= 20)
})
test_that("obfuscatePed creates ID map on request", {
  pedSix <- qcStudbook(nprcgenekeepr::pedSix)
  ped <- obfuscatePed(pedSix, size = 3, maxDelta = 20, map = TRUE)
  expect_true(class(ped) == "list")
  expect_equal(names(ped), c("ped", "map"))
  expect_equal(class(ped$ped), "data.frame")
  expect_equal(class(ped$map), "character")
  expect_equal(names(ped$map), pedSix$id)
  expect_equal(as.character(ped$map), ped$ped$id)
})

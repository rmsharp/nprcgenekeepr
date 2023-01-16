#' Copyright(c) 2017-2023 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("createPedTree")
library(testthat)
data("smallPed")
ped <- smallPed
pedTree <- createPedTree(ped)
test_that("createPedTree correctly breaks up pedigrees", {
  for (id in ped$id) {
    expect_equal(pedTree[[id]][["sire"]], ped$sire[ped$id == id])
    expect_equal(pedTree[[id]][["dam"]], ped$dam[ped$id == id])
  }
})

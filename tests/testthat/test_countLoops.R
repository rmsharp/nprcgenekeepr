#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("countLoops")
library(testthat)
ped <- nprcgenekeepr::qcPed
ped <- qcStudbook(ped, minParentAge = 0)
pedTree <- createPedTree(ped)
pedLoops <- findLoops(pedTree)
test_that("countLoops correctly counts loops", {
  nLoops <- countLoops(pedLoops, pedTree)
  expect_equal(sum(unlist(nLoops[nLoops > 0])), 45)
})

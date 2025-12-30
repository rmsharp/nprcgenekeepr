#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of mprcgenekeepr
context("countLoops")

ped <- mprcgenekeepr::qcPed
ped <- qcStudbook(ped, minParentAge = 0L)
pedTree <- createPedTree(ped)
pedLoops <- findLoops(pedTree)
test_that("countLoops correctly counts loops", {
  nLoops <- countLoops(pedLoops, pedTree)
  expect_equal(sum(unlist(nLoops[nLoops > 0L])), 45L)
})

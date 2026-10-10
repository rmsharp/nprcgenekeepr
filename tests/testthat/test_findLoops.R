## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)
data("smallPed")
ped <- smallPed
data("smallPedTree")
smallLoops <- findLoops(smallPedTree)
test_that("findLoops correctly locates loops", {
  expect_false(all(sapply(smallLoops, function(item) item)))
  ped$sire[ped$id == "K"] <- "A"
  pedTree <- createPedTree(ped)
  loops <- findLoops(pedTree)
  expect_true(loops$L)
  expect_false(all(sapply(loops[!names(loops) == "L"], function(item) item)))
  ped$sire[ped$id == "K"] <- "Q"
  pedTree <- createPedTree(ped)
  loops <- findLoops(pedTree)
  expect_true(loops$L)
  expect_false(all(sapply(loops[!names(loops) == "L"], function(item) item)))
})

# A parent with no entry of its own in the tree is an animal with unknown
# parents (see test_getAncestors.R), so a loop through one is still found.
test_that("findLoops on a raw tree with absent parents equals the answer after qcStudbook()", {
  trees <- absentParentTrees()
  rawLoops <- findLoops(trees$raw)
  qcLoops <- findLoops(trees$qc)
  expect_identical(rawLoops, qcLoops[names(rawLoops)])
})

test_that("findLoops finds a loop through an absent grandparent shared by both parents", {
  rawLoops <- findLoops(absentParentTrees()$raw)
  expect_true(rawLoops$K)
  expect_false(rawLoops$N)
})

## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

ped <- nprcgenekeepr::qcPed
ped <- qcStudbook(ped, minParentAge = 0L)
pedTree <- createPedTree(ped)
pedLoops <- findLoops(pedTree)
test_that("countLoops correctly counts loops", {
  nLoops <- countLoops(pedLoops, pedTree)
  expect_equal(sum(unlist(nLoops[nLoops > 0L])), 45L)
})

test_that("countLoops on a raw tree with absent parents equals the answer after qcStudbook()", {
  trees <- absentParentTrees()
  rawCounts <- countLoops(findLoops(trees$raw), trees$raw)
  qcCounts <- countLoops(findLoops(trees$qc), trees$qc)
  expect_identical(rawCounts, qcCounts[names(rawCounts)])
})

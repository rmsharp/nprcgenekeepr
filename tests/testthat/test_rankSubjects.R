## Copyright(c) 2017-2026 R. Mark Sharp
# This file is part of nprcgenekeepr
library(testthat)
## reportGV() unit test is weak.
rpt <- rankSubjects(nprcgenekeepr::finalRpt)
test_that("rankSubjects ranks subject correctly", {
  expect_identical(nrow(rpt[[2L]]), 68L)
  expect_identical(rpt[[1L]][1L, "value"], "High Value")
  expect_identical(rpt[[3L]][1L, "value"], "Low Value")
  expect_identical(rpt[[3L]][1L, "rank"], 190L)
  expect_identical(rpt[["lowMk"]][68L, "rank"], 189L)
})

## S920: the bundled report has no no-parentage tier, so nothing above pins the
## "Undetermined" label or that those animals stay unranked.
test_that("rankSubjects labels the no-parentage tier Undetermined and leaves it unranked", {
  tiers <- list(
    highGu = data.frame(id = c("a1", "a2"), stringsAsFactors = FALSE),
    noParentage = data.frame(id = c("n1", "n2"), stringsAsFactors = FALSE),
    lowVal = data.frame(id = "l1", stringsAsFactors = FALSE)
  )
  out <- rankSubjects(tiers)
  expect_identical(out$highGu$value, c("High Value", "High Value"))
  expect_identical(out$noParentage$value, c("Undetermined", "Undetermined"))
  expect_identical(out$lowVal$value, "Low Value")
  expect_identical(out$highGu$rank, 1:2)
  expect_true(all(is.na(out$noParentage$rank)))
  expect_identical(out$lowVal$rank, 3L)
})

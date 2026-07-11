## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' Structure/type contract for the bundled `examplePedigree` data object's
#' `fromCenter` (colony-origin) column (BACKLOG.md item, discovered S348):
#' derived from the pre-existing, documented `origin` field (blank origin +
#' recordStatus == "original" -> local/colony-born; imported animals or
#' recordStatus == "added" placeholder rows -> not confirmed colony-born) so
#' the shipped example pedigree can demonstrate a populated Potential
#' Parents result end to end, not just the graceful-degradation state.
ped <- nprcgenekeepr::examplePedigree

test_that("examplePedigree has a fromCenter column", {
  expect_true("fromCenter" %in% names(ped))
  expect_type(ped$fromCenter, "logical")
  expect_identical(sum(is.na(ped$fromCenter)), 0L)
})

test_that("examplePedigree fromCenter reflects origin/recordStatus", {
  expect_identical(sum(ped$fromCenter), 2267L)
  expect_identical(sum(!ped$fromCenter), 1427L)
  expect_true(all(!ped$fromCenter[ped$recordStatus == "added"]))
  expect_true(all(!ped$fromCenter[!is.na(ped$origin) & ped$origin != ""]))
  expect_true(all(ped$fromCenter[
    !is.na(ped$origin) & ped$origin == "" & ped$recordStatus == "original"
  ]))
})
